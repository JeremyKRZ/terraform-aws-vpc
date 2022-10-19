variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block"{
  type = string
  description = "Le block CIDR du vpc. /16 est recommandé"
}

variable "tags" {
  type = map(string)
  description = "liste de tags pour les ressources"
  default = {
    Name = "iaas-vpc"
    Owner = "JeremyKRZ"
  }
}

variable "env"{
    type = string
    description = "env du vpc"
}

variable "vpc-name"{
    type = string
    description = "nom du vpc"
}

variable "owner"{
    type = string
    description = "propriétaire du vpc"
}
