# Projeto de Computação em Nuvem

Projeto de implementação de um ALB entre instâncias EC2 com Auto Scaling e Banco de dados RDS

**Por: Renato Laffranchi Falcão**

## Objetivo de Implementação

![diagrama de arquitetura](img/arquitetura.png)

### Setup do ambiente de desenvolvimento

O projeto será desenvolvido em Terraform, uma ferramenta de desenvolvimento de infraestrutura como código (IaC), que irá gerenciar instâncias e serviços da provedora AWS. O diretório do projeto pode ser estruturado da seguinte forma:

    .
    ├── terraform/
    │   ├── main.tf
    │   ├── ec2.tf
    │   ├── rds.tf
    └────── outputs.tf

Nesta estrutura de diretórios, o arquivo **main.tf** contém ...

O arquivo **outputs.tf** contém ...

Antes de mais nada, é necessário realizar a instalação do Terraform. Para tanto, basta seguir o [tutorial de instalação do Terraform](https://developer.hashicorp.com/terraform/downloads) de acordo com o sistema operacional.

Além do Terraform, também é preciso instalar a [CLI da AWS](https://aws.amazon.com/pt/cli/) de acordo com o sistema operacional. 

Por fim, deve-se configurar as credencias da AWS para que o Terraform realize todo o gerenciamento. A seguinte forma de fazer esta configuração é uma boa prática para evitar vazamento de credenciais caso os scripts sejam compartilhados. Utilizando o comando:

    aws configure

- `AWS Access Key ID` e `AWS Secret Access Key ID`: O **ID** e a **chave de acesso** gerados no console da AWS, na aba *"Credenciais de Segurança"*.
- `Default region name`: A região padrão para se implantar serviços e instâncias. Neste caso, está sendo utilizada a região **MUDAR A REGIÃO AQUI**.
- `Default output format`: O formato de saída padrão das respostas recebidas. Por simplicidade, **json**.

# MUDAR TUDO A PARTIR DAQUI

### Inicialização do projeto

Inicialmente, crie um diretório para guardar todos os arquivos do projeto:

    mkdir Projeto-Computacao-Nuvem
    mkdir Projeto-Computacao-Nuvem/terraform
    cd Projeto-Computacao-Nuvem/terraform

Agora crie e acesse um arquivo chamado `main.tf` :

    touch main.tf
    sudo nano main.tf

<aside>
💡 Dentro deste arquivo colocaremos toda a nossa infraestrutura

</aside>

Primeiro, vamos iniciar o arquivo com o seguinte código:

    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 4.0"
        }
      }
    }

    provider "aws" {
      alias   = "region_main"
      region  = "us-east-1"
      profile = "default"
    }

Com este bloco, estamos configurando o Terraform com o provedor que estaremos utilizando, que neste caso é a AWS, especificando também a versão do provedor, a região na qual as aplicações serão implantadas, bem como um apelido para este provedor (”region_main”). Além do mais, este provedor é definido como o provedor padrão. Isso significa que todos os serviços e instâncias serão implantados a partir deste provedor, nesta região, a menos que um outro provedor seja especificado.

### Configuração de rede

Em seguida, vamos definir uma VPC (Virtual Private Cloud). A VPC é uma rede virtual que isola o que está dentro dela para com o resto da internet. E é dentro dela que toda a infraestrutura vai funcionar. Para criá-la, basta adicionar o seguinte bloco de código:

    resource "aws_vpc" "app_vpc" {
      cidr_block = "172.16.0.0/16"
      tags = {
        Name = "app_vpc"
      }
    }

    resource "aws_internet_gateway" "app_gateway" {
      vpc_id = aws_vpc.app_vpc.id

      tags = {
        Name = "app_gateway"
      }
    }

Estes códigos criam, respectivamente, a VPC, com bloco de endereços na faixa de 172.16.0.0/16, e um Gateway de Internet, para que o mundo externo consiga se comunicar com a rede interna à VPC.

A seguir, iremos configurar nossas duas sub-redes, nas quais as instâncias serão implantadas. Para configurar sub-redes:

    resource "aws_subnet" "app_subnet_e1a" {
      vpc_id                  = aws_vpc.app_vpc.id
      cidr_block              = "172.16.64.0/19"
      availability_zone       = "us-east-1a"
      map_public_ip_on_launch = true

      tags = {
        Name = "app_public_subnet_e1a"
      }
    }

    resource "aws_subnet" "app_subnet_e1b" {
      vpc_id                  = aws_vpc.app_vpc.id
      cidr_block              = "172.16.96.0/19"
      availability_zone       = "us-east-1b"
      map_public_ip_on_launch = true

      tags = {
        Name = "app_public_subnet_e1b"
      }
    }

Estas sub-redes estão configuradas dentro da VPC, portanto na mesma região, mas em zonas de disponibilidade diferentes. Estão configuradas para utilizarem os blocos de endereço 172.16.64.0/19 e 172.16.96.0/19, de forma “pública”, ou seja, mapeando IPs públicos quando instâncias são criadas nestas sub-redes. Esta configuração é um primeiro passo para permitir que acessemos tais instâncias via SSH, caso desejemos.

Após a criação das sub-redes, precisamos configurar uma tabela de roteamento, que vai rotear e direcionar o tráfego dentro da VPC para as devidas sub-redes. Para isso vamos adicionar o seguinte código:

    resource "aws_route_table" "app_route_table" {
      vpc_id = aws_vpc.app_vpc.id

      route {
        gateway_id = aws_internet_gateway.app_gateway.id
        cidr_block = "0.0.0.0/0"
      }

      tags = {
        Name = "app_route_table"
      }

    }

    resource "aws_route_table_association" "app_route_table_association_e1a" {
      subnet_id      = aws_subnet.app_subnet_e1a.id
      route_table_id = aws_route_table.app_route_table.id
    }

    resource "aws_route_table_association" "app_route_table_association_e1b" {
      subnet_id      = aws_subnet.app_subnet_e1b.id
      route_table_id = aws_route_table.app_route_table.id
    }

Desta forma, tanto as sub-redes criadas, como o gateway de internet são registrados na tabela de roteamento, permitindo que o tráfego seja direcionado corretamente.  

### Configuração dos grupos de segurança

A partir do momento em que temos a rede configurada, podemos começar a pensar na implantação das instâncias e do load balancer. No entanto, para que elas funcionem corretamente, é necessário que sejam configurados os grupos de segurança, bem como suas regras. Esses grupos de segurança definem as permissões que as instâncias ou serviços tem para receber ou enviar pacotes. Em geral, essas regras definem, principalmente, portas de acesso permitidas, protocolos de comunicação e endereços que podem fazer as requisições.

Primeiramente, vamos criar dois grupos de segurança: um para as instâncias e um para o load balancer:

    resource "aws_security_group" "app_security_group" {
      name   = "app_security_group"
      vpc_id = aws_vpc.app_vpc.id
    }

    resource "aws_security_group" "lb_security_group" {
      name   = "lb_security_group"
      vpc_id = aws_vpc.app_vpc.id
    }

Agora, vamos criar as regras que definirão o comportamento das instâncias:

    resource "aws_security_group_rule" "app_ingress_rule" {
      type              = "ingress"
      from_port         = 80
      to_port           = 80
      protocol          = "tcp"
      security_group_id = aws_security_group.app_security_group.id
      cidr_blocks       = ["0.0.0.0/0"]
    }

    resource "aws_security_group_rule" "app_ingress_rule_ssh" {
      type              = "ingress"
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      security_group_id = aws_security_group.app_security_group.id
      cidr_blocks       = ["0.0.0.0/0"]
    }

A primeira regra define que as instâncias podem **************receber************** dados na porta 80, por protocolo TCP (isso inclui a permissão de protocolos de comunicação de mais alto nível, como HTTP e HTTPS). A permissão é dada para que as instâncias recebam dados de qualquer IP.

Já a segunda regra define que as instâncias podem **************receber************** dados na porta 22, que é a padrão para acesso de SSH, por protocolo TCP, também de qualquer IP.

E pensando nas regras para definir o comportamento do load balancer, temos:

    resource "aws_security_group_rule" "lb_ingress_rule" {
      type              = "ingress"
      from_port         = "-1"
      to_port           = "-1"
      protocol          = "-1"
      security_group_id = aws_security_group.lb_security_group.id
      cidr_blocks       = ["0.0.0.0/0"]
    }

    resource "aws_security_group_rule" "lb_egress_rule" {
      type              = "egress"
      from_port         = "-1"
      to_port           = "-1"
      protocol          = "-1"
      security_group_id = aws_security_group.lb_security_group.id
      cidr_blocks       = ["0.0.0.0/0"]
    }

Estas regras, resumo, permitem que o load balancer tanto ************receba************ quanto **********envie********** dados, através de ********todas******** as suas portas, de ****************************************qualquer endereço IP****************************************. Isso abre um maior leque de possibilidades para o futuro, caso se deseje adicionar novas aplicações para o load balancer ou até mesmo acessá-lo de diferentes lugares do mundo, dando maior flexibilidade para este serviço. 

### Configuração das instâncias

Finalizadas as configurações dos grupos de segurança, vamos começar pela implantação das instâncias, que carregarão uma aplicação Wordpress. Vamos utilizar um bloco que permitirá a criação das instâncias de forma simplificada e pode ser usada para replicar o processo de criação de mais instâncias:

    locals {
      apps = {
        app_1 = {
          machine_type = "t3a.small"
          subnet_id    = aws_subnet.app_subnet_e1a.id
        }
        app_2 = {
          machine_type = "t3a.small"
          subnet_id    = aws_subnet.app_subnet_e1b.id
        }
      }
    }

Este bloco define as características exclusivas das instâncias que serão criadas, permitindo que utilizemos um loop “for_each” do Terraform para criar as instâncias:

    resource "aws_instance" "app_instance" {
      for_each = local.apps

      ami           = "ami-0d5627e38262b3304"
      instance_type = each.value.machine_type
      subnet_id     = each.value.subnet_id

      vpc_security_group_ids = [aws_security_group.app_security_group.id]

      tags = {
        Name = each.key
      }
    }

Estas configurações permitem que duas instâncias sejam criadas nas duas diferentes zonas de disponibilidade, com seus respectivos tipos de máquina, ambas utilizando do mesmo grupo de segurança criado na etapa anterior. AMI’s (Amazon Machine Images ou Imagens de Máquina da Amazon) são imagens mantidas pela AWS que fornecem as informações de sistema operacional e execução de aplicações necessárias para iniciar uma instância. Desta forma, a imagem escolhida foi uma que já realiza a implantação automática do Wordpress em sistema operacional Debian.

### Configuração do Load Balancer

Finalmente podemos começar a configuração do Load Balancer. O serviço de load balancing é dividido em algumas partes. Primeiramente, é necessário configurar um “Target Group” (ou grupo de destino) do balancer. O grupo de destino é usado para rotear o tráfego entre o balanceador de carga e os servidores de destino registrados nele:

    resource "aws_lb_target_group" "app_target_group" {
      name     = "apptargetgroup"
      port     = 80
      protocol = "HTTP"
      vpc_id   = aws_vpc.app_vpc.id

      load_balancing_algorithm_type = "round_robin"

      health_check {
        enabled             = true
        port                = 80
        interval            = 30
        protocol            = "HTTP"
        path                = "/"
        matcher             = "200"
        healthy_threshold   = 3
        unhealthy_threshold = 3
      }
    }

O target group define a porta na qual o tráfego será roteado para os servidores de destino no grupo de destino, que neste caso será encaminhado para a porta 80, define o protocolo que será usado para o tráfego entre o balanceador de carga e os servidores de destino, neste caso o HTTP, especifica o ID da VPC na qual o grupo de destino será criado, define o algoritmo de balanceamento de carga que será usado pelo grupo de destino e define, na seção health_check, as configurações de verificação de integridade para os servidores de destino no grupo de destino, que é usado para determinar se um servidor de destino está saudável e pode receber tráfego.

Em seguida, deve-se “acoplar” as instâncias criadas ao grupo de destino:

    resource "aws_lb_target_group_attachment" "app_target_group_attachment" {
      for_each = aws_instance.app_instance

      target_group_arn = aws_lb_target_group.app_target_group.arn
      target_id        = each.value.id
      port             = 80
    }

Este código usa novamente o loop for_each para “acoplar” ambas as instâncias grupo de destino, especificando seu ARN (Amazon Resource Name ou Nome de Recurso da Amazon) e o id da instância.

Agora é hora de criar o recurso do load balancer propriamente dito, que neste caso será configurado como um load balancer do tipo “aplicação”, isto é, opera na camada de aplicação:

    resource "aws_lb" "app_elb" {
      name               = "app-elb"
      internal           = false
      load_balancer_type = "application"
      security_groups    = [aws_security_group.lb_security_group.id]

      subnets = [
        aws_subnet.app_subnet_e1a.id,
        aws_subnet.app_subnet_e1b.id
      ]
    }

Este recurso define se o balanceador de carga é interno ou externo, ou seja, se ele pode ser visto apenas pela rede interna da VPC ou também pela rede externa. Neste caso, queremos que ela esteja visível pela rede externa também, para podermos acessá-la. Além disso, o grupo de segurança criado anteriormente é associado ao recurso e as sub-redes de operação são especificadas.

Então, para tornar o load balancer disponível para receber requisições e encaminhá-las às instâncias, podemos utilizar o recurso de “listener” a seguir:

    resource "aws_lb_listener" "app_listener" {
      load_balancer_arn = aws_lb.app_elb.arn
      port              = "80"
      protocol          = "HTTP"

      default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_target_group.arn
      }
    }

Neste código, o recurso de load balancing a que ele está associado é declarado, definindo também a porta em que está escutando as requisições, neste caso é a porta 80,  o protocolo utilizado, o HTTP, e o grupo para o qual o tráfego será direcionado. Desta forma, o listener é responsável apenas por encaminhar os dados, sendo responsabilidade do algoritmo do load balancer de dividir o tráfego.

Agora salve e feche o arquivo `main.tf`.

### Finalização e Implantação

Este código em Terraform é o suficiente para implantar toda a infraestrutura necessária. No entanto, para se acessar a aplicação, através do load balancer, precisamos recuperar de alguma forma o nome do DNS público no qual a aplicação está disponível. Para isso, vamos utilizar os “outputs” do Terraform.

Crie e acesse um arquivo chamado `outputs.tf`:

    touch outputs.tf
    sudo nano outputs.tf

Neste arquivo, vamos colocar o seguinte bloco de código:

    output "lb_url" {
      description = "URL do Load Balancer"
      value       = "http://${aws_lb.app_elb.dns_name}/"
    }

Este código vai fazer com que, ao final da implantação, a URL da nossa aplicação seja imprimida no terminal. Desta forma, basta clicar e você será redirecionado para a sua aplicação funcionando na nuvem, com o uso de um Load Balancer.

Agora salve e feche o arquivo `outputs.tf`.

Para implementar toda a infraestrutura, inicie o Terraform com o provedor requerido. Dentro do diretório `terraform/`:

    terraform init

Com o provedor inicializado, podemos criar um "plano", isto é, uma forma de analisar todas as mudanças que serão implementadas na infraestrutura antes de executar na AWS. Neste "plano" ele demonstra tudo que será adicionado, alterado ou destruído na sua infraestrutura com um toque para facilitar a visualização:

I. to add --- trás um símbolo de adição (+) em verde para demostrar o que será criado.

II. to change --- trás um símbolo de til (~) em amarelo para demostrar mudança de estado do recurso criado.

III. to destroy --- trás um símbolo de subtração (-) em vermelho para demonstrar o que será excluído da infraestrutura.

Desta forma, é possível "debugar" erros de programação e analisar respostas de recursos a serem criados, antes de subir a estrutura para a AWS, bastando alterar os arquivos e recursos que desejar, salvar os documentos alterados e rodar o seguinte comando até ficar satisfeito com o "plano" de criação:

    terraform plan -out plano

Depois de analisar se é isso mesmo que deseja criar, é só utilizar o comando:

    terraform apply "plano"

O processo de implantação pode demorar alguns poucos minutos, mas quando finalizar, você deve ver a URL para sua aplicação impressa no terminal no formato:

    lb_url: http://DNS_SEU_APP/

Quando quiser finalizar toda a infraestrutura, apenas execute o comando:

    terraform destroy