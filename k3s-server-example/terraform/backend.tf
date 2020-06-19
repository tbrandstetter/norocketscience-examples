terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "your chosen organization name"

    workspaces {
      prefix = "k3s-infrastructure"
    }
  }
}