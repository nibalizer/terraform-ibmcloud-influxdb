variable "ssh_key" {
}

locals {
  BASENAME = "nibz-influx"
  ZONE     = "us-south-1"
}

resource "ibm_is_vpc" "vpc" {
  name = "${local.BASENAME}-vpc"
}

resource "ibm_is_security_group" "sg1" {
  name = "${local.BASENAME}-sg1"
  vpc  = ibm_is_vpc.vpc.id
}

# allow all incoming network traffic on port 22
resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

# allow vms to crosstalk on influxdb ports 8088-8091
resource "ibm_is_security_group_rule" "crosstalk_ingress" {
  group     = ibm_is_security_group.sg1.id
  direction = "inbound"
  remote    = ibm_is_security_group.sg1.id

  tcp {
    port_min = 8088
    port_max = 8091
  }
}

# allow vms to talk out to whatever they want
# NOTE: consider restricting this
resource "ibm_is_security_group_rule" "egress_all_all" {
  group     = ibm_is_security_group.sg1.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_subnet" "subnet1" {
  name                     = "${local.BASENAME}-subnet1"
  vpc                      = ibm_is_vpc.vpc.id
  zone                     = local.ZONE
  total_ipv4_address_count = 256
}

data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

data "ibm_is_ssh_key" "ssh_key_id" {
  name = var.ssh_key
}

variable "data_instances" {
    description = "The number of data nodes to run"
} 

variable "instance_type" {
   description = "The IBM Gen 2 instance type. For example, bx2-4x16. `ibmcloud is instance-profiles` for more details"
   default = "bx2-2x8"
}

# data nodes

resource "ibm_is_volume" "data" {
  profile  = "10iops-tier"
  zone     = "us-south-1"
  #iops     = 10000
  capacity = 100
  name     = "influx-data-node-${count.index}"
  count    = var.data_instances
}

resource "ibm_is_instance" "data_node" {
  name    = "${local.BASENAME}-vsi1-${count.index}"
  vpc     = ibm_is_vpc.vpc.id
  zone    = local.ZONE
  keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
  image   = data.ibm_is_image.ubuntu.id
  profile = var.instance_type
  count   = var.data_instances

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet1.id
    security_groups = [ibm_is_security_group.sg1.id]
  }
  volumes = [ibm_is_volume.data.*.id[count.index]]
  user_data = templatefile("vm-user-data.conf", {})
}



resource "ibm_is_floating_ip" "fip1" {
  name   = "${local.BASENAME}-fip-${count.index}"
  target = ibm_is_instance.data_node[count.index].primary_network_interface[0].id
  count  = var.data_instances
}


output "sshcommand" {
  value = "ssh root@${ibm_is_floating_ip.fip1[0].address}"
}




# meta nodes
# TODO: fill these out the same as the data nodes above



# resource "ibm_is_instance" "meta_node" {
#  name    = "${local.BASENAME}-vsi1"
#  vpc     = ibm_is_vpc.vpc.id
#  zone    = local.ZONE
#  keys    = [data.ibm_is_ssh_key.ssh_key_id.id]
#  image   = data.ibm_is_image.ubuntu.id
#  profile = "cc1-2x4"
#  count   = "${var.data_instances}"
#
#  primary_network_interface {
#    subnet          = ibm_is_subnet.subnet1.id
#    security_groups = [ibm_is_security_group.sg1.id]
#  }
#}
