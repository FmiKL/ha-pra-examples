data "docker_image" "app" {
  name = var.app_image
}

data "docker_network" "public" {
  name = "${var.project_name}-public"
}

# Images partagées avec Compose, conservées au destroy.
resource "docker_image" "mysql" {
  name         = "mysql:8.4"
  keep_locally = true
}

resource "docker_image" "haproxy" {
  name         = "haproxy:3.2-alpine"
  keep_locally = true
}

resource "docker_network" "scaleway" {
  name     = "${var.project_name}-scaleway"
  internal = true
}

resource "docker_volume" "mysql" {
  name = "${var.project_name}-scaleway-mysql"
}

resource "docker_container" "db" {
  name  = "${var.project_name}-scaleway-db"
  image = docker_image.mysql.image_id

  env = [
    "MYSQL_DATABASE=app",
    "MYSQL_USER=app",
    "MYSQL_PASSWORD=local-demo-password",
    "MYSQL_ROOT_PASSWORD=local-root-password",
  ]

  networks_advanced {
    name    = docker_network.scaleway.name
    aliases = ["db"]
  }

  volumes {
    volume_name    = docker_volume.mysql.name
    container_path = "/var/lib/mysql"
  }

  volumes {
    host_path      = abspath("${path.module}/../../../../app/schema.sql")
    container_path = "/docker-entrypoint-initdb.d/schema.sql"
    read_only      = true
  }

  healthcheck {
    test         = ["CMD-SHELL", "MYSQL_PWD=\"$MYSQL_PASSWORD\" mysql --protocol=TCP -h 127.0.0.1 -u \"$MYSQL_USER\" \"$MYSQL_DATABASE\" -e 'SELECT 1'"]
    interval     = "3s"
    timeout      = "5s"
    retries      = 30
    start_period = "20s"
  }

  wait         = true
  wait_timeout = 120
}

resource "docker_container" "app" {
  count = 2
  name  = "${var.project_name}-scaleway-app-${count.index + 1}"
  image = data.docker_image.app.id

  env = [
    "APP_ENV=scaleway",
    "DB_HOST=db",
    "DB_NAME=app",
    "DB_USER=app",
    "DB_PASSWORD=local-demo-password",
  ]

  # Permet aux scripts de retrouver les instances.
  labels {
    label = "seasonal-ha-pra.app"
    value = "${var.project_name}-scaleway"
  }

  networks_advanced {
    name    = docker_network.scaleway.name
    aliases = ["scaleway-app"]
  }

  healthcheck {
    test     = ["CMD", "php", "-r", "exit(@file_get_contents('http://127.0.0.1/health') === false ? 1 : 0);"]
    interval = "5s"
    timeout  = "5s"
    retries  = 10
  }

  wait       = true
  depends_on = [docker_container.db]
}

resource "docker_container" "lb" {
  name  = "${var.project_name}-scaleway-lb"
  image = docker_image.haproxy.image_id

  networks_advanced {
    name = docker_network.scaleway.name
  }

  networks_advanced {
    name    = data.docker_network.public.name
    aliases = ["scaleway"]
  }

  ports {
    internal = 80
    external = var.lb_port
    ip       = "127.0.0.1"
  }

  volumes {
    host_path      = abspath("${path.module}/../../docker/haproxy.cfg")
    container_path = "/usr/local/etc/haproxy/haproxy.cfg"
    read_only      = true
  }

  healthcheck {
    test     = ["CMD", "wget", "-q", "-O", "/dev/null", "http://127.0.0.1/health"]
    interval = "5s"
    timeout  = "5s"
    retries  = 10
  }

  wait       = true
  depends_on = [docker_container.app]
}
