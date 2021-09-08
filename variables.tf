# ----------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ----------------------------------------------------------------------------------------------------------------------

variable "load_balancer_arn" {
  type        = string
  description = "(Required, Forces New Resource) The ARN of the load balancer."
}

# ---------------------------------------------------------------------------------------------------------------------
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
  #   # (Required) Type of routing action. Valid values are 'forward', 'redirect', 'fixed-response'.
  #   type = string
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
  #     target_group = list(object({
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

variable "tags" {
  description = "(Optional) A map of tags to apply to the 'aws_lb_listener' resource. Default is {}."
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
  description = "(Optional) Whether to create resources within the module or not. Default is true."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(Optional) A list of external resources the module depends_on. Default is []."
  default     = []
}

variable "module_tags" {
  description = "(Optional) A map of default tags to apply to all resources created which support tags. Default is {}."
  type        = map(string)
  default     = {}
}
