
resource "aws_instance" "consul_server" {

  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.opsschool_consul_key.key_name
  subnet_id                   = "subnet-0a6e0daf69de7b73b"
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name

  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]
  user_data            = "/home/ubuntu/consul-server.sh"

  provisioner "file" {
    source      = "scripts/consul-server.sh"
    destination = "/home/ubuntu/consul-server.sh"
    connection {   
      host        = self.private_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)      
    }   
  }

  tags = {
    Name = "opsschool-server"
    consul_server = "true"
  }

}

resource "aws_instance" "consul_agent" {

  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.opsschool_consul_key.key_name
  subnet_id                   = "subnet-0a6e0daf69de7b73b"
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]
  user_data            = "/home/ubuntu/consul-agent.sh"  
  provisioner "file" {
    source      = "scripts/consul-agent.sh"
    destination = "/home/ubuntu/consul-agent.sh"

    connection {   
      host        = self.private_ip
      user        = "ubuntu"
      private_key = file(var.pem_key_name)      
    }   
  }


  tags = {
    Name = "opsschool-agent"
  }


}

output "server" {
  value = aws_instance.consul_server.private_ip
}

output "agent" {
  value = aws_instance.consul_agent.private_ip
}
 
