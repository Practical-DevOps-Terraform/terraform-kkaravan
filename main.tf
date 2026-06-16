terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

variable "db_root_password" {
  type = string
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "mariadb" {
  name = "mariadb:latest"
}

resource "docker_container" "nginx" {
  name  = "nginx-container"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = 8080
  }

  volumes {
    host_path      = "${path.module}/index.html"
    container_path = "/usr/share/nginx/html/index.html"
  }
}

resource "docker_container" "mariadb" {
  name  = "mariadb-container"
  image = docker_image.mariadb.image_id

  env = [
    "MYSQL_ROOT_PASSWORD=${var.db_root_password}"
  ]

  ports {
    internal = 3306
    external = 3306
  }

  healthcheck {
    test     = ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-p${var.db_root_password}"]
    interval = "5s"
    timeout  = "3s"
    retries  = 20
  }
}
