variable "keypair" {
  type        = string
  description = "SSH keypair to use to connect to instances"
}

variable "cp_instance_type" {
  type        = string
  description = "Type AWS à utiliser lors de la création d'instances de gestionnaire"
  default     = "t2.medium"
}

variable "wkr_instance_type" {
  type        = string
  description = "Type AWS à utiliser lors de la création d'instances de travail"
  default     = "t2.large"
}

variable "bastion_instance_type" {
  type        = string
  description = "Type AWS à utiliser lors de la création d'instances bastion SSH"
  default     = "t2.small"
}

variable "user_region" {
  type        = string
  description = "Région AWS à utiliser pour les nouvelles ressources"
}

variable "num_wkr_nodes" {
  type        = number
  description = "Nombre de noeuds worker à créer"
  default     = 1
}

variable "base_cidr" {
  type        = string
  description = "CIDR de base pour l'infrastructure"
}
