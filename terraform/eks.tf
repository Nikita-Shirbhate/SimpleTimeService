module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "simple-time-cluster"
  cluster_version = "1.29"
  subnets         = aws_subnet.private[*].id
  vpc_id          = aws_vpc.main.id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_size         = 1
      max_size         = 3
      instance_types   = ["t3.small"]
      subnet_ids       = aws_subnet.private[*].id
    }
  }
}
