# Projeto de Computação em Nuvem - 2023.2

Projeto de implementação de um ALB entre instâncias EC2 com Auto Scaling e Banco de dados RDS

**Por: Renato Laffranchi Falcão**

## Objetivo de Implementação

![diagrama de arquitetura](img/arquitetura-cloud.png)

1. Infraestrutura como Código (IaC) com Terraform.
2. Application Load Balancer (ALB).
3. EC2 com Auto Scaling.
4. Banco de Dados RDS.
5. Aplicação.
6. Análise de Custo com a Calculadora AWS.
7. Documentação.

### Detalhamento técnico

O projeto foi desenvolvido em Terraform, uma ferramenta de desenvolvimento de infraestrutura como código (IaC), que gerencia instâncias e serviços de diversos provedores, como a AWS. O diretório do projeto está estruturado da seguinte forma:

    .
    ├── project/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── modules/
    │       ├── alb_listener/
    │       ├── alb_target_group/
    │       ├── application_load_balancer/
    │       ├── auto_scaling_group/
    │       ├── auto_scaling_policy/
    │       ├── cloud_watch_alarm/
    │       ├── internet_gateway/
    │       ├── launch_template/
    │       ├── placement_group/
    │       ├── relational_database/
    │       ├── route_table/
    │       ├── s3_bucket/
    │       ├── security_group/
    │       ├── subnet_group/
    │       ├── subnet_route_table_association/
    │       ├── subnets/
    │       └── vpc/
    ├── docs/
    │   └── estimativa-de-custos.pdf
    ├── img/
    │   └── arquitetura-cloud.png
    └── deploy.sh

Nesta estrutura de diretórios, todo o código de Terraform está dentro de da pasta `project/`. O arquivo `main.tf` deste diretório contém a conexão principal entre os recursos da AWS, sendo responsável pelo deploy de toda a infraestrutura. Já o arquivo `outputs.tf` é responsável por exibir os usuário o URL para acessar a aplicação através do browser. 

Dentro deste diretório também é possível encontrar a pasta `modules/`, que guarda todos os recursos necessários para fazer o deploy da aplicação, separados por componente. Esta forma de organização em módulos é muito eficiente para abstrair certos detalhes dos recursos, bem como permitir a sua reutilização. Desta forma, todos os módulos são utilizados pelo programa principal, de forma que os argumentos passados para os módulos permitem uma maneira facilitada de conectar os recursos, além de deixar o código mais fácil de ser atualizado e mantido.

Aqui estão alguns detalhes técnicos importantes acerca do código Terraform fornecido:

1. **Configuração de Subnets**: O código define duas subnets públicas e duas privadas, cada uma em zonas de disponibilidade diferentes. Isso não apenas distribui a carga e melhora a resiliência, mas também permite a segregação de tráfego entre recursos públicos e privados, como instâncias de banco de dados e servidores web.

1. **Security Groups e Regras**: Os security groups são configurados para diferentes recursos, como instâncias, load balancers e bancos de dados. As regras definidas permitem tráfego específico (por exemplo, HTTP, SSH, MySQL) de/para blocos de endereços IP definidos, garantindo que apenas o tráfego necessário e seguro seja permitido, o que é fundamental para a segurança da rede.

1. **Gerenciamento de Credenciais do Banco de Dados**: O username e password do banco de dados são gerenciados através de variáveis, o que sugere um método seguro e centralizado de gerenciamento de credenciais, essencial para a segurança e manutenção do banco de dados.

1. **Escolha da Imagem Django para o Launch Template**: A AMI selecionada é específica para Django (Bitnami com Linux Debian 11 - x86-64), o que indica uma configuração otimizada e pronta para uso com aplicações Django, garantindo eficiência e estabilidade. Além disso, a imagem escolhida recebe atualizações regulares, sempre garantindo a última versão estável de todos os componentes.

1. **Auto Scaling Group**: A configuração de um grupo de auto scaling para gerenciar a escalabilidade das instâncias EC2 de forma dinâmica, em resposta a mudanças na demanda ou performance. Mais específicamente, esta escalabilidade é dada pela alta utilização de CPU, que é monitorada através de um alarme CloudWatch.

1. **Balanceamento de Carga (ALB)**: Implementação de um Application Load Balancer, que ajuda a distribuir o tráfego de entrada para melhorar a disponibilidade e a robustez da aplicação.

1. **Monitoramento e Alertas com CloudWatch**: A criação de um alarme CloudWatch para monitorar a utilização de CPU e acionar políticas de auto scaling, garantindo uma gestão eficiente dos recursos.

1. **Armazenamento S3**: A utilização de um bucket S3 para armazenamento de objetos, provendo um meio eficaz e seguro para armazenar e acessar dados. Neste caso, o bucket é utilizado para armazenar o estado do Terraform.

Esses componentes, juntos, formam uma infraestrutura robusta e escalável na AWS, ideal para suportar aplicações web modernas com requisitos complexos de rede, segurança e desempenho.

### Deploy da infraestrutura

Antes de realizar o deploy, é necessário instalar o Terraform. Para tanto, basta seguir o [tutorial de instalação do Terraform](https://developer.hashicorp.com/terraform/downloads) de acordo com o sistema operacional. Além do Terraform, também é preciso instalar a [CLI da AWS](https://aws.amazon.com/pt/cli/) de acordo com o sistema operacional. 

Com ambas dependências instaladas, deve-se configurar as credencias da AWS para que o Terraform realize todo o gerenciamento por conta própria. Uma das maneiras mais seguras de gerenciar as credenciais de desenvolvimento da AWS, para evitar vazamento das mesmas, é configurar as credenciais como variáveis de ambiente no computador, de forma que elas não são compartilhadas. Utilizando o comando:

    aws configure

- `AWS Access Key ID` e `AWS Secret Access Key ID`: O **ID** e a **chave de acesso** gerados no console da AWS, na aba *"Credenciais de Segurança"*.
- `Default region name`: A região padrão para se implantar serviços e instâncias. Pode ser deixado em branco, mas a região que estará sendo utilizada é a **us-west-2**.
- `Default output format`: O formato de saída padrão das respostas recebidas. Pode ser deixado em braco.

Por fim, execute o seguinte comando no diretório raiz deste repositório:

- Linux

        ./deploy.sh

> [!IMPORTANTE]  
> Os scripts `deploy.sh` e `destroy.sh` funcionam apenas em sistemas operacionais Linux.

Ao executar o comando, é necessário definir duas variáveis:

- `Database Username` e `Database Password`: O usuário e a senha, respectivamente, para acesso ao banco de dados.

Agora é só fazer um chá enquanto aguarda o deploy da infraestrutura finalizar... :tea:

Quando finalizar, a URL para teste do funcionamento da aplicação será exibido no terminal.

### Encerramento da infraestrutura

Quando desejar finalizar a infraestrutura, liberando todos os recursos alocados, basta executar o seguinte comando:

- Linux

        ./destroy.sh

## Análise de custos

O relatório detalhado sobre a estimativa de custos, elaborado com o suporte da calculadora oficial de preços da Amazon Web Services (AWS), está disponível no arquivo `docs/estimativa-de-custos.pdf`.

A proposta visa implantar a infraestrutura na região **us-west-2** da AWS, uma decisão estratégica que equilibra custo e desempenho. Esta região não só oferece preços competitivos, mas também assegura baixa latência, essencial para uma experiência de usuário ágil e um serviço eficiente.

Uma análise geral indica que o custo mensal estimado é de aproximadamente *$65,39 USD*. Este valor é composto pelos seguintes custos principais, discriminados por recurso:

- Instâncias (EC2):
    - Transferência de dados: *$11,00 USD*
- Nuvem privada (VPC):
    - Transferência de dados: *$11,00 USD*
- Balanceador de carga (ALB):
    - Instância do ALB: *$16,43 USD*

É possível notar que os preços de transferência de dados, seja intrarregional ou para a internet, é o fator que mais agrega custo. Para esta estimativa, foi considerado um tráfego de 100 GB por mês transitando intrarregionalmente (isto é, dados que transitam entre a instância e o banco de dados) e 100 GB por mês transitando para fora da VPC (isto é, para a internet, como respostas para os clientes).

O valor para o tráfego de dados foi escolhido arbitrariamente, mas revela que o cuidado no desenvolvimento da aplicação é de extrema importância para se reduzir os custos operacionais de uma infraestrutura em nuvem. Desta forma, a principal otimização que deve ser considerada é a melhoria contínua da eficiência na transmissão de dados pela aplicação. Entre as otimizações que podem ser implementadas estão:

- **Compressão de Dados**: Reduzindo o tamanho dos dados transmitidos, o que diminui a largura de banda necessária.
- **Caching Inteligente**: Armazenando dados localmente para evitar transmissões repetitivas.
- **Uso de Protocolos de Comunicação Eficientes**: Selecionando protocolos que otimizam a transmissão de dados.
- **Otimização de Consultas de Banco de Dados**: Garantindo que as consultas sejam eficientes e consumam menos recursos.

Essas medidas, ao serem implementadas, não apenas diminuem os custos operacionais associados ao tráfego de dados, mas também melhoram a velocidade e a responsividade da aplicação para os usuários.

Outro ponto de atenção no cenário atual, no qual a aplicação de teste está em execução na AWS, é o uso de instâncias EC2 de menor custo, adequadas para a baixa demanda de recursos computacionais. No entanto, ao transitar para uma aplicação em ambiente de produção, espera-se um aumento significativo nos requisitos de recursos computacionais. Isso implicará na necessidade de instâncias EC2 mais avançadas, capazes de suportar cargas de trabalho mais intensas. Essa mudança acarretará um aumento notável nos custos associados às instâncias EC2. Portanto, é crucial considerar a escalabilidade dos custos com infraestrutura mais robusta no planejamento orçamentário, tendo em vista que o crescimento na demanda e no desempenho da aplicação tende a elevar proporcionalmente os custos operacionais.

## Referências

AWS Architecture Blog. (2021). [What to Consider when Selecting a Region for your Workloads](https://aws.amazon.com/pt/blogs/architecture/what-to-consider-when-selecting-a-region-for-your-workloads/).

HashiCorp Terraform Registry. (2023). [AWS provider documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

HashiCorp. (2023). [Terraform documentation](https://developer.hashicorp.com/terraform).

Amazon AWS. (2023). [AWS pricing calculator](https://calculator.aws/#/).

