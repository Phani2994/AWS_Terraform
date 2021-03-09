# output "aws_ami_id" {
#   value = data.aws_ami.latest-amazon-linux-image
# }

# output "ec2_public_ip" {
#   value = aws_instance.app_server.public_ip
# }

output "ec2_public_ip" {
  value = module.app_server.instance.public_ip
}
