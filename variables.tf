variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type        = string
  description = "Le block CIDR du vpc. /16 est recommandé"
}

variable "tags" {
  type        = map(string)
  description = "liste de tags pour les ressources"
  default = {
    Name  = "iaas-vpc"
    Owner = "JeremyKRZ"
  }
}

variable "env" {
  type        = string
  description = "env du vpc"
}

variable "vpc-name" {
  type        = string
  description = "nom du vpc"
}

variable "owner" {
  type        = string
  description = "propriétaire du vpc"
}

variable "zones" {
  type = map(string)
  description = "l'index correspond à la plage d'IP du sous-réseaux choisi"
  default = {
    "a" = 0,
    "b" = 1,
    "c" = 2,
  }
}

variable "eip_list"{
  type = list(string)
  description = ""
  default = [
    
  ]
}
