data "aws_caller_identity" "current" {}

variable "aws_region" {}

provider "aws" {
  version = "~> 1.32"
  region     = "${var.aws_region}"
}

# "${var.tags["Environment"]}-consul-as"
variable "tags" {
  type        = "map"
  description = "A map of tags to assign to these services"

  default = {
    Agileteam    = "ma"
    Environment  = "prod"
    Project      = "survey-moviesanywhere"
    Product_name = "survey-moviesanywhere"
  }
}

terraform {
  backend "s3" {
    bucket = "twds-ma-tfstate"
    key    = "state/tf/survey-moviesanywhere/environment/prod/terraform.tfstate"
    region = "us-west-2"
  }
}

#
# MySQL Database
# 

variable "subnet_ids" {
  description = "List of Subnet IDs used DB parameters"
  type = "list"
}

variable "db_identifier" {
  default = "survey-moviesanywhere"
}

variable "db_name" {
  default = "survey_moviesanywhere_db"
}

variable "db_username" {
  default = "studiosadmin"
}

variable "db_password" {
  default = "xxxx1234"
}

variable "skip_final_snapshot" {
  default = false
}

resource "aws_db_subnet_group" "default" {
  name       = "${var.db_name}"
  subnet_ids = "${var.subnet_ids}"

  tags = "${var.tags}"
}

resource "aws_db_instance" "default" {
  identifier           = "${var.db_identifier}"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = "${var.db_name}"
  username             = "${var.db_username}"
  password             = "${var.db_password}"

  apply_immediately    = true
  backup_retention_period = 7
  skip_final_snapshot  = "${var.skip_final_snapshot}"
  storage_encrypted    = false
  db_subnet_group_name = "${aws_db_subnet_group.default.name}"
  tags                 = "${var.tags}"
}

#
# DNS
# 

data "aws_route53_zone" "main" {
  name = "moviesanywhere.com."
}

resource "aws_route53_record" "main" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "survey.moviesanywhere.com"
  type    = "A"

  alias {
      name                   = "dualstack.a0617f01d062a11e8b79f0a894162e6a-66993500.us-west-2.elb.amazonaws.com."
      zone_id                = "Z1H1FL5HABSF5"
      evaluate_target_health = false
    }
}