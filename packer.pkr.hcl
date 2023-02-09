packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


variable "ami_prefix" {
  type    = string
  default = "test"
}

variable "ansible_host" {
  type    = string
  default = "default"
}

variable "ansible_connection" {
  type    = string
  default = "docker"
}



locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-base-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "ap-northeast-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-bionic-18.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "setup.yml"
    extra_arguments = [
      "-vvvv",
      "--extra-vars",
      "ansible_host=${var.ansible_host} ansible_connection=${var.ansible_connection}"
    ]
  }
}
