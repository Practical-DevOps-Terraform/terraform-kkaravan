terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.0"
    }
  }
}

provider "docker" {}

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

  provisioner "local-exec" {
    command = <<EOT
echo "<h1>My First and Lastname: Your First Lastname</h1>" > index.html
docker cp index.html ${self.name}:/usr/share/nginx/html/index.html
EOT
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
    external = 3307
  }
}
