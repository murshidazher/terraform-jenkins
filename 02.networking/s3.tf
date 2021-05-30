resource "aws_s3_bucket" "my_bucket" {
  bucket = var.my_app_s3_bucket
  acl    = "private"
  region = var.region
  tags = {
    Name        = "javahome-app-de"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_s3_bucket" "alb_access_logs" {
  bucket = var.access_logs_bucket
  policy = data.template_file.javahome.rendered
  acl    = "private"
  region = var.region
  tags = {
    Name        = "jalb-access-logs"
    Environment = "${terraform.workspace}"
  }
}
