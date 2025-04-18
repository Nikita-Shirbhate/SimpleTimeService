resource "aws_subnet" "public" {
  # ...
  tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  # ...
  tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
