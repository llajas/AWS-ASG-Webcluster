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

variable "keyname"{
#   default = "ASSESSMENT_PUBLIC_KEY"
  description = "Please enter the appropriate keypair from your AWS account to have the SSH key added to instances for SSH management"
}
variable "region" {
  type        = string
#   default     = "us-east-1"
  description = "Please enter the region in which you would like to deploy (ie. 'us-east-1' or 'us-east-2')"
}

variable "securitygroup_name"{
 type = string
 default = "app_lb_sg"
}

variable "cluster_name"{
 type = string
 default = "assessment-cluster"
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