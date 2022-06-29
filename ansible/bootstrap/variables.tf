variable "key_pair" {
    type                    = "string"
    description             = "Paire de clés SSH à utiliser pour se connecter aux instances"
}

variable "dest_vpc" {
    type                    = "string"
    description             = "ID de VPC pour les instances lancées"
}

variable "sec_grp" {
    type                    = "string"
    description             = "ID de groupe de sécurité pour le groupe à appliquer aux instances"
}

variable "user_region" {
    type                    = "string"
    description             = "Région AWS à utiliser pour les nouvelles ressources"
}

variable "dest_subnet" {
    type                    = "string"
    description             = "ID de sous-réseau pour les instances lancées"
}

variable "instance_type" {
    type                    = "string"
    description             = "Type à utiliser pour les instances lancées"
}
