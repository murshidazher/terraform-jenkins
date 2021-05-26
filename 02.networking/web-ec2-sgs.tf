resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow traffic for web apps on ec2"
  vpc_id      = aws_vpc.my_app.id

  # customers to hit website on 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # in production, we shouldn't do this the cidr block should be our own ips so no outside access
  }

  # ec2 to outside services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
