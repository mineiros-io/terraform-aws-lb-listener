resource "aws_lb_listener" "listener" {
  count = var.module_enabled ? 1 : 0

  load_balancer_arn = var.load_balancer_arn

  port        = var.port
  protocol    = var.protocol
  alpn_policy = var.protocol == "TLS" ? var.alpn_policy : null

  ssl_policy      = var.protocol == "HTTPS" || var.protocol == "TLS" ? var.ssl_policy : null
  certificate_arn = var.certificate_arn

  # Enable Cognito auth
  dynamic "default_action" {
    for_each = try([var.default_action.authenticate_cognito], [])
    iterator = authenticate_cognito

    content {
      type = "authenticate-cognito"

      authenticate_cognito {
        user_pool_arn       = authenticate_cognito.value.user_pool_arn
        user_pool_domain    = authenticate_cognito.value.user_pool_domain
        user_pool_client_id = authenticate_cognito.value.user_pool_client_id

        authentication_request_extra_params = try(authenticate_cognito.value.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(authenticate_cognito.value.on_unauthenticated_request, null)
        scope                               = try(authenticate_cognito.value.scope, null)
        session_cookie_name                 = try(authenticate_cognito.value.session_cookie_name, null)
        session_timeout                     = try(authenticate_cognito.value.session_timeout, null)
      }
    }
  }

  # Enable OIDC auth
  dynamic "default_action" {
    for_each = try([var.default_action.authenticate_oidc], [])
    iterator = authenticate_oidc

    content {
      type = "authenticate-oidc"

      authenticate_oidc {
        authorization_endpoint = authenticate_oidc.value.authorization_endpoint
        client_id              = authenticate_oidc.value.client_id
        client_secret          = authenticate_oidc.value.client_secret
        issuer                 = authenticate_oidc.value.issuer

        authentication_request_extra_params = try(authenticate_oidc.value.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(authenticate_oidc.value.on_unauthenticated_request, null)
        scope                               = try(authenticate_oidc.value.scope, null)
        session_cookie_name                 = try(authenticate_oidc.value.session_cookie_name, null)
        session_timeout                     = try(authenticate_oidc.value.session_timeout, null)

        token_endpoint     = authenticate_oidc.value.token_endpoint
        user_info_endpoint = authenticate_oidc.value.user_info_endpoint
      }
    }
  }

  # Add a single default action
  default_action {
    type             = var.default_action.type
    target_group_arn = var.default_action.type == "forward" ? try(var.default_action.target_group_arn, null) : null
    order            = try(var.default_action.order, null)

    dynamic "fixed_response" {
      for_each = try([var.default_action.fixed_response], [])

      content {
        content_type = fixed_response.value.content_type
        message_body = try(fixed_response.value.message_body, null)
        status_code  = try(fixed_response.value.status_code, null)
      }
    }

    dynamic "forward" {
      for_each = try([var.default_action.forward], [])

      content {
        dynamic "target_group" {
          for_each = forward.value.target_group

          content {
            arn    = target_group.value.arn
            weight = try(target_group.value.weight, null)
          }
        }

        dynamic "stickiness" {
          for_each = try([forward.value.stickiness], [])

          content {
            duration = stickiness.value.duration
            enabled  = try(stickiness.value.enabled, false)
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = try([var.default_action.redirect], [])

      content {
        status_code = try(redirect.value.status_code, "HTTP_302")
        host        = try(redirect.value.host, "#{host}")
        path        = try(redirect.value.path, "/#{path}")
        port        = try(redirect.value.port, "#{port}")
        protocol    = try(redirect.value.protocol, "#{protocol}")
        query       = try(redirect.value.query, "#{query}")
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
