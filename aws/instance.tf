resource "aws_instance" "example_server" {
  ami           = "ami-0faab6bdbac9486fb"
  instance_type = "t2.micro"
  key_name      = "aws-key"
  subnet_id     = aws_subnet.public-subnet-01.id
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOL
  #!/bin/bash -xe
  apt update
  apt install apache2 -y
  EOL

  tags = {
    Name = "TestVM"
  }
}
