locals {
  common_tags = {
    managed_by = "terraform"
    app = "kandasoft-website"
  }
  db_name = "kanda"
  db_user = "kanda"
  db_password = "Pa55w0rd"
}
