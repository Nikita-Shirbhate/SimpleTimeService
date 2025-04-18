resource "aws_lb" "simpletime_alb" {
  name               = "simpletime-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id   # <- this is correct inside this block
  security_groups    = [aws_security_group.lb_sg.id]

  tags = {
    Name = "simpletime-alb"
  }
}


