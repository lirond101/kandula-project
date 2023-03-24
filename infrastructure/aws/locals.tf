locals {
  common_tags = {
    company = var.company
    project = "${var.company}-${var.project}"
  }

  name_prefix = "${var.naming_prefix}-${var.env_name}"
}