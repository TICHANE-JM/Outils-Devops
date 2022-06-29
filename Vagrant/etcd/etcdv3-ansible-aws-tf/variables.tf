variable "user_region" {
  type        = "string"
  description = "Région AWS à utiliser pour toutes les ressources"
}

variable "node_type" {
  type        = "string"
  description = "Type d'instance à utiliser, tel que t2.large"
}

variable "key_pair" {
  type        = "string"
  description = "Paire de clés SSH à utiliser pour accéder aux instances"
}
