resource "aws_security_group_rule" "ingress_ssh" {
  depends_on = [ aws_security_group.ci_cd_sg ]
  description = "Inbound access (SSH management)"

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]

  security_group_id = aws_security_group.ci_cd_sg.id
}

resource "aws_security_group_rule" "egress_all" {
  depends_on = [ aws_security_group.ci_cd_sg ]
  description = "Outbound access (internet, vpcs)."

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = [ "0.0.0.0/0" ]

  security_group_id = aws_security_group.ci_cd_sg.id
}

resource "aws_security_group" "ci_cd_sg" {
  name        = local.ci_cd_inst_base_name
  description = "CI CD access to this VPC resources"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(
    local.tags,
    { Name= local.ci_cd_inst_base_name }
  )
}

resource "aws_key_pair" "ci_cd_ssh_key" {
  key_name   = "${local.ci_cd_key_name}"
  public_key = local.ci_cd_ssh_public_key

  tags = merge(
    { Name="${local.ci_cd_inst_base_name}" },
    local.tags,
  )
}

data "aws_ami" "ci_cd_amis" {
  count = length(local.ci_cd_instances)

  # Ubuntu Canonical
  owners      = ["099720109477"]
  most_recent = true

  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }

  filter {
    name   = "name"
    values = local.ci_cd_instances[count.index].ami_values
  }
}

resource "aws_instance" "ci_cd_instances" {
  count = length(local.ci_cd_instances)

  key_name = aws_key_pair.ci_cd_ssh_key.key_name

  ami                    = data.aws_ami.ci_cd_amis[count.index].id
  instance_type          = local.ci_cd_instances[count.index].instance_type
  monitoring             = local.ci_cd_instances[count.index].monitoring

  network_interface {
      device_index          = 0
      network_interface_id  = aws_network_interface.ci_cd_interfaces[count.index].id
      delete_on_termination = false
    }

  dynamic "root_block_device" {
      for_each = local.ci_cd_instances[count.index].root_block_device
      content {
        delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
        encrypted             = lookup(root_block_device.value, "encrypted", null)
        iops                  = lookup(root_block_device.value, "iops", null)
        kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
        volume_size           = lookup(root_block_device.value, "volume_size", null)
        volume_type           = lookup(root_block_device.value, "volume_type", null)
        throughput            = lookup(root_block_device.value, "throughput", null)
        tags                  = merge({ Name="${local.ci_cd_inst_base_name}-${count.index + 1}" }, local.tags,)
      }
  }

  user_data = <<EOF
#!/bin/bash
apt-get update -y
apt-get install unzip git docker.io -y
EOF

  tags = merge(
    { Name="${local.ci_cd_inst_base_name}-${count.index + 1}" },
    local.tags,
  )
}

resource "aws_eip" "ci_cd_eips" {
  count = length(local.ci_cd_instances)

  vpc               = true
  network_interface = aws_network_interface.ci_cd_interfaces[count.index].id

  tags = merge(
    {
      Name="${local.ci_cd_inst_base_name}-${count.index + 1}"
    },
    local.tags,
  )
}

resource "aws_network_interface" "ci_cd_interfaces" {
  count = length(local.ci_cd_instances)

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[count.index]
  security_groups = [aws_security_group.ci_cd_sg.id]
  source_dest_check = local.ci_cd_instances[count.index].source_dest_check

  tags = merge(
    {
      Name="${local.ci_cd_inst_base_name}-${count.index + 1}"
    },
    local.tags,
  )
}