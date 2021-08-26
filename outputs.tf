# ------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ------------------------------------------------------------------------------

output "lb_listener" {
  description = "All outputs of the created 'aws_lb_listener' resource."
  value       = try(aws_lb_listener.listener[0], {})
}

output "certificates" {
  description = "All outputs of the created 'aws_lb_listener_certificate' resources."
  value       = try(aws_lb_listener_certificate.certificate, {})
}

# ------------------------------------------------------------------------------
# OUTPUT MODULE CONFIGURATION
# ------------------------------------------------------------------------------

output "module_enabled" {
  description = "Whether the module is enabled"
  value       = var.module_enabled
}

output "module_tags" {
  description = "A map of default tags to apply to all resources created which support tags."
  value       = var.module_tags
}
