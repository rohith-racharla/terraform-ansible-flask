variable "region" {
  type    = string
  default = "us-east-1"
}

variable "az" {
  type    = string
  default = "us-east-1a"
}

variable "myIP" {
  type      = string
  sensitive = true
}

variable "public_key" {
  type      = string
  sensitive = true
}

variable "instance_type" {
  type = string
}

variable "web_count" {
  type    = number
  default = 3
}
