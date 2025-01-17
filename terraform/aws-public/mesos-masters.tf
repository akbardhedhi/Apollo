resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.key_file)}"
}

/* Base packer build we use for provisioning master instances */
resource "atlas_artifact" "mesos-master" {
  name    = "${var.atlas_artifact.master}"
  type    = "aws.ami"
  version = "${var.atlas_artifact_version.master}"
}

/* Mesos master instances */
resource "aws_instance" "mesos-master" {
  instance_type     = "${var.instance_type.master}"
  ami               = "${replace(atlas_artifact.mesos-master.id, concat(var.region, ":"), "")}"
  count             = "${var.masters}"
  key_name          = "${aws_key_pair.deployer.key_name}"
  subnet_id         = "${aws_subnet.public.id}"
  source_dest_check = false
  security_groups   = ["${aws_security_group.default.id}"]
  tags = {
    Name = "apollo-mesos-master-${count.index}"
    role = "mesos_masters"
  }
}
