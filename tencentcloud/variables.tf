variable "sg_name" {
  default = "tc_sg"
}

variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "vpc_name" {
  default = "tc_vpc"
}

variable "subnet_cidr" {
  default = "10.1.0.0/26"
}

variable "subnet_name" {
  default = "tc_subnet"
}

//target_region is the region cvm instance belongs to
variable "target_region" {
  default = "ap-shanghai"
}

variable "availability_zone" {
  default = "ap-shanghai-3"
}

variable "instance_name"{
  default = "tc_instance"
}

variable "project_id"{
  default = 0
}

variable "clb_name" {
  default = "tc_clb"
}

variable "listener_name" {
  default = "tc_listener_https"
}

variable "listener_port" {
  default = 80
}

variable "rule_name" {
  default = "tc_rule_name"
}

variable "rule_domain" {
  default = "abc.com"
}

variable "rule_url" {
  default = "/"
}

variable "targetA_port" {
  default = 80
}

variable "targetA_weight" {
  default = 10
}

variable "targetB_port" {
  default = 22
}

variable "targetB_weight" {
  default = 10
}