output "gcp_vm_instance_private_and_static_ip_gcp_alb_static_ip" {
  description = "Details of the Google Cloud VM Instance and Application LoadBalancer"
  value       = "${module.autoscale_alb}"
}
