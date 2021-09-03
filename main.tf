resource "aws_lb_listener" "listener" {
  count = var.module_enabled ? 1 : 0

  load_balancer_arn = var.load_balancer_arn

  port        = var.port
  protocol    = var.protocol
  alpn_policy = var.protocol == "TLS" ? var.alpn_policy : null

  ssl_policy      = var.protocol == "HTTPS" || var.protocol == "TLS" ? var.ssl_policy : null
  certificate_arn = var.certificate_arn

  default_action {
    type             = var.default_action.type
    target_group_arn = var.default_action.type == "forward" ? try(var.default_action.target_group_arn, null) : null
    order            = try(var.default_action.order, null)

    dynamic "authenticate_cognito" {
      for_each = var.default_action.type == "authenticate_cognito" ? ["enable_authenticate_cognito"] : []

      content {
        user_pool_arn       = var.default_action.authenticate_cognito.user_pool_arn
        user_pool_domain    = var.default_action.authenticate_cognito.user_pool_domain
        user_pool_client_id = var.default_action.authenticate_cognito.user_pool_client_id

        authentication_request_extra_params = try(var.default_action.authenticate_cognito.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(var.default_action.authenticate_cognito.on_unauthenticated_request, null)
        scope                               = try(var.default_action.authenticate_cognito.scope, null)
        session_cookie_name                 = try(var.default_action.authenticate_cognito.session_cookie_name, null)
        session_timeout                     = try(var.default_action.authenticate_cognito.session_timeout, null)
      }
    }

    dynamic "fixed_response" {
      for_each = var.default_action.type == "fixed-response" ? ["enable_fixed_response"] : []

      content {
        content_type = var.default_action.fixed_response.content_type
        message_body = try(var.default_action.fixed_response.message_body, null)
        status_code  = try(var.default_action.fixed_response.status_code, null)
      }
    }

    dynamic "forward" {
      for_each = try(var.default_action.forward, null) != null ? ["enable_forward"] : []

      content {
        dynamic "target_group" {
          for_each = var.default_action.forward.target_group

          content {
            arn    = target_group.value.arn
            weight = try(target_group.value.weight, null)
          }
        }

        dynamic "stickiness" {
          for_each = try(var.default_action.forward.stickiness, null) != null ? ["enable_stickiness"] : []

          content {
            duration = var.default_action.stickiness.duration
            enabled  = try(var.default_action.stickiness.enabled, false)
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = try(var.default_action.redirect, null) != null ? ["enable_redirect"] : []

      content {
        status_code = try(var.default_action.redirect.status_code, "HTTP_302")
        host        = try(var.default_action.redirect.host, "#{host}")
        path        = try(var.default_action.redirect.path, "/#{path}")
        port        = try(var.default_action.redirect.port, "#{port}")
        protocol    = try(var.default_action.redirect.protocol, "#{protocol}")
        query       = try(var.default_action.redirect.query, "#{query}")
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags       = merge(var.module_tags, var.tags)
  depends_on = [var.module_depends_on]
}

resource "aws_lb_listener_certificate" "certificate" {
  for_each = var.module_enabled ? var.additional_certificates_arns : []

  listener_arn    = aws_lb_listener.listener[0].arn
  certificate_arn = each.value

  depends_on = [var.module_depends_on]
}
