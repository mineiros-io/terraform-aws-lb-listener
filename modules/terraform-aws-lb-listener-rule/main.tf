resource "aws_lb_listener_rule" "lb_listener_rule" {
  count = var.module_enabled ? 1 : 0

  listener_arn = var.listener_arn

  priority = var.priority

  # Enable Cognito auth
  dynamic "action" {
    for_each = var.authenticate_cognito != null ? [var.authenticate_cognito] : []
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
  dynamic "action" {
    for_each = var.authenticate_oidc != null ? [var.authenticate_oidc] : []
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

  # Add a single action
  action {
    type             = var.action.type
    target_group_arn = try(var.action.target_group_arn, null)

    dynamic "fixed_response" {
      for_each = try([var.action.fixed_response], [])

      content {
        message_body = try(fixed_response.value.message_body, null)
        content_type = fixed_response.value.content_type
        status_code  = try(fixed_response.value.status_code, null)
      }
    }

    dynamic "forward" {
      for_each = try([var.action.forward], [])

      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups

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
      for_each = try([var.action.redirect], [])

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

  dynamic "condition" {
    for_each = var.conditions

    content {
      dynamic "host_header" {
        for_each = try([condition.value.host_header], [])

        content {
          values = host_header.value.values
        }
      }

      dynamic "http_header" {
        for_each = try([condition.value.http_header], [])

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = try([condition.value.http_request_method], [])

        content {
          values = http_request_method.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = try([condition.value.path_pattern], [])

        content {
          values = path_pattern.value.values
        }
      }

      dynamic "query_string" {
        for_each = try([condition.value.query_string], [])

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = try([condition.value.source_ip], [])

        content {
          values = source_ip.value.values
        }
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags       = merge(var.module_tags, var.tags)
  depends_on = [var.module_depends_on]
}
