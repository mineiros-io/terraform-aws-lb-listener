# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ----------------------------------------------------------------------------------------------------------------------

variable "load_balancer_arn" {
  type        = string
  description = "(Required, Forces New Resource) The ARN of the load balancer."
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ----------------------------------------------------------------------------------------------------------------------

variable "port" {
  type        = number
  description = "(Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers."
  default     = null
}

variable "protocol" {
  type        = string
  description = "(Optional) Protocol for connections from clients to the load balancer. For Application Load Balancers, valid values are 'HTTP' and 'HTTPS'. For Network Load Balancers, valid values are 'TCP', 'TLS', 'UDP', and 'TCP_UDP'. Not valid to use 'UDP' or 'TCP_UDP' if dual-stack mode is enabled. Not valid for Gateway Load Balancers."
  default     = null

  validation {
    condition     = var.protocol == null ? true : contains(["HTTP", "HTTPS", "TCP", "TLS", "UDP", "TCP_UDP"], var.protocol)
    error_message = "The 'protocol' variable should be set to one of either: 'HTTP', 'HTTPS', 'TCP', 'TLS', 'UDP' or 'TCP_UDP'."
  }
}

variable "certificate_arn" {
  type        = string
  description = "(Optional) ARN of the default SSL server certificate. Exactly one certificate is required if the protocol is 'HTTPS'."
  default     = null
}

variable "alpn_policy" {
  type        = string
  description = "(Optional) Name of the Application-Layer Protocol Negotiation (ALPN) policy. Can be set if 'protocol' is set to 'TLS'. Valid values are 'HTTP1Only', 'HTTP2Only', 'HTTP2Optional', 'HTTP2Preferred', and 'None'."
  default     = "None"

  validation {
    condition     = contains(["HTTP1Only", "HTTP2Only", "HTTP2Optional", "HTTP2Preferred", "None"], var.alpn_policy)
    error_message = "The 'apln_policy' value must be the name of a valid ALPN policy. Valid values are 'HTTP1Only', 'HTTP2Only', 'HTTP2Optional', 'HTTP2Preferred', and 'None'."
  }
}

variable "ssl_policy" {
  type        = string
  description = "(Optional) Name of the SSL Policy for the listener. Required if protocol is 'HTTPS' or 'TLS'."
  default     = "ELBSecurityPolicy-2016-08"
}

variable "additional_certificates_arns" {
  type        = set(string)
  description = "(Required) The ARNs of the additional certificates to attach to the listener."
  default     = []
}

variable "default_action" {
  type = any
  # type = object({
  #   # (Optional) Order for the action. This value is required for rules with multiple actions. The action with the lowest value for order is performed first. Valid values are between 1 and 50000.
  #   order = optional(number)
  #   # (Optional) ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead.
  #   target_group = optional(string)

  #   authenticate_cognito = optional(object({
  #     # (Required) ARN of the Cognito user pool.
  #     user_pool_arn = string
  #     # (Required) ID of the Cognito user pool client.
  #     user_pool_client_id = string
  #     # (Required) Domain prefix or fully-qualified domain name of the Cognito user pool.
  #     user_pool_domain = string
  #     # (Optional) Query parameters to include in the redirect request to the
  #     # authorization endpoint. Max: 10.
  #     authentication_request_extra_params = optional(list(object({
  #       key   = string
  #       value = string
  #     })))
  #     # (Optional) Behavior if the user is not authenticated.
  #     # Valid values are 'deny', 'allow' and 'authenticate'.
  #     on_unauthenticated_request = optional(string)
  #     # (Optional) Set of user claims to be requested from the IdP.
  #     scope = optional(string)
  #     # (Optional) Name of the cookie used to maintain session information.
  #     session_cookie_name = optional(string)
  #     # (Optional) Maximum duration of the authentication session, in seconds.
  #     session_timeout = optional(number)
  #   }))

  #   authenticate_oidc = optional(object({
  #     # (Required) Authorization endpoint of the IdP.
  #     authorization_endpoint = string
  #     # (Required) OAuth 2.0 client identifier.
  #     client_id = string
  #     # (Required) OAuth 2.0 client secret.
  #     client_secret = string
  #     # (Required) OAuth 2.0 client secret.
  #     issuer = string
  #     # (Required) Token endpoint of the IdP.
  #     token_endpoint = string
  #     # (Required) User info endpoint of the IdP.
  #     user_info_endpoint = string
  #     # (Optional) Query parameters to include in the redirect request to the authorization endpoint. Max: 10.
  #     authentication_request_extra_params = optional(list(object({
  #       key   = string
  #       value = string
  #     })))
  #     # (Optional) Behavior if the user is not authenticated.
  #     # Valid values are 'deny', 'allow' and 'authenticate'.
  #     on_unauthenticated_request = optional(string)
  #     # (Optional) Set of user claims to be requested from the IdP.
  #     scope = optional(string)
  #     # (Optional) Name of the cookie used to maintain session information.
  #     session_cookie_name = optional(string)
  #     # (Optional) Maximum duration of the authentication session, in seconds.
  #     session_timeout = optional(number)
  #   }))

  #   fixed_response = optional(object({
  #     # (Required) Content type. Valid values are 'text/plain', 'text/css', 'text/html', 'application/javascript' and 'application/json'.
  #     content_type = string
  #     # (Optional) Message body.
  #     message_body = optional(string)
  #     # (Optional) HTTP response code. Valid values are 2XX, 4XX, or 5XX
  #     status_code = optional(string)
  #   }))

  #   forward = optional(object({
  #     # (Required) Set of 1-5 target group blocks.
  #     target_groups = list(object({
  #       # (Required) ARN of the target group.
  #       arn = string
  #       # (Optional) Weight. The range is 0 to 999.
  #       weight = optional(number)
  #     }))

  #     stickiness = optional(object({
  #       #  (Required) Time period, in seconds, during which requests from a client should be routed to the same target group. The range is 1-604800 seconds (7 days)
  #       duration = number
  #       # (Optional) Whether target group stickiness is enabled
  #       enabled = optional(bool)
  #     }))
  #   }))

  #   redirect = optional(object({
  #     # (Required) HTTP redirect code. The redirect is either permanent (HTTP_301) or temporary (HTTP_302).
  #     status_code = string
  #     # (Optional) Hostname. This component is not percent-encoded. The hostname can contain #{host}. Defaults to #{host}.
  #     host = optional(string)
  #     # (Optional) Absolute path, starting with the leading "/". This component is not percent-encoded. The path can contain #{host}, #{path}, and #{port}. Defaults to /#{path}.
  #     path = optional(string)
  #     # (Optional) Port. Specify a value from 1 to 65535 or #{port}. Defaults to #{port}.
  #     port = optional(string)
  #     # (Optional) Protocol. Valid values are HTTP, HTTPS, or #{protocol}. Defaults to #{protocol}.
  #     protocol = optional(string)
  #     # (Optional) Query parameters, URL-encoded when necessary, but not percent-encoded. Do not include the leading "?". Defaults to #{query}.
  #     query = optional(string)
  #   }))

  # })
  description = "(Required) Configuration block for default actions."
  default = {
    fixed_response = {
      content_type = "plain/text"
      message_body = "Nothing to see here!"
      status_code  = 418
    }
  }
}

variable "rules" {
  description = "(Optional) A list of rules to be attached to the created listener."
  # type = list(object({
  #   # (Required) A unique identifier for the rule
  #   id = string
  #   # (Optional) The priority for the rule between 1 and 50000. Leaving it unset will automatically set the rule with next available priority after currently existing highest rule. A listener can't have multiple rules with the same priority.
  #   priority = optional(number)

  #   # (Required) Configuration block for default actions.
  #   action = object({
  #     # (Optional) Order for the action. This value is required for rules with multiple actions. The action with the lowest value for order is performed first. Valid values are between 1 and 50000.
  #     order = optional(number)
  #     # (Optional) ARN of the Target Group to which to route traffic. Specify only if type is forward and you want to route to a single target group. To route to one or more target groups, use a forward block instead.
  #     target_group = optional(string)

  #     fixed_response = optional(object({
  #       # (Required) Content type. Valid values are 'text/plain', 'text/css', 'text/html', 'application/javascript' and 'application/json'.
  #       content_type = string
  #       # (Optional) Message body.
  #       message_body = optional(string)
  #       # (Optional) HTTP response code. Valid values are 2XX, 4XX, or 5XX
  #       status_code = optional(string)
  #     }))

  #     forward = optional(object({
  #       # (Required) Set of 1-5 target group blocks.
  #       target_group = list(object({
  #         # (Required) ARN of the target group.
  #         arn = string
  #         # (Optional) Weight. The range is 0 to 999.
  #         weight = optional(number)
  #       }))

  #       stickiness = optional(object({
  #         #  (Required) Time period, in seconds, during which requests from a client should be routed to the same target group. The range is 1-604800 seconds (7 days)
  #         duration = number
  #         # (Optional) Whether target group stickiness is enabled
  #         enabled = optional(bool)
  #       }))
  #     }))

  #     redirect = optional(object({
  #       # (Required) HTTP redirect code. The redirect is either permanent (HTTP_301) or temporary (HTTP_302).
  #       status_code = string
  #       # (Optional) Hostname. This component is not percent-encoded. The hostname can contain #{host}. Defaults to #{host}.
  #       host = optional(string)
  #       # (Optional) Absolute path, starting with the leading "/". This component is not percent-encoded. The path can contain #{host}, #{path}, and #{port}. Defaults to /#{path}.
  #       path = optional(string)
  #       # (Optional) Port. Specify a value from 1 to 65535 or #{port}. Defaults to #{port}.
  #       port = optional(string)
  #       # (Optional) Protocol. Valid values are HTTP, HTTPS, or #{protocol}. Defaults to #{protocol}.
  #       protocol = optional(string)
  #       # (Optional) Query parameters, URL-encoded when necessary, but not percent-encoded. Do not include the leading "?". Defaults to #{query}.
  #       query = optional(string)
  #     }))
  #   })

  #   # One or more condition blocks can be set per rule.
  #   # Most condition types can only be specified once per rule
  #   # except for http-header and query-string which can be specified multiple times.
  #   # NOTE: Exactly one of host_header, http_header, http_request_method, path_pattern,
  #   # query_string or source_ip must be set per condition.
  #   #
  #   # (Required) A Condition block. Multiple condition blocks of different types can be set and all must be satisfied for the rule to match.
  #   conditions = list({
  #     # (Optional) Contains a single values item which is a list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied.
  #     host_header = optional(object({
  #       values = set(string)
  #     }))
  #     # (Optional) HTTP headers to match.
  #     http_header = optional(object({
  #       # (Required) Name of HTTP header to search. The maximum size is 40 characters. Comparison is case insensitive. Only RFC7240 characters are supported. Wildcards are not supported. You cannot use HTTP header condition to specify the host header, use a host-header condition instead.
  #       http_header_name = string
  #       # (Required) List of header value patterns to match. Maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). If the same header appears multiple times in the request they will be searched in order until a match is found. Only one pattern needs to match for the condition to be satisfied. To require that all of the strings are a match, create one condition block per string.
  #       values = set(string)
  #     }))
  #     # (Optional) Contains a single values item which is a list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (_). Comparison is case sensitive. Wildcards are not supported. Only one needs to match for the condition to be satisfied. AWS recommends that GET and HEAD requests are routed in the same way because the response to a HEAD request may be cached.
  #     http_request_method = optional(object({
  #       values = set(string)
  #     }))
  #     # (Optional) Contains a single values item which is a list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied. Path pattern is compared only to the path of the URL, not to its query string. To compare against the query string, use a query_string condition.
  #     path_pattern = optional(object({
  #       values = set(string)
  #     }))
  #     # (Required) Query string pairs or values to match. Multiple values blocks can be specified, see example above. Maximum size of each string is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). To search for a literal '*' or '?' character in a query string, escape the character with a backslash (\). Only one pair needs to match for the condition to be satisfied.
  #     query_string = optional(object({
  #       # (Optional) Query string key pattern to match.
  #       key = optional(string)
  #       # (Required) Query string value pattern to match.
  #       value = string
  #     }))
  #     # (Optional) Contains a single values item which is a list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported. Condition is satisfied if the source IP address of the request matches one of the CIDR blocks. Condition is not satisfied by the addresses in the X-Forwarded-For header, use http_header condition instead.
  #     source_ip = optional(object({
  #       values = set(string)
  #     }))
  #   })

  #   # (Optional) Information for creating an authenticate action using Cognito.
  #   authenticate_cognito = object({
  #     # (Required) Authorization endpoint of the IdP.
  #     authorization_endpoint = string
  #     # (Optional) Query parameters to include in the redirect request to the authorization endpoint. Max: 10.
  #     authentication_request_extra_params = optional(list(object({
  #       key   = string
  #       value = string
  #     })))
  #     # (Required) OAuth 2.0 client identifier.
  #     client_id = string
  #     # (Required) OAuth 2.0 client secret.
  #     client_secret = string
  #     # (Required) OAuth 2.0 client secret.
  #     issuer = string
  #     # (Optional) Behavior if the user is not authenticated. Valid values are 'deny', 'allow' and 'authenticate'.
  #     on_unauthenticated_request = optional(string)
  #     # (Optional) Set of user claims to be requested from the IdP.
  #     scope = optional(string)
  #     # (Optional) Name of the cookie used to maintain session information.
  #     session_cookie_name = optional(string)
  #     # (Optional) Maximum duration of the authentication session, inseconds.
  #     session_timeout = optional(number)
  #     # (Required) Token endpoint of the IdP.
  #     token_endpoint = string
  #     # (Required) User info endpoint of the IdP.
  #     user_info_endpoint = string
  #   })

  #   (Optional) A map of tags to apply to the 'aws_lb_listener_rule' resource.
  #   tags = map(string)
  # }))
  type    = any
  default = []
}

variable "tags" {
  description = "(Optional) A map of tags to apply to the 'aws_lb_listener' resource. Default is {}."
  type        = map(string)
  default     = {}
}

variable "rules_tags" {
  description = "(Optional) A map of tags to apply to all 'aws_lb_listener_rule' resources. Default is {}."
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# MODULE CONFIGURATION PARAMETERS
# These variables are used to configure the module.
# See https://medium.com/mineiros/the-ultimate-guide-on-how-to-write-terraform-modules-part-1-81f86d31f024
# ----------------------------------------------------------------------------------------------------------------------

variable "module_enabled" {
  type        = bool
  description = "(Optional) Whether to create resources within the module or not."
  default     = true
}

variable "module_tags" {
  type        = map(string)
  description = "(Optional) A map of tags that will be applied to all created resources that accept tags. Tags defined with 'module_tags' can be overwritten by resource-specific tags."
  default     = {}
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on."
  default     = []
}
