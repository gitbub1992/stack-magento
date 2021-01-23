terraform {
  required_providers {
    tencentcloud = {
      source = "tencentcloudstack/tencentcloud"
      version = "1.53.0"
    }
  }
}


#create a new security group
provider "tencentcloud" {
  region     = "ap-shanghai"
}

resource "tencentcloud_security_group" "sg" {
  name = var.sg_name
}

#create new vpc and subnet
resource "tencentcloud_vpc" "vpc" {
  name       = var.vpc_name
  cidr_block = var.vpc_cidr
}

resource "tencentcloud_subnet" "subnet" {
  name              = var.subnet_name
  availability_zone = var.availability_zone
  vpc_id            = tencentcloud_vpc.vpc.id
  cidr_block        = var.subnet_cidr
  is_multicast      = false
}

#create two new cvm instances
data "tencentcloud_images" "my_favorate_image" {
  image_type = ["PUBLIC_IMAGE"]
  os_name    = "centos"
}

data "tencentcloud_instance_types" "my_favorate_instance_types" {
  filter {
    name   = "instance-family"
    values = ["S5"]
  }

  cpu_core_count = 1
  memory_size    = 2
}

resource "tencentcloud_instance" "instance" {
  instance_name     = var.instance_name
  availability_zone = var.availability_zone
  image_id          = data.tencentcloud_images.my_favorate_image.images.0.image_id
  instance_type     = data.tencentcloud_instance_types.my_favorate_instance_types.instance_types.0.instance_type
  project_id = var.project_id
  vpc_id = tencentcloud_vpc.vpc.id
  subnet_id = tencentcloud_subnet.subnet.id
  system_disk_type  = "CLOUD_PREMIUM"

  disable_monitor_service    = true
  internet_max_bandwidth_out = 2
  count                      = 2
}


#create an OPEN postpaid CLB instance
resource "tencentcloud_clb_instance" "clb" {
  clb_name                  = var.clb_name
  network_type              = "OPEN"
  project_id                = var.project_id
  vpc_id                    = tencentcloud_vpc.vpc.id
  target_region_info_region = var.target_region
  target_region_info_vpc_id = tencentcloud_vpc.vpc.id
  security_groups           = [tencentcloud_security_group.sg.id]
}

#create an HTTP clb listener
resource "tencentcloud_clb_listener" "listener" {
  clb_id               = tencentcloud_clb_instance.clb.id
  listener_name        = var.listener_name
  port                 = var.listener_port
  protocol             = "HTTP"

}

#create clb https rule with scheduler WRR
resource "tencentcloud_clb_listener_rule" "rule" {
  clb_id              = tencentcloud_clb_instance.clb.id
  listener_id         = tencentcloud_clb_listener.listener.listener_id
  domain              = var.rule_domain
  url                 = var.rule_url
  session_expire_time = 30
  scheduler           = "WRR"
}

#create clb binding two instances relationship
resource "tencentcloud_clb_attachment" "attachment" {
  clb_id      = tencentcloud_clb_instance.clb.id
  listener_id = tencentcloud_clb_listener.listener.listener_id
  rule_id     = tencentcloud_clb_listener_rule.rule.rule_id

  targets {
    instance_id = tencentcloud_instance.instance.0.id
    port        = var.targetA_port
    weight      = var.targetA_weight
  }
  targets {
    instance_id = tencentcloud_instance.instance.1.id
    port        = var.targetB_port
    weight      = var.targetB_weight
  }
}