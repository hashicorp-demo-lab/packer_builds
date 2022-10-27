packer {
  required_plugins {
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "subscription_id" {
  type    = string
  default = "4dbaeeb5e-5272-4590-89ae-1e5db83ae010"
}

variable "resource_group_name" {
  type    = string
  default = "acmedemo"
}

variable "tenant_id" {
  type    = string
  default = "788d8595-3c0f-4d77-beda-ca1bb0715ede"
}

variable "storage_account" {
  type    = string
  default = "acmedemo"
}

#set via env export PKR_VAR_client_id
variable "client_id" {
  type      = string
  sensitive = true
}

#set via env export PKR_VAR_client_secret
variable "client_secret" {
  type      = string
  sensitive = true
}


source "azure-arm" "basic-example" {
  resource_group_name = var.resource_group_name
  storage_account     = var.storage_account

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

  capture_container_name = "images"
  capture_name_prefix    = "packer"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "14.04.4-LTS"

  azure_tags = {
    dept = "acme"
  }

  location = "Australia East"
  vm_size  = "Standard_B1s"
}


build {
  hcp_packer_registry {
    bucket_name = "ubuntu-nginx"
    description = <<EOT
Some nice description about the image being published to HCP Packer Registry.
    EOT
    bucket_labels = {
      "owner"          = "app-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "Focal 20.04",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }
  sources = [
    "sources.azure-arm.basic-example",
  ]

  provisioner "shell" {
    inline = [
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"

    ]
  }
}