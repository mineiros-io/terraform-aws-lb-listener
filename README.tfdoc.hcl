header {
  image = "https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg"
  url   = "https://mineiros.io/?ref=terraform-aws-lb-listener"

  badge "build" {
    image = "https://github.com/mineiros-io/terraform-aws-lb-listener/workflows/Tests/badge.svg"
    url   = "https://github.com/mineiros-io/terraform-aws-lb-listener/actions"
    text  = "Build Status"
  }

  badge "semver" {
    image = "https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-lb-listener.svg?label=latest&sort=semver"
    url   = "https://github.com/mineiros-io/terraform-aws-lb-listener/releases"
    text  = "GitHub tag (latest SemVer)"
  }

  badge "terraform" {
    image = "https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform"
    url   = "https://github.com/hashicorp/terraform/releases"
    text  = "Terraform Version"
  }

  badge "tf-aws-provider" {
    image = "https://img.shields.io/badge/AWS-3-F8991D.svg?logo=terraform"
    url   = "https://github.com/terraform-providers/terraform-provider-aws/releases"
    text  = "AWS Provider Version"
  }

  badge "slack" {
    image = "https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack"
    url   = "https://mineiros.io/slack"
    text  = "Join Slack"
  }
}

section {
  title   = "terraform-aws-lb-listener"
  toc     = true
  content = <<-END
    A [Terraform] module to create and manage an
    [Application Load Balancer Listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
    on [Amazon Web Services (AWS)][aws].

    **_This module supports Terraform version 1
    and is compatible with the Terraform AWS Provider version 3.40._**

    This module is part of our Infrastructure as Code (IaC) framework
    that enables our users and customers to easily deploy and manage reusable,
    secure, and production-grade cloud infrastructure.
  END

  section {
    title   = "Module Features"
    content = <<-END
      This module implements the following Terraform resources:

      - `aws_lb_listener`
      - `aws_lb_listener_certificate`
      - `lb_listener_rule`
    END
  }

  section {
    title   = "Getting Started"
    content = <<-END
      Most common usage of the module:

      ```hcl
      module "terraform-aws-lb-listener" {
        source = "git@github.com:mineiros-io/terraform-aws-lb-listener.git?ref=v0.0.1"

        load_balancer_arn = "load-balancer-arn"
      }
      ```
    END
  }

  section {
    title   = "Module Argument Reference"
    content = <<-END
      See [variables.tf] and [examples/] for details and use-cases.
    END

    section {
      title = "Main Resource Configuration"

      variable "load_balancer_arn" {
        required    = true
        type        = string
        description = <<-END
          The ARN of the load balancer. Forces new resource creation.
        END
      }

      variable "port" {
        type        = number
        description = <<-END
          Port on which the load balancer is listening. Not valid for Gateway
          Load Balancers.
        END
      }

      variable "protocol" {
        type        = string
        description = <<-END
          Protocol for connections from clients to the load balancer. For
          Application Load Balancers, valid values are `HTTP` and `HTTPS`. For
          Network Load Balancers, valid values are `TCP`, `TLS`, `UDP`, and
          `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is
          enabled. Not valid for Gateway Load Balancers.
        END
      }

      variable "certificate_arn" {
        type        = string
        description = <<-END
          ARN of the default SSL server certificate. Exactly one certificate is
          required if the protocol is `HTTPS`.
        END
      }

      variable "alpn_policy" {
        type        = string
        default     = "None"
        description = <<-END
          Name of the Application-Layer Protocol Negotiation (ALPN) policy. Can
          be set if `protocol` is set to `TLS`. Valid values are `HTTP1Only`,
          `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`.
        END
      }

      variable "ssl_policy" {
        type        = string
        default     = "ELBSecurityPolicy-2016-08"
        description = <<-END
          Name of the SSL Policy for the listener. Required if protocol is
          `HTTPS` or `TLS`.
        END
      }

      variable "additional_certificates_arns" {
        type        = set(string)
        default     = []
        description = <<-END
          The ARNs of the additional certificates to attach to the listener.
        END
      }

      variable "default_action" {
        type = object(default_action)
        default = {
          fixed_response = {
            content_type = "plain/text"
            message_body = "Nothing to see here!"
            status_code  = 418
          }
        }
        description = <<-END
          Configuration block for default actions.
        END


        attribute "target_group_arn" {
          type        = string
          description = <<-END
            ARN of the Target Group to which to route traffic. Specify only if
            `type` is `forward` and you want to route to a single target group.
            To route to one or more target groups, use a `forward` block instead.
          END
        }

        attribute "order" {
          type        = number
          description = <<-END
            Order for the action. This value is required for rules with multiple
            actions. The action with the lowest value for order is performed
            first. Valid values are between `1` and `50000`.
          END
        }

        attribute "authenticate_cognito" {
          type        = object(authenticate_cognito)
          description = <<-END
            Configuration block for using Amazon Cognito to authenticate users.
          END

          attribute "user_pool_arn" {
            required    = true
            type        = string
            description = <<-END
              ARN of the Cognito user pool.
            END
          }

          attribute "user_pool_domain" {
            required    = true
            type        = string
            description = <<-END
              Domain prefix or fully-qualified domain name of the Cognito user pool.
            END
          }

          attribute "user_pool_client_id" {
            required    = true
            type        = string
            description = <<-END
              Domain prefix or fully-qualified domain name of the Cognito user
              pool.
            END
          }

          attribute "authentication_request_extra_params" {
            type        = map(string)
            description = <<-END
              Query parameters to include in the redirect request to the
              authorization endpoint. Max: 10.
            END
          }

          attribute "on_unauthenticated_request" {
            type        = string
            description = <<-END
              Behavior if the user is not authenticated. Valid values are `deny`,
              `allow` and `authenticate`.
            END
          }

          attribute "scope" {
            type        = string
            description = <<-END
              Set of user claims to be requested from the IdP.
            END
          }

          attribute "session_cookie_name" {
            type        = string
            description = <<-END
              Name of the cookie used to maintain session information.
            END
          }

          attribute "session_timeout" {
            type        = number
            description = <<-END
              Maximum duration of the authentication session, in seconds.
            END
          }
        }

        attribute "authenticate_oidc" {
          type        = object(authenticate_oidc)
          default     = []
          description = <<-END
            Configuration block for an identity provider that is compliant with
            OpenID Connect (OIDC).
          END

          attribute "authorization_endpoint" {
            required    = true
            type        = string
            description = <<-END
              Authorization endpoint of the IdP.
            END
          }

          attribute "client_id" {
            required    = true
            type        = string
            description = <<-END
              OAuth 2.0 client identifier.
            END
          }

          attribute "client_secret" {
            required    = true
            type        = string
            description = <<-END
              OAuth 2.0 client secret.
            END
          }

          attribute "issuer" {
            required    = true
            type        = string
            description = <<-END
              OIDC issuer identifier of the IdP.
            END
          }

          attribute "authentication_request_extra_params" {
            type        = map(string)
            description = <<-END
              Query parameters to include in the redirect request to the
              authorization endpoint. Max: 10.
            END
          }

          attribute "on_unauthenticated_request" {
            type        = string
            description = <<-END
              Behavior if the user is not authenticated. Valid values: `deny`,
              `allow` and `authenticate`.
            END
          }

          attribute "scope" {
            type        = string
            description = <<-END
              Set of user claims to be requested from the IdP.
            END
          }

          attribute "session_cookie_name" {
            type        = string
            description = <<-END
              Name of the cookie used to maintain session information.
            END
          }

          attribute "session_timeout" {
            type        = number
            description = <<-END
              Maximum duration of the authentication session, in seconds.
            END
          }

          attribute "token_endpoint" {
            required    = true
            type        = string
            description = <<-END
              Token endpoint of the IdP.
            END
          }

          attribute "user_info_endpoint" {
            required    = true
            type        = string
            description = <<-END
              User info endpoint of the IdP.
            END
          }
        }

        attribute "fixed_response" {
          type        = object(fixed_response)
          description = <<-END
            Information for creating an action that returns a custom HTTP
            response.
          END

          attribute "content_type" {
            required    = true
            type        = string
            description = <<-END
              Content type. Valid values are `text/plain`, `text/css`,
              `text/html`, `application/javascript` and `application/json`.
            END
          }

          attribute "message_body" {
            type        = string
            description = <<-END
              Message body.
            END
          }

          attribute "status_code" {
            type        = string
            description = <<-END
              HTTP response code. Valid values are `2XX`, `4XX`, or `5XX`.
            END
          }
        }

        attribute "forward" {
          type        = object(forward)
          description = <<-END
            Configuration block for creating an action that distributes requests
            among one or more target groups.
            If you specify both `forward` block and `target_group_arn`
            attribute, you can specify only one target group using `forward` and
            it must be the same target group specified in `target_group_arn`.
          END

          attribute "target_groups" {
            type        = set(target_group)
            description = <<-END
              Set of 1-5 target group blocks. 
            END

            attribute "arn" {
              required    = true
              type        = string
              description = <<-END
                ARN of the target group.
              END
            }

            attribute "weight" {
              type        = number
              description = <<-END
                Weight. The range is `0` to `999`.
              END
            }
          }

          attribute "stickiness" {
            type        = object(stickiness)
            description = <<-END
              Configuration block for target group stickiness for the rule.
            END

            attribute "duration" {
              required    = true
              type        = number
              description = <<-END
                Time period, in seconds, during which requests from a client
                should be routed to the same target group. The range is
                `1`-`604800` seconds (7 days).
              END
            }

            attribute "enabled" {
              type        = bool
              default     = false
              description = <<-END
                Whether target group stickiness is enabled.
              END
            }
          }
        }

        attribute "redirect" {
          type        = object(redirect)
          description = <<-END
            Configuration block for creating a redirect action.
          END

          attribute "status_code" {
            type        = string
            default     = "HTTP_302"
            description = <<-END
              HTTP redirect code. The redirect is either permanent (`HTTP_301`)
              or temporary (`HTTP_302`).
            END
          }

          attribute "host" {
            type        = string
            default     = "{host}"
            description = <<-END
              Hostname. This component is not percent-encoded. The hostname can
              contain `#{host}`.
            END
          }

          attribute "path" {
            type        = string
            default     = "#{path}"
            description = <<-END
              Absolute path, starting with the leading `"/"`. This component is
              not percent-encoded. The path can contain `#{host}`, `#{path}`,
              and `#{port}`.
            END
          }

          attribute "port" {
            type        = string
            default     = "#{port}"
            description = <<-END
              The port. Specify a value from `1` to `65535` or `#{port}`.
            END
          }

          attribute "protocol" {
            type        = string
            default     = "#{protocol}"
            description = <<-END
              The protocol. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`. 
            END
          }

          attribute "query" {
            type        = string
            default     = "#{query"
            description = <<-END
              The query parameters, URL-encoded when necessary, but not
              percent-encoded. Do not include the leading "?".
            END
          }
        }
      }

      variable "tags" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of tags to apply to the `aws_lb_listener` resource.
        END
      }
    }

    section {
      title = "Extended Resource Configuration"

      variable "rules" {
        type        = list(rule)
        default     = []
        description = <<-END
          A list of rules to be attached to the created listener.
        END

        attribute "id" {
          required    = true
          type        = string
          description = <<-END
            A unique identifier for the rule
          END
        }

        attribute "priority" {
          type        = number
          description = <<-END
            The priority for the rule between `1` and `50000`. Leaving it unset
            will automatically set the rule with next available priority after
            currently existing highest rule. A listener can't have multiple
            rules with the same priority.
          END
        }

        attribute "action" {
          required = true
          type     = object(action)
          default = {
            fixed_response = {
              content_type = "plain/text"
              message_body = "Nothing to see here!"
              status_code  = 418
            }
          }
          description = <<-END
            Configuration block for the action of the rule.
          END


          attribute "target_group_arn" {
            type        = string
            description = <<-END
              ARN of the Target Group to which to route traffic. Specify only if
              `type` is `forward` and you want to route to a single target group.
              To route to one or more target groups, use a `forward` block instead.
            END
          }

          attribute "fixed_response" {
            type        = object(fixed_response)
            description = <<-END
              Information for creating an action that returns a custom HTTP
              response. Required if `type` is `fixed-response`.
            END

            attribute "content_type" {
              required    = true
              type        = string
              description = <<-END
                Content type. Valid values are `text/plain`, `text/css`,
                `text/html`, `application/javascript` and `application/json`.
              END
            }

            attribute "message_body" {
              type        = string
              description = <<-END
                Message body.
              END
            }

            attribute "status_code" {
              type        = string
              description = <<-END
                HTTP response code. Valid values are `2XX`, `4XX`, or `5XX`.
              END
            }
          }

          attribute "forward" {
            type        = object(forward)
            description = <<-END
              Configuration block for creating an action that distributes requests
              among one or more target groups.
              If you specify both `forward` block and `target_group_arn`
              attribute, you can specify only one target group using `forward` and
              it must be the same target group specified in `target_group_arn`.
            END

            attribute "target_groups" {
              type        = set(target_group)
              description = <<-END
                Set of 1-5 target group blocks. 
              END

              attribute "arn" {
                required    = true
                type        = string
                description = <<-END
                  ARN of the target group.
                END
              }

              attribute "weight" {
                type        = number
                description = <<-END
                  Weight. The range is `0` to `999`.
                END
              }
            }

            attribute "stickiness" {
              type        = object(stickiness)
              description = <<-END
                Configuration block for target group stickiness for the rule.
              END

              attribute "duration" {
                required    = true
                type        = number
                description = <<-END
                  Time period, in seconds, during which requests from a client
                  should be routed to the same target group. The range is
                  `1`-`604800` seconds (7 days).
                END
              }

              attribute "enabled" {
                type        = bool
                default     = false
                description = <<-END
                  Whether target group stickiness is enabled.
                END
              }
            }
          }

          attribute "redirect" {
            type        = object(redirect)
            description = <<-END
              Configuration block for creating a redirect action. Required if
              `type` is `redirect`.
            END

            attribute "status_code" {
              type        = string
              default     = "HTTP_302"
              description = <<-END
                HTTP redirect code. The redirect is either permanent (`HTTP_301`)
                or temporary (`HTTP_302`).
              END
            }

            attribute "host" {
              type        = string
              default     = "#{host}"
              description = <<-END
                Hostname. This component is not percent-encoded. The hostname can
                contain `#{host}`.
              END
            }

            attribute "path" {
              type        = string
              default     = "#{path}"
              description = <<-END
                Absolute path, starting with the leading `"/"`. This component is
                not percent-encoded. The path can contain `#{host}`, `#{path}`,
                and `#{port}`.
              END
            }

            attribute "port" {
              type        = string
              default     = "#{port}"
              description = <<-END
                The port. Specify a value from `1` to `65535` or `#{port}`.
              END
            }

            attribute "protocol" {
              type        = string
              default     = "#{protocol}"
              description = <<-END
                The protocol. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`. 
              END
            }

            attribute "query" {
              type        = string
              default     = "#{query"
              description = <<-END
                The query parameters, URL-encoded when necessary, but not
                percent-encoded. Do not include the leading "?".
              END
            }
          }
        }

        attribute "conditions" {
          required    = true
          type        = set(conditions)
          description = <<-END
            A Condition block. Multiple condition blocks of different types can
            be set and all must be satisfied for the rule to match.
          END

          attribute "host_header" {
            type        = object(host_header)
            description = <<-END
              The maximum size of each pattern is 128 characters. Comparison is
              case insensitive. Wildcard characters supported: `*` (matches 0 or
              more characters) and `?` (matches exactly 1 character). Only one
              pattern needs to match for the condition to be satisfied.
            END

            attribute "values" {
              required    = true
              type        = set(string)
              description = <<-END
                List of host header patterns to match.
              END
            }
          }

          attribute "http_header" {
            type        = object(http_header)
            description = <<-END
              HTTP headers to match. 
            END

            attribute "http_header_name" {
              required    = true
              type        = string
              description = <<-END
                Name of HTTP header to search. The maximum size is 40
                characters. Comparison is case insensitive. Only RFC7240
                characters are supported. Wildcards are not supported. You
                cannot use HTTP header condition to specify the host header,
                use a `host-header` condition instead.
              END
            }

            attribute "values" {
              required    = true
              type        = set(string)
              description = <<-END
                List of header value patterns to match. Maximum size of each
                pattern is 128 characters. Comparison is case insensitive.
                Wildcard characters supported: `*` (matches 0 or more
                characters) and `?` (matches exactly 1 character). If the same
                header appears multiple times in the request they will be
                searched in order until a match is found. Only one pattern
                needs to match for the condition to be satisfied. To require
                that all of the strings are a match, create one condition block
                per string.
              END
            }
          }

          attribute "http_request_method" {
            type        = object(http_request_method)
            default     = []
            description = <<-END
              Maximum size is 40 characters. Only allowed characters are `A-Z`,
              hyphen (`-`) and underscore (`_`). Comparison is case sensitive.
              Wildcards are not supported. Only one needs to match for the
              condition to be satisfied. AWS recommends that `GET` and `HEAD`
              requests are routed in the same way because the response to a
              `HEAD` request may be cached.
            END

            attribute "values" {
              required    = true
              type        = set(string)
              description = <<-END
                List of HTTP request methods or verbs to match.
              END
            }
          }

          attribute "path_pattern" {
            type        = object(path_pattern)
            default     = []
            description = <<-END
              Maximum size of each pattern is `128` characters. Comparison is
              case sensitive. Wildcard characters supported: `*` (matches 0 or
              more characters) and `?` (matches exactly 1 character). Only one
              pattern needs to match for the condition to be satisfied. Path
              pattern is compared only to the path of the URL, not to its query
              string. To compare against the query string, use a
              `query_string` condition.
            END

            attribute "values" {
              required    = true
              type        = set(string)
              description = <<-END
                List of path patterns to match against the request URL. 
              END
            }
          }

          attribute "query_string" {
            type        = set(query_string)
            default     = []
            description = <<-END
              Query strings to match.
            END

            attribute "key" {
              type        = string
              description = <<-END
                Query string key pattern to match. 
              END
            }

            attribute "value" {
              required    = true
              type        = string
              description = <<-END
                Query string value pattern to match.
              END
            }
          }

          attribute "source_ip" {
            type        = object(source_ip)
            default     = []
            description = <<-END
              You can use both IPv4 and IPv6 addresses. Wildcards are not
              supported. Condition is satisfied if the source IP address of the
              request matches one of the CIDR blocks. Condition is not satisfied
              by the addresses in the `X-Forwarded-For` header, use
              `http_header` condition instead.
            END

            attribute "values" {
              required    = true
              type        = set(string)
              description = <<-END
                List of source IP CIDR notations to match.
              END
            }
          }
        }

        attribute "authenticate_cognito" {
          type        = object(authenticate_cognito)
          default     = []
          description = <<-END
            Configuration block for using Amazon Cognito to authenticate users.
            Specify only when `type` is `authenticate-cognito`.
          END

          attribute "user_pool_arn" {
            required    = true
            type        = string
            description = <<-END
              ARN of the Cognito user pool.
            END
          }

          attribute "user_pool_domain" {
            required    = true
            type        = string
            description = <<-END
              Domain prefix or fully-qualified domain name of the Cognito user pool.
            END
          }

          attribute "user_pool_client_id" {
            required    = true
            type        = string
            description = <<-END
              Domain prefix or fully-qualified domain name of the Cognito user
              pool.
            END
          }

          attribute "authentication_request_extra_params" {
            type        = map(string)
            description = <<-END
              Query parameters to include in the redirect request to the
              authorization endpoint. Accepts a maximum of 10 extra parameters.
            END
          }

          attribute "on_unauthenticated_request" {
            type        = string
            description = <<-END
              Behavior if the user is not authenticated. Valid values are `deny`,
              `allow` and `authenticate`.
            END
          }

          attribute "scope" {
            type        = string
            description = <<-END
              Set of user claims to be requested from the IdP.
            END
          }

          attribute "session_cookie_name" {
            type        = string
            description = <<-END
              Name of the cookie used to maintain session information.
            END
          }

          attribute "session_timeout" {
            type        = number
            description = <<-END
              Maximum duration of the authentication session, in seconds.
            END
          }
        }

        attribute "authenticate_oidc" {
          type        = object(authenticate_oidc)
          default     = []
          description = <<-END
            Configuration block for an identity provider that is compliant with
            OpenID Connect (OIDC).
          END

          attribute "authorization_endpoint" {
            required    = true
            type        = string
            description = <<-END
              Authorization endpoint of the IdP.
            END
          }

          attribute "client_id" {
            required    = true
            type        = string
            description = <<-END
              OAuth 2.0 client identifier.
            END
          }

          attribute "client_secret" {
            required    = true
            type        = string
            description = <<-END
              OAuth 2.0 client secret.
            END
          }

          attribute "issuer" {
            required    = true
            type        = string
            description = <<-END
              OIDC issuer identifier of the IdP.
            END
          }

          attribute "authentication_request_extra_params" {
            type        = map(string)
            description = <<-END
              Query parameters to include in the redirect request to the
              authorization endpoint. Max: 10.
            END
          }

          attribute "on_unauthenticated_request" {
            type        = string
            description = <<-END
              Behavior if the user is not authenticated. Valid values: `deny`,
              `allow` and `authenticate`.
            END
          }

          attribute "scope" {
            type        = string
            description = <<-END
              Set of user claims to be requested from the IdP.
            END
          }

          attribute "session_cookie_name" {
            type        = string
            description = <<-END
              Name of the cookie used to maintain session information.
            END
          }

          attribute "session_timeout" {
            type        = number
            description = <<-END
              Maximum duration of the authentication session, in seconds.
            END
          }

          attribute "token_endpoint" {
            required    = true
            type        = string
            description = <<-END
              Token endpoint of the IdP.
            END
          }

          attribute "user_info_endpoint" {
            required    = true
            type        = string
            description = <<-END
              User info endpoint of the IdP.
            END
          }
        }
      }

      variable "rules_tags" {
        type        = map(string)
        default     = {}
        description = <<-END
          A map of tags to apply to all `aws_lb_listener_rule` resources.
        END
      }
    }

    section {
      title = "Module Configuration"

      variable "module_enabled" {
        type        = bool
        default     = true
        description = <<-END
          Specifies whether resources in the module will be created.
        END
      }

      variable "module_tags" {
        type           = map(string)
        default        = {}
        description    = <<-END
          A map of tags that will be applied to all created resources that accept tags.
          Tags defined with `module_tags` can be overwritten by resource-specific tags.
        END
        readme_example = <<-END
          module_tags = {
            environment = "staging"
            team        = "platform"
          }
        END
      }

      variable "module_depends_on" {
        type           = list(dependency)
        description    = <<-END
          A list of dependencies.
          Any object can be _assigned_ to this list to define a hidden external dependency.
        END
        default        = []
        readme_example = <<-END
          module_depends_on = [
            null_resource.name
          ]
        END
      }
    }
  }

  section {
    title   = "Module Outputs"
    content = <<-END
      The following attributes are exported in the outputs of the module:
    END

    output "lb_listener_rule" {
      type        = object(lb_listener_rule)
      description = <<-END
          All outputs of the created 'aws_lb_listener_rule' resource.
        END
    }

    output "module_enabled" {
      type        = bool
      description = <<-END
          Whether this module is enabled.
        END
    }

    output "module_tags" {
      type        = map(string)
      description = <<-END
        The map of tags that are being applied to all created resources that accept tags.
      END
    }
  }

  section {
    title = "External Documentation"

    section {
      title   = "AWS Documentation"
      content = <<-END
        - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html
      END
    }

    section {
      title   = "Terraform AWS Provider Documentation"
      content = <<-END
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate
        - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
      END
    }
  }

  section {
    title   = "Module Versioning"
    content = <<-END
      This Module follows the principles of [Semantic Versioning (SemVer)].

      Given a version number `MAJOR.MINOR.PATCH`, we increment the:

      1. `MAJOR` version when we make incompatible changes,
      2. `MINOR` version when we add functionality in a backwards compatible manner, and
      3. `PATCH` version when we make backwards compatible bug fixes.
    END

    section {
      title   = "Backwards compatibility in `0.0.z` and `0.y.z` version"
      content = <<-END
        - Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
        - Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)
      END
    }
  }

  section {
    title   = "About Mineiros"
    content = <<-END
      [Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
      that solves development, automation and security challenges in cloud infrastructure.

      Our vision is to massively reduce time and overhead for teams to manage and
      deploy production-grade and secure cloud infrastructure.

      We offer commercial support for all of our modules and encourage you to reach out
      if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
      [Community Slack channel][slack].
    END
  }

  section {
    title   = "Reporting Issues"
    content = <<-END
      We use GitHub [Issues] to track community reported issues and missing features.
    END
  }

  section {
    title   = "Contributing"
    content = <<-END
      Contributions are always encouraged and welcome! For the process of accepting changes, we use
      [Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].
    END
  }

  section {
    title   = "Makefile Targets"
    content = <<-END
      This repository comes with a handy [Makefile].
      Run `make help` to see details on each available target.
    END
  }

  section {
    title   = "License"
    content = <<-END
      [![license][badge-license]][apache20]

      This module is licensed under the Apache License Version 2.0, January 2004.
      Please see [LICENSE] for full details.

      Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]
    END
  }
}

references {
  ref "homepage" {
    value = "https://mineiros.io/?ref=terraform-aws-lb-listener"
  }
  ref "hello@mineiros.io" {
    value = " mailto:hello@mineiros.io"
  }
  ref "badge-license" {
    value = "https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg"
  }
  ref "releases-terraform" {
    value = "https://github.com/hashicorp/terraform/releases"
  }
  ref "releases-aws-provider" {
    value = "https://github.com/terraform-providers/terraform-provider-aws/releases"
  }
  ref "apache20" {
    value = "https://opensource.org/licenses/Apache-2.0"
  }
  ref "slack" {
    value = "https://mineiros.io/slack"
  }
  ref "terraform" {
    value = "https://www.terraform.io"
  }
  ref "aws" {
    value = "https://aws.amazon.com/"
  }
  ref "semantic versioning (semver)" {
    value = "https://semver.org/"
  }
  ref "variables.tf" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/variables.tf"
  }
  ref "examples/" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/examples"
  }
  ref "issues" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/issues"
  }
  ref "license" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/LICENSE"
  }
  ref "makefile" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/Makefile"
  }
  ref "pull requests" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/pulls"
  }
  ref "contribution guidelines" {
    value = "https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/CONTRIBUTING.md"
  }
}
