variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_admin_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "public_key" {
  type = string
}