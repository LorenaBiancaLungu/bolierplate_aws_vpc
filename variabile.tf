#AWS region
variable "region" {
type = string
description = "Region"
default = "us-east-1"
}

#AWS VPC
variable "vpc-ceb03" {
type = string
description = "VPC"
default = "vpc-ceb03"
}

#AWS public subnet
variable "public_subnet" {
type = number
description = "public_subnet"
default = "pub-subnet03"
}
   
variable "privat_subnet" {
type = number
description = "privat_subnet"
default = "priv-subnet03"
}

#AWS private subnet
#Tag
variable "tag_createdby" {
type = string
description = "Your Full Name"
default = "Lorena Lungu"
}

#VPC Ciddr
variable "vpc_ciddr" {
type = string
description = "VPC CIDDR block"
}
