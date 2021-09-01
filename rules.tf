locals {
  rules = { for rule in var.rules : rule.id => rule }
}

module "lb_listener_rule" {
  source = "./modules/terraform-aws-lb-listener-rule"

  for_each = var.module_enabled ? local.rules : []

  listener_arn = aws_lb_listener.listener[0].arn
  priority     = try(each.value.priority, null)

  action               = each.value.action
  conditions           = each.value.conditions
  authenticate_cognito = try(each.value.authenticate_cognito, null)
  authenticate_oidc    = try(each.value.authenticate_oidc, null)

  tags              = merge(var.rules_tags, try(each.value.tags))
  module_tags       = var.module_tags
  module_depends_on = var.module_depends_on
}
