output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "load_balancer_hostname" {
  value = kubernetes_service.simple_time_svc.status[0].load_balancer.ingress[0].hostname
}
