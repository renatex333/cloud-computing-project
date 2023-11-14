resource "aws_db_instance" "main" {
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  db_name                 = var.db_name
  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  license_model           = "general-public-license"
  multi_az                = true
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "modusponnens"
  port                    = 3306
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = var.db_security_group_ids
  publicly_accessible     = false
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 7
  backup_window           = "07:00-09:00"
  maintenance_window      = "Tue:04:00-Tue:04:30"
}
