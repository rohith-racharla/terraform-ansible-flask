resource "aws_key_pair" "sshkeypair" {
  key_name   = "sshkey"
  public_key = var.public_key
}
