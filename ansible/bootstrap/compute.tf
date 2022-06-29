# Lancer une instance pour servir de cible pour le playbook Ansible
resource "aws_instance" "xenial" {
    ami                     = "${data.aws_ami.xenial_ami.id}"
    instance_type           = "${var.instance_type}"
    key_name                = "${var.key_pair}"
    vpc_security_group_ids  = ["${var.sec_grp}"]
    subnet_id               = "${var.dest_subnet}"
    tags {
        Name                = "xenial"
        demo                = "ansible-bootstrap"
        owner               = "Tichane JM"
        tool                = "terraform"
    }
}
