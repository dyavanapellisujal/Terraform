provider "aws" {
   region     = "ap-south-1"
   #run aws configure to set credentials (or hardcode - not recommended)
}

resource "aws_instance" "testserver" {

    ami = "ami-0e35ddab05955cf57"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mykey.key_name
    vpc_security_group_ids = [aws_security_group.main.id]

  user_data = <<-EOF
      #!/bin/sh
      sudo apt-get update
      sudo apt install -y apache2
      sudo systemctl status apache2
      sudo systemctl start apache2
      sudo chown -R $USER:$USER /var/www/html
      sudo echo "<html><body><h1>This is sujals page</h1></body></html>" > /var/www/html/index.html
      EOF
}

resource "aws_key_pair" "mykey" {
  key_name   = "my-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSioVaLOfQ3Lf+igTNAP3/TrbEFXuhwYA8JSIkDsK26QMFteiH12ozuchVhTPUB+ostXgDvIfu0K0ckz/94c+5umjY/Z5C9NcfAFoFPZiPKrkwqj/rYT8fL0BWYEkLAwu0ZXO0Ttcb1jlENyDsCsWiYICuvVsrYpLol9IqpooijJc6+oMLxT5zVsluYKEaCSGPMrbjqG8HE1XnBbqT6mw8hOsT183u+4N4Mn4KdY2eY7N/A4kPRefM6O7C9t5Z520+bolYtuSYhCLKCFYueUBWduquK7SS6DhSSK0WaSDZ3JqBdn5cAGaQhxXoZ1JMSLZes1fPXpsBcQlhMr/B08fvGqgE4q/0SkwAIxTF8aEJz8QCd6f439udumjov8XuYtEX+k0iEr/wG7BEtHlFJpLHbqV7hQuE2Sd1n24LtNBtZsP1fG28u2936nsUjfmvBTUvRxhbgE751CrIZrUp91aIrzYmAbhDiq7444HcBoGWF/Had1CcqRG3aQAoFITTuwM= sujal dyavanapelli@Vishal"
}


resource "aws_security_group" "main" {
  name        = "sgmain"
  description = "Allow ssh,http and https"
  

  dynamic "ingress" {
    for_each = [ 80, 443] 
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }

  }

  ingress {
    from_port = 22

    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  #I recommend to not allow default ip restrict this to your ip only
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}