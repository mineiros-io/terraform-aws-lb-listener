resource "aws_lb_listener_rule" "lb_listener_rule" {
  count = var.module_enabled ? 1 : 0

  listener_arn = var.listener_arn

  priority = var.priority

  # Cognito Auth
  dynamic "action" {
    for_each = var.authenticate_cognito != null ? ["enable_authenticate_cognito_action"] : []

    content {
      type = "authenticate-cognito"

      authenticate_cognito {
        user_pool_arn       = var.authenticate_cognito.user_pool_arn
        user_pool_domain    = var.authenticate_cognito.user_pool_domain
        user_pool_client_id = var.authenticate_cognito.user_pool_client_id

        authentication_request_extra_params = try(var.authenticate_cognito.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(var.authenticate_cognito.on_unauthenticated_request, null)
        scope                               = try(var.authenticate_cognito.scope, null)
        session_cookie_name                 = try(var.authenticate_cognito.session_cookie_name, null)
        session_timeout                     = try(var.authenticate_cognito.session_timeout, null)
      }
    }
  }

  # OIDC Auth
  dynamic "action" {
    for_each = var.authenticate_cognito != null ? ["enable_authenticate_cognito_action"] : []

    content {
      type = "authenticate-oidc"

      authenticate_oidc {
        authorization_endpoint = var.authenticate_oidc.authorization_endpoint
        client_id              = var.authenticate_oidc.client_id
        client_secret          = var.authenticate_oidc.client_secret
        issuer                 = var.authenticate_oidc.issuer

        authentication_request_extra_params = try(var.authenticate_oidc.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(var.authenticate_oidc.on_unauthenticated_request, null)
        scope                               = try(var.authenticate_oidc.scope, null)
        session_cookie_name                 = try(var.authenticate_oidc.session_cookie_name, null)
        session_timeout                     = try(var.authenticate_oidc.session_timeout, null)
        token_endpoint                      = var.authenticate_oidc.token_endpoint
        user_info_endpoint                  = var.authenticate_oidc.user_info_endpoint
      }
    }
  }

  action {
    type             = var.action.type
    target_group_arn = var.action.type == "forward" ? try(var.action.target_group_arn, null) : null
    order            = try(var.action.order, null)

    dynamic "fixed_response" {
      for_each = var.action.type == "fixed-response" ? ["enable_fixed_response_action"] : []

      content {
        content_type = var.action.fixed_response.content_type
        message_body = try(var.action.fixed_response.message_body, null)
        status_code  = try(var.action.fixed_response.status_code, null)
      }
    }

    dynamic "forward" {
      for_each = try(var.action.forward, null) != null ? ["enable_forward_action"] : []

      content {
        dynamic "target_group" {
          for_each = var.action.forward.target_group

          content {
            arn    = target_group.value.arn
            weight = try(target_group.value.weight, null)
          }
        }

        dynamic "stickiness" {
          for_each = try(var.action.forward.stickiness, null) != null ? ["enable_stickiness"] : []

          content {
            duration = var.action.stickiness.duration
            enabled  = try(var.action.stickiness.enabled, false)
          }
        }
      }
    }

    dynamic "redirect" {
      for_each = try(var.action.redirect, null) != null ? ["enable_redirect_action"] : []

      content {
        status_code = try(var.action.redirect.status_code, "HTTP_302")
        host        = try(var.action.redirect.host, "#{host}")
        path        = try(var.action.redirect.path, "/#{path}")
        port        = try(var.action.redirect.port, "#{port}")
        protocol    = try(var.action.redirect.protocol, "#{protocol}")
        query       = try(var.action.redirect.query, "#{query}")
      }
    }
  }

  dynamic "condition" {
    for_each = var.conditions

    content {
      dynamic "host_header" {
        for_each = try(condition.value.host_header, null) != null ? ["enable_host_header_condition"] : []

        content {
          values = condition.value.host_header.values
        }
      }

      dynamic "http_header" {
        for_each = try(condition.value.http_header, null) != null ? ["enable_http_header_condition"] : []

        content {
          http_header_name = condition.value.http_header.http_header_name
          values           = condition.value.http_header.values
        }
      }

      dynamic "http_request_method" {
        for_each = try(condition.value.http_request_method, null) != null ? ["enable_http_request_method_condition"] : []

        content {
          values = condition.value.http_request_method.values
        }
      }

      dynamic "path_pattern" {
        for_each = try(condition.value.path_pattern, null) != null ? ["enable_path_pattern_condition"] : []

        content {
          values = condition.value.path_pattern.values
        }
      }

      dynamic "query_string" {
        for_each = try(condition.value.query_string, null) != null ? ["enable_query_string_condition"] : []

        content {
          key   = try(condition.value.query_string.key, null)
          value = condition.value.query_string.value
        }
      }

      dynamic "source_ip" {
        for_each = try(condition.value.source_ip, null) != null ? ["enable_source_ip_condition"] : []

        content {
          values = condition.value.source_ip.values
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
