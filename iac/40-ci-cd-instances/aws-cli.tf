resource "null_resource" "install_awscli" {
  count = length(local.ci_cd_instances)

  depends_on = [aws_instance.ci_cd_instances]

  connection {
    user        = "ubuntu"
    private_key = replace("${var.ci_cd_ssh_private_key}", "\\n", "\n")
    host        = aws_eip.ci_cd_eips[count.index].public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo '1) Waiting for user data script to finish:'",
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo -e 'Checking cloud-init...'; sleep 5; done",
      "echo 'User data script finished.'",
      "echo '2) Starting aws cli download and install...'",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",
      "sudo rm awscliv2.zip",
      "mkdir -p .aws",
    ]
  }
}

resource "null_resource" "configure_awscli" {
  count = length(local.ci_cd_instances)

  depends_on = [
    aws_instance.ci_cd_instances,
    null_resource.install_awscli
  ]

  connection {
    user        = "ubuntu"
    private_key = replace("${var.ci_cd_ssh_private_key}", "\\n", "\n")
    host        = aws_eip.ci_cd_eips[count.index].public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo \"[default]\nregion=${var.aws_region}\noutput=json\" > .aws/config",
      "echo \"[default]\naws_access_key_id=${var.CI_CD_AWS_ACCESS_KEY_ID}\naws_secret_access_key=${var.CI_CD_AWS_SECRET_ACCESS_KEY}\" > .aws/credentials",
      "chmod 400 .aws/credentials",
    ]
  }
}