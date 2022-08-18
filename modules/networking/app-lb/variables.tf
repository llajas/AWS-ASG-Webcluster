variable "vpc_cidr" {
  type        = string
  default     = "172.16.0.0/16"
  description = "default vpc_cidr_block"
}
variable "public_subnet1_cidr_block"{
   type        = string
   default     = "172.16.1.0/24"
}
variable "public_subnet2_cidr_block"{
   type        = string
   default     = "172.16.2.0/24"
}
variable "private_subnet1_cidr_block"{
   type        = string
   default     = "172.16.3.0/24"
}
variable "private_subnet2_cidr_block"{
   type        = string
   default     = "172.16.4.0/24"
}
variable "securitygroup_name"{
 type = string
 default = "app_lb_sg"
}
variable "securitygroup_description"{
 type = string
 default = "Security group for application load balancer"
}

variable "securitygroup_tagname"{
 type = string
 default = "Security group for application load balancer"
}

variable "webserver_securitygroup_name"{
 type = string
 default = "webserver_sg"
}

variable "webserver_securitygroup_description"{
 type = string
 default = "Security group for web server"
}

variable "webserver_securitygroup_tagname"{
 type = string
 default = "Security group for web server"
}