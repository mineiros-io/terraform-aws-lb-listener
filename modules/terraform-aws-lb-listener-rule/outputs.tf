# ------------------------------------------------------------------------------
# OUTPUT CALCULATED VARIABLES (prefer full objects)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# OUTPUT ALL RESOURCES AS FULL OBJECTS
# ------------------------------------------------------------------------------

output "lb_listener_rule" {
  description = "All outputs of the created 'aws_lb_listener_rule' resource."
  value       = try(aws_lb_listener_rule.lb_listener_rule[0], {})
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
