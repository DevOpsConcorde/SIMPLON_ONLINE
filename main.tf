provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

resource "aws_key_pair" "cle" {
  key_name   = "ma_cle"
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terraform_simplon" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.cle.key_name
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]
  user_data                   = <<-EOF
                                  #!/bin/bash
                                  # mise a jour et installer editeur
                                  sudo apt-get update -y
                                  sudo apt-get install -y vim nano
                                  sudo timedatectl set-timezone Europe/Paris



                                EOF

  tags = {
    Name = "VM-PFE-BACKUP"
  }
}
