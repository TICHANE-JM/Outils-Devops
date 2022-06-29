# Créer un groupe de sécurité pour l'hôte bastion SSH
resource "aws_security_group" "bastion-sg" {
  vpc_id      = aws_vpc.velero-test-vpc.id
  name        = "bastion-sg"
  description = "Groupe de sécurité pour les hôtes bastion SSH"
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [aws_vpc.velero-test-vpc.cidr_block]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "bastion-sg"
    "tool" = "terraform"
    "demo" = "velero-capi-testing"
  }
}

# Créer un groupe de sécurité pour l'ELB pour le cluster de gestion A
resource "aws_security_group" "mgmt-a-elb-sg" {
  vpc_id      = aws_vpc.velero-test-vpc.id
  name        = "mgmt-a-elb-sg"
  description = "Groupe de sécurité ELB pour le cluster de gestion A"
  ingress {
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"                         = "mgmt-a-elb-sg"
    "tool"                         = "terraform"
    "demo"                         = "velero-capi-testing"
    "kubernetes.io/cluster/mgmt-a" = "shared"
  }
}

# Créer un groupe de sécurité pour l'ELB pour le cluster de gestion B
resource "aws_security_group" "mgmt-b-elb-sg" {
  vpc_id      = aws_vpc.velero-test-vpc.id
  name        = "mgmt-b-elb-sg"
  description = "Groupe de sécurité ELB pour le cluster de gestion B"
  ingress {
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "6443"
    to_port     = "6443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"                         = "mgmt-b-elb-sg"
    "tool"                         = "terraform"
    "demo"                         = "velero-capi-testing"
    "kubernetes.io/cluster/mgmt-b" = "shared"
  }
}

# Créer un groupe de sécurité pour les nœuds du plan de contrôle
resource "aws_security_group" "controlplane-sg" {
  vpc_id      = aws_vpc.velero-test-vpc.id
  name        = "controlplane-sg"
  description = "Groupe de sécurité pour les nœuds du plan de contrôle K8s"
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [aws_vpc.velero-test-vpc.cidr_block]
  }
  ingress {
    from_port       = "6443"
    to_port         = "6443"
    protocol        = "tcp"
    security_groups = [aws_security_group.mgmt-a-elb-sg.id, aws_security_group.mgmt-b-elb-sg.id]
  }
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"                         = "controlplane-sg"
    "tool"                         = "terraform"
    "demo"                         = "velero-capi-testing"
    "kubernetes.io/cluster/mgmt-a" = "shared"
    "kubernetes.io/cluster/mgmt-b" = "shared"
  }
}

# Créer un groupe de sécurité pour les nœuds de travail K8s
resource "aws_security_group" "worker-sg" {
  vpc_id      = aws_vpc.velero-test-vpc.id
  name        = "worker-sg"
  description = "Groupe de sécurité pour les nœuds de travail K8"
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [aws_vpc.velero-test-vpc.cidr_block]
  }
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion-sg.id]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name"                         = "worker-sg"
    "tool"                         = "terraform"
    "demo"                         = "velero-capi-testing"
    "kubernetes.io/cluster/mgmt-a" = "shared"
    "kubernetes.io/cluster/mgmt-b" = "shared"
  }
}
