variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "allowed_admin_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "public_key" {
  type = string
}