# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ----------------------------------------------------------------------------------------------------------------------

output "lb_listener" {
  description = "All outputs of the created 'aws_lb_listener' resource."
  value       = one(aws_lb_listener.listener)
}

output "rules" {
  description = "A map of all outputs of the resources created in the 'terraform-aws-lb-listener-rule' modules keyed by id."
  value       = module.lb_listener_rule
}

output "certificates" {
  description = "All outputs of the created 'aws_lb_listener_certificate' resources."
  value       = try(aws_lb_listener_certificate.certificate, {})
}

# ----------------------------------------------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ----------------------------------------------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled."
  value       = var.module_enabled
}

output "module_tags" {
  description = "A map of tags that will be applied to all created resources that accept tags."
  value       = var.module_tags
}
