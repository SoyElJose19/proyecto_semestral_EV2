resource "aws_instance" "mysql_jose" {
  ami           = "ami-0c7217cdde317cfec" 
  instance_type = "t2.micro"
  subnet_id     = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  tags = { Name = "BD-MySQL" }
}
