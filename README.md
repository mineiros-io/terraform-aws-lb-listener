[<img src="https://raw.githubusercontent.com/mineiros-io/brand/3bffd30e8bdbbde32c143e2650b2faa55f1df3ea/mineiros-primary-logo.svg" width="400"/>](https://mineiros.io/?ref=terraform-aws-lb-listener)

[![Build Status](https://github.com/mineiros-io/terraform-aws-lb-listener/workflows/Tests/badge.svg)](https://github.com/mineiros-io/terraform-aws-lb-listener/actions)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/mineiros-io/terraform-aws-lb-listener.svg?label=latest&sort=semver)](https://github.com/mineiros-io/terraform-aws-lb-listener/releases)
[![Terraform Version](https://img.shields.io/badge/Terraform-1.x-623CE4.svg?logo=terraform)](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version](https://img.shields.io/badge/AWS-3-F8991D.svg?logo=terraform)](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Join Slack](https://img.shields.io/badge/slack-@mineiros--community-f32752.svg?logo=slack)](https://mineiros.io/slack)

# terraform-aws-lb-listener

A [Terraform] module to create and manage an
[Application Load Balancer Listener](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
on [Amazon Web Services (AWS)][aws].

**_This module supports Terraform version 1
and is compatible with the Terraform AWS Provider version 3.40._**

This module is part of our Infrastructure as Code (IaC) framework
that enables our users and customers to easily deploy and manage reusable,
secure, and production-grade cloud infrastructure.


- [Module Features](#module-features)
- [Getting Started](#getting-started)
- [Module Argument Reference](#module-argument-reference)
  - [Main Resource Configuration](#main-resource-configuration)
  - [Extended Resource Configuration](#extended-resource-configuration)
  - [Module Configuration](#module-configuration)
- [Module Outputs](#module-outputs)
- [External Documentation](#external-documentation)
  - [AWS Documentation](#aws-documentation)
  - [Terraform AWS Provider Documentation](#terraform-aws-provider-documentation)
- [Module Versioning](#module-versioning)
  - [Backwards compatibility in `0.0.z` and `0.y.z` version](#backwards-compatibility-in-00z-and-0yz-version)
- [About Mineiros](#about-mineiros)
- [Reporting Issues](#reporting-issues)
- [Contributing](#contributing)
- [Makefile Targets](#makefile-targets)
- [License](#license)

## Module Features

This module implements the following Terraform resources:

- `aws_lb_listener`
- `aws_lb_listener_certificate`
- `lb_listener_rule`

## Getting Started

Most common usage of the module:

```hcl
module "terraform-aws-lb-listener" {
  source = "git@github.com:mineiros-io/terraform-aws-lb-listener.git?ref=v0.0.1"

  load_balancer_arn = "load-balancer-arn"
}
```

## Module Argument Reference

See [variables.tf] and [examples/] for details and use-cases.

### Main Resource Configuration

- [**`load_balancer_arn`**](#var-load_balancer_arn): *(**Required** `string`)*<a name="var-load_balancer_arn"></a>

  The ARN of the load balancer. Forces new resource creation.

- [**`port`**](#var-port): *(Optional `number`)*<a name="var-port"></a>

  Port on which the load balancer is listening. Not valid for Gateway
  Load Balancers.

- [**`protocol`**](#var-protocol): *(Optional `string`)*<a name="var-protocol"></a>

  Protocol for connections from clients to the load balancer. For
  Application Load Balancers, valid values are `HTTP` and `HTTPS`. For
  Network Load Balancers, valid values are `TCP`, `TLS`, `UDP`, and
  `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is
  enabled. Not valid for Gateway Load Balancers.

- [**`certificate_arn`**](#var-certificate_arn): *(Optional `string`)*<a name="var-certificate_arn"></a>

  ARN of the default SSL server certificate. Exactly one certificate is
  required if the protocol is `HTTPS`.

- [**`alpn_policy`**](#var-alpn_policy): *(Optional `string`)*<a name="var-alpn_policy"></a>

  Name of the Application-Layer Protocol Negotiation (ALPN) policy. Can
  be set if `protocol` is set to `TLS`. Valid values are `HTTP1Only`,
  `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`.

  Default is `"None"`.

- [**`ssl_policy`**](#var-ssl_policy): *(Optional `string`)*<a name="var-ssl_policy"></a>

  Name of the SSL Policy for the listener. Required if protocol is
  `HTTPS` or `TLS`.

  Default is `"ELBSecurityPolicy-2016-08"`.

- [**`additional_certificates_arns`**](#var-additional_certificates_arns): *(Optional `set(string)`)*<a name="var-additional_certificates_arns"></a>

  The ARNs of the additional certificates to attach to the listener.

  Default is `[]`.

- [**`default_action`**](#var-default_action): *(Optional `object(default_action)`)*<a name="var-default_action"></a>

  Configuration block for default actions.

  Default is `{"fixed_response":{"content_type":"plain/text","message_body":"Nothing to see here!","status_code":418}}`.

  The `default_action` object accepts the following attributes:

  - [**`type`**](#attr-default_action-type): *(**Required** `string`)*<a name="attr-default_action-type"></a>

    Type of routing action. Valid values are `forward`, `redirect`,
    `fixed-response`, `authenticate-cognito` and `authenticate-oidc`.

  - [**`target_group_arn`**](#attr-default_action-target_group_arn): *(Optional `string`)*<a name="attr-default_action-target_group_arn"></a>

    ARN of the Target Group to which to route traffic. Specify only if
    `type` is `forward` and you want to route to a single target group.
    To route to one or more target groups, use a `forward` block instead.

  - [**`order`**](#attr-default_action-order): *(Optional `number`)*<a name="attr-default_action-order"></a>

    Order for the action. This value is required for rules with multiple
    actions. The action with the lowest value for order is performed
    first. Valid values are between `1` and `50000`.

  - [**`authenticate_cognito`**](#attr-default_action-authenticate_cognito): *(Optional `object(authenticate_cognito)`)*<a name="attr-default_action-authenticate_cognito"></a>

    Configuration block for using Amazon Cognito to authenticate users.
    Specify only when `type` is `authenticate-cognito`.

    Default is `[]`.

    The `authenticate_cognito` object accepts the following attributes:

    - [**`user_pool_arn`**](#attr-default_action-authenticate_cognito-user_pool_arn): *(**Required** `string`)*<a name="attr-default_action-authenticate_cognito-user_pool_arn"></a>

      ARN of the Cognito user pool.

    - [**`user_pool_domain`**](#attr-default_action-authenticate_cognito-user_pool_domain): *(**Required** `string`)*<a name="attr-default_action-authenticate_cognito-user_pool_domain"></a>

      Domain prefix or fully-qualified domain name of the Cognito user pool.

    - [**`user_pool_client_id`**](#attr-default_action-authenticate_cognito-user_pool_client_id): *(**Required** `string`)*<a name="attr-default_action-authenticate_cognito-user_pool_client_id"></a>

      Domain prefix or fully-qualified domain name of the Cognito user
      pool.

    - [**`authentication_request_extra_params`**](#attr-default_action-authenticate_cognito-authentication_request_extra_params): *(Optional `map(string)`)*<a name="attr-default_action-authenticate_cognito-authentication_request_extra_params"></a>

      Query parameters to include in the redirect request to the
      authorization endpoint. Max: 10.

    - [**`on_unauthenticated_request`**](#attr-default_action-authenticate_cognito-on_unauthenticated_request): *(Optional `string`)*<a name="attr-default_action-authenticate_cognito-on_unauthenticated_request"></a>

      Behavior if the user is not authenticated. Valid values are `deny`,
      `allow` and `authenticate`.

    - [**`scope`**](#attr-default_action-authenticate_cognito-scope): *(Optional `string`)*<a name="attr-default_action-authenticate_cognito-scope"></a>

      Set of user claims to be requested from the IdP.

    - [**`session_cookie_name`**](#attr-default_action-authenticate_cognito-session_cookie_name): *(Optional `string`)*<a name="attr-default_action-authenticate_cognito-session_cookie_name"></a>

      Name of the cookie used to maintain session information.

    - [**`session_timeout`**](#attr-default_action-authenticate_cognito-session_timeout): *(Optional `number`)*<a name="attr-default_action-authenticate_cognito-session_timeout"></a>

      Maximum duration of the authentication session, in seconds.

  - [**`authenticate_oidc`**](#attr-default_action-authenticate_oidc): *(Optional `object(authenticate_oidc)`)*<a name="attr-default_action-authenticate_oidc"></a>

    Configuration block for an identity provider that is compliant with
    OpenID Connect (OIDC). Specify only when `type` is
    `authenticate-oidc`.

    Default is `[]`.

    The `authenticate_oidc` object accepts the following attributes:

    - [**`authorization_endpoint`**](#attr-default_action-authenticate_oidc-authorization_endpoint): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-authorization_endpoint"></a>

      Authorization endpoint of the IdP.

    - [**`client_id`**](#attr-default_action-authenticate_oidc-client_id): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-client_id"></a>

      OAuth 2.0 client identifier.

    - [**`client_secret`**](#attr-default_action-authenticate_oidc-client_secret): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-client_secret"></a>

      OAuth 2.0 client secret.

    - [**`issuer`**](#attr-default_action-authenticate_oidc-issuer): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-issuer"></a>

      OIDC issuer identifier of the IdP.

    - [**`authentication_request_extra_params`**](#attr-default_action-authenticate_oidc-authentication_request_extra_params): *(Optional `map(string)`)*<a name="attr-default_action-authenticate_oidc-authentication_request_extra_params"></a>

      Query parameters to include in the redirect request to the
      authorization endpoint. Max: 10.

    - [**`on_unauthenticated_request`**](#attr-default_action-authenticate_oidc-on_unauthenticated_request): *(Optional `string`)*<a name="attr-default_action-authenticate_oidc-on_unauthenticated_request"></a>

      Behavior if the user is not authenticated. Valid values: `deny`,
      `allow` and `authenticate`.

    - [**`scope`**](#attr-default_action-authenticate_oidc-scope): *(Optional `string`)*<a name="attr-default_action-authenticate_oidc-scope"></a>

      Set of user claims to be requested from the IdP.

    - [**`session_cookie_name`**](#attr-default_action-authenticate_oidc-session_cookie_name): *(Optional `string`)*<a name="attr-default_action-authenticate_oidc-session_cookie_name"></a>

      Name of the cookie used to maintain session information.

    - [**`session_timeout`**](#attr-default_action-authenticate_oidc-session_timeout): *(Optional `number`)*<a name="attr-default_action-authenticate_oidc-session_timeout"></a>

      Maximum duration of the authentication session, in seconds.

    - [**`token_endpoint`**](#attr-default_action-authenticate_oidc-token_endpoint): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-token_endpoint"></a>

      Token endpoint of the IdP.

    - [**`user_info_endpoint`**](#attr-default_action-authenticate_oidc-user_info_endpoint): *(**Required** `string`)*<a name="attr-default_action-authenticate_oidc-user_info_endpoint"></a>

      User info endpoint of the IdP.

  - [**`fixed_response`**](#attr-default_action-fixed_response): *(Optional `object(fixed_response)`)*<a name="attr-default_action-fixed_response"></a>

    Information for creating an action that returns a custom HTTP
    response. Required if `type` is `fixed-response`.

    The `fixed_response` object accepts the following attributes:

    - [**`content_type`**](#attr-default_action-fixed_response-content_type): *(**Required** `string`)*<a name="attr-default_action-fixed_response-content_type"></a>

      Content type. Valid values are `text/plain`, `text/css`,
      `text/html`, `application/javascript` and `application/json`.

    - [**`message_body`**](#attr-default_action-fixed_response-message_body): *(Optional `string`)*<a name="attr-default_action-fixed_response-message_body"></a>

      Message body.

    - [**`status_code`**](#attr-default_action-fixed_response-status_code): *(Optional `string`)*<a name="attr-default_action-fixed_response-status_code"></a>

      HTTP response code. Valid values are `2XX`, `4XX`, or `5XX`.

  - [**`forward`**](#attr-default_action-forward): *(Optional `object(forward)`)*<a name="attr-default_action-forward"></a>

    Configuration block for creating an action that distributes requests
    among one or more target groups. Specify only if `type` is `forward`.
    If you specify both `forward` block and `target_group_arn`
    attribute, you can specify only one target group using `forward` and
    it must be the same target group specified in `target_group_arn`.

    The `forward` object accepts the following attributes:

    - [**`target_groups`**](#attr-default_action-forward-target_groups): *(Optional `set(target_group)`)*<a name="attr-default_action-forward-target_groups"></a>

      Set of 1-5 target group blocks.

      Each `target_group` object in the set accepts the following attributes:

      - [**`arn`**](#attr-default_action-forward-target_groups-arn): *(**Required** `string`)*<a name="attr-default_action-forward-target_groups-arn"></a>

        ARN of the target group.

      - [**`weight`**](#attr-default_action-forward-target_groups-weight): *(Optional `number`)*<a name="attr-default_action-forward-target_groups-weight"></a>

        Weight. The range is `0` to `999`.

    - [**`stickiness`**](#attr-default_action-forward-stickiness): *(Optional `object(stickiness)`)*<a name="attr-default_action-forward-stickiness"></a>

      Configuration block for target group stickiness for the rule.

      The `stickiness` object accepts the following attributes:

      - [**`duration`**](#attr-default_action-forward-stickiness-duration): *(**Required** `number`)*<a name="attr-default_action-forward-stickiness-duration"></a>

        Time period, in seconds, during which requests from a client
        should be routed to the same target group. The range is
        `1`-`604800` seconds (7 days).

      - [**`enabled`**](#attr-default_action-forward-stickiness-enabled): *(Optional `bool`)*<a name="attr-default_action-forward-stickiness-enabled"></a>

        Whether target group stickiness is enabled.

        Default is `false`.

  - [**`redirect`**](#attr-default_action-redirect): *(Optional `object(redirect)`)*<a name="attr-default_action-redirect"></a>

    Configuration block for creating a redirect action. Required if
    `type` is `redirect`.

    The `redirect` object accepts the following attributes:

    - [**`status_code`**](#attr-default_action-redirect-status_code): *(Optional `string`)*<a name="attr-default_action-redirect-status_code"></a>

      HTTP redirect code. The redirect is either permanent (`HTTP_301`)
      or temporary (`HTTP_302`).

      Default is `"HTTP_302"`.

    - [**`host`**](#attr-default_action-redirect-host): *(Optional `string`)*<a name="attr-default_action-redirect-host"></a>

      Hostname. This component is not percent-encoded. The hostname can
      contain `#{host}`.

      Default is `"{host}"`.

    - [**`path`**](#attr-default_action-redirect-path): *(Optional `string`)*<a name="attr-default_action-redirect-path"></a>

      Absolute path, starting with the leading `"/"`. This component is
      not percent-encoded. The path can contain `#{host}`, `#{path}`,
      and `#{port}`.

      Default is `"#{path}"`.

    - [**`port`**](#attr-default_action-redirect-port): *(Optional `string`)*<a name="attr-default_action-redirect-port"></a>

      The port. Specify a value from `1` to `65535` or `#{port}`.

      Default is `"#{port}"`.

    - [**`protocol`**](#attr-default_action-redirect-protocol): *(Optional `string`)*<a name="attr-default_action-redirect-protocol"></a>

      The protocol. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`.

      Default is `"#{protocol}"`.

    - [**`query`**](#attr-default_action-redirect-query): *(Optional `string`)*<a name="attr-default_action-redirect-query"></a>

      The query parameters, URL-encoded when necessary, but not
      percent-encoded. Do not include the leading "?".

      Default is `"#{query"`.

- [**`tags`**](#var-tags): *(Optional `map(string)`)*<a name="var-tags"></a>

  A map of tags to apply to the `aws_lb_listener` resource.

  Default is `{}`.

### Extended Resource Configuration

- [**`rules`**](#var-rules): *(Optional `list(rule)`)*<a name="var-rules"></a>

  A list of rules to be attached to the created listener.

  Default is `[]`.

  Each `rule` object in the list accepts the following attributes:

  - [**`id`**](#attr-rules-id): *(**Required** `string`)*<a name="attr-rules-id"></a>

    A unique identifier for the rule

  - [**`priority`**](#attr-rules-priority): *(**Required** `number`)*<a name="attr-rules-priority"></a>

    The priority for the rule between `1` and `50000`. Leaving it unset
    will automatically set the rule with next available priority after
    currently existing highest rule. A listener can't have multiple
    rules with the same priority.

  - [**`action`**](#attr-rules-action): *(**Required** `object(action)`)*<a name="attr-rules-action"></a>

    Configuration block for default actions.

    Default is `{"fixed_response":{"content_type":"plain/text","message_body":"Nothing to see here!","status_code":418}}`.

    The `action` object accepts the following attributes:

    - [**`type`**](#attr-rules-action-type): *(**Required** `string`)*<a name="attr-rules-action-type"></a>

      Type of routing action. Valid values are `forward`, `redirect`,
      `fixed-response`, `authenticate-cognito` and `authenticate-oidc`.

    - [**`target_group_arn`**](#attr-rules-action-target_group_arn): *(Optional `string`)*<a name="attr-rules-action-target_group_arn"></a>

      ARN of the Target Group to which to route traffic. Specify only if
      `type` is `forward` and you want to route to a single target group.
      To route to one or more target groups, use a `forward` block instead.

    - [**`fixed_response`**](#attr-rules-action-fixed_response): *(Optional `object(fixed_response)`)*<a name="attr-rules-action-fixed_response"></a>

      Information for creating an action that returns a custom HTTP
      response. Required if `type` is `fixed-response`.

      The `fixed_response` object accepts the following attributes:

      - [**`content_type`**](#attr-rules-action-fixed_response-content_type): *(**Required** `string`)*<a name="attr-rules-action-fixed_response-content_type"></a>

        Content type. Valid values are `text/plain`, `text/css`,
        `text/html`, `application/javascript` and `application/json`.

      - [**`message_body`**](#attr-rules-action-fixed_response-message_body): *(Optional `string`)*<a name="attr-rules-action-fixed_response-message_body"></a>

        Message body.

      - [**`status_code`**](#attr-rules-action-fixed_response-status_code): *(Optional `string`)*<a name="attr-rules-action-fixed_response-status_code"></a>

        HTTP response code. Valid values are `2XX`, `4XX`, or `5XX`.

    - [**`forward`**](#attr-rules-action-forward): *(Optional `object(forward)`)*<a name="attr-rules-action-forward"></a>

      Configuration block for creating an action that distributes requests
      among one or more target groups. Specify only if `type` is `forward`.
      If you specify both `forward` block and `target_group_arn`
      attribute, you can specify only one target group using `forward` and
      it must be the same target group specified in `target_group_arn`.

      The `forward` object accepts the following attributes:

      - [**`target_groups`**](#attr-rules-action-forward-target_groups): *(Optional `set(target_group)`)*<a name="attr-rules-action-forward-target_groups"></a>

        Set of 1-5 target group blocks.

        Each `target_group` object in the set accepts the following attributes:

        - [**`arn`**](#attr-rules-action-forward-target_groups-arn): *(**Required** `string`)*<a name="attr-rules-action-forward-target_groups-arn"></a>

          ARN of the target group.

        - [**`weight`**](#attr-rules-action-forward-target_groups-weight): *(Optional `number`)*<a name="attr-rules-action-forward-target_groups-weight"></a>

          Weight. The range is `0` to `999`.

      - [**`stickiness`**](#attr-rules-action-forward-stickiness): *(Optional `object(stickiness)`)*<a name="attr-rules-action-forward-stickiness"></a>

        Configuration block for target group stickiness for the rule.

        The `stickiness` object accepts the following attributes:

        - [**`duration`**](#attr-rules-action-forward-stickiness-duration): *(**Required** `number`)*<a name="attr-rules-action-forward-stickiness-duration"></a>

          Time period, in seconds, during which requests from a client
          should be routed to the same target group. The range is
          `1`-`604800` seconds (7 days).

        - [**`enabled`**](#attr-rules-action-forward-stickiness-enabled): *(Optional `bool`)*<a name="attr-rules-action-forward-stickiness-enabled"></a>

          Whether target group stickiness is enabled.

          Default is `false`.

    - [**`redirect`**](#attr-rules-action-redirect): *(Optional `object(redirect)`)*<a name="attr-rules-action-redirect"></a>

      Configuration block for creating a redirect action. Required if
      `type` is `redirect`.

      The `redirect` object accepts the following attributes:

      - [**`status_code`**](#attr-rules-action-redirect-status_code): *(Optional `string`)*<a name="attr-rules-action-redirect-status_code"></a>

        HTTP redirect code. The redirect is either permanent (`HTTP_301`)
        or temporary (`HTTP_302`).

        Default is `"HTTP_302"`.

      - [**`host`**](#attr-rules-action-redirect-host): *(Optional `string`)*<a name="attr-rules-action-redirect-host"></a>

        Hostname. This component is not percent-encoded. The hostname can
        contain `#{host}`.

        Default is `"#{host}"`.

      - [**`path`**](#attr-rules-action-redirect-path): *(Optional `string`)*<a name="attr-rules-action-redirect-path"></a>

        Absolute path, starting with the leading `"/"`. This component is
        not percent-encoded. The path can contain `#{host}`, `#{path}`,
        and `#{port}`.

        Default is `"#{path}"`.

      - [**`port`**](#attr-rules-action-redirect-port): *(Optional `string`)*<a name="attr-rules-action-redirect-port"></a>

        The port. Specify a value from `1` to `65535` or `#{port}`.

        Default is `"#{port}"`.

      - [**`protocol`**](#attr-rules-action-redirect-protocol): *(Optional `string`)*<a name="attr-rules-action-redirect-protocol"></a>

        The protocol. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`.

        Default is `"#{protocol}"`.

      - [**`query`**](#attr-rules-action-redirect-query): *(Optional `string`)*<a name="attr-rules-action-redirect-query"></a>

        The query parameters, URL-encoded when necessary, but not
        percent-encoded. Do not include the leading "?".

        Default is `"#{query"`.

  - [**`conditions`**](#attr-rules-conditions): *(**Required** `set(conditions)`)*<a name="attr-rules-conditions"></a>

    A Condition block. Multiple condition blocks of different types can
    be set and all must be satisfied for the rule to match.

    Each `conditions` object in the set accepts the following attributes:

    - [**`host_header`**](#attr-rules-conditions-host_header): *(Optional `object(host_header)`)*<a name="attr-rules-conditions-host_header"></a>

      The maximum size of each pattern is 128 characters. Comparison is
      case insensitive. Wildcard characters supported: `*` (matches 0 or
      more characters) and `?` (matches exactly 1 character). Only one
      pattern needs to match for the condition to be satisfied.

      The `host_header` object accepts the following attributes:

      - [**`values`**](#attr-rules-conditions-host_header-values): *(**Required** `set(string)`)*<a name="attr-rules-conditions-host_header-values"></a>

        List of host header patterns to match.

    - [**`http_header`**](#attr-rules-conditions-http_header): *(Optional `object(http_header)`)*<a name="attr-rules-conditions-http_header"></a>

      HTTP headers to match.

      The `http_header` object accepts the following attributes:

      - [**`http_header_name`**](#attr-rules-conditions-http_header-http_header_name): *(**Required** `string`)*<a name="attr-rules-conditions-http_header-http_header_name"></a>

        Name of HTTP header to search. The maximum size is 40
        characters. Comparison is case insensitive. Only RFC7240
        characters are supported. Wildcards are not supported. You
        cannot use HTTP header condition to specify the host header,
        use a `host-header` condition instead.

      - [**`values`**](#attr-rules-conditions-http_header-values): *(**Required** `set(string)`)*<a name="attr-rules-conditions-http_header-values"></a>

        List of header value patterns to match. Maximum size of each
        pattern is 128 characters. Comparison is case insensitive.
        Wildcard characters supported: `*` (matches 0 or more
        characters) and `?` (matches exactly 1 character). If the same
        header appears multiple times in the request they will be
        searched in order until a match is found. Only one pattern
        needs to match for the condition to be satisfied. To require
        that all of the strings are a match, create one condition block
        per string.

    - [**`http_request_method`**](#attr-rules-conditions-http_request_method): *(Optional `object(http_request_method)`)*<a name="attr-rules-conditions-http_request_method"></a>

      Maximum size is 40 characters. Only allowed characters are `A-Z`,
      hyphen (`-`) and underscore (`_`). Comparison is case sensitive.
      Wildcards are not supported. Only one needs to match for the
      condition to be satisfied. AWS recommends that `GET` and `HEAD`
      requests are routed in the same way because the response to a
      `HEAD` request may be cached.

      Default is `[]`.

      The `http_request_method` object accepts the following attributes:

      - [**`values`**](#attr-rules-conditions-http_request_method-values): *(**Required** `set(string)`)*<a name="attr-rules-conditions-http_request_method-values"></a>

        List of HTTP request methods or verbs to match.

    - [**`path_pattern`**](#attr-rules-conditions-path_pattern): *(Optional `object(path_pattern)`)*<a name="attr-rules-conditions-path_pattern"></a>

      Maximum size of each pattern is `128` characters. Comparison is
      case sensitive. Wildcard characters supported: `*` (matches 0 or
      more characters) and `?` (matches exactly 1 character). Only one
      pattern needs to match for the condition to be satisfied. Path
      pattern is compared only to the path of the URL, not to its query
      string. To compare against the query string, use a
      `query_string` condition.

      Default is `[]`.

      The `path_pattern` object accepts the following attributes:

      - [**`values`**](#attr-rules-conditions-path_pattern-values): *(**Required** `set(string)`)*<a name="attr-rules-conditions-path_pattern-values"></a>

        List of path patterns to match against the request URL.

    - [**`query_string`**](#attr-rules-conditions-query_string): *(Optional `set(query_string)`)*<a name="attr-rules-conditions-query_string"></a>

      Query strings to match.

      Default is `[]`.

      Each `query_string` object in the set accepts the following attributes:

      - [**`key`**](#attr-rules-conditions-query_string-key): *(Optional `string`)*<a name="attr-rules-conditions-query_string-key"></a>

        Query string key pattern to match.

      - [**`value`**](#attr-rules-conditions-query_string-value): *(**Required** `string`)*<a name="attr-rules-conditions-query_string-value"></a>

        Query string value pattern to match.

    - [**`source_ip`**](#attr-rules-conditions-source_ip): *(Optional `object(source_ip)`)*<a name="attr-rules-conditions-source_ip"></a>

      You can use both IPv4 and IPv6 addresses. Wildcards are not
      supported. Condition is satisfied if the source IP address of the
      request matches one of the CIDR blocks. Condition is not satisfied
      by the addresses in the `X-Forwarded-For` header, use
      `http_header` condition instead.

      Default is `[]`.

      The `source_ip` object accepts the following attributes:

      - [**`values`**](#attr-rules-conditions-source_ip-values): *(**Required** `set(string)`)*<a name="attr-rules-conditions-source_ip-values"></a>

        List of source IP CIDR notations to match.

  - [**`authenticate_cognito`**](#attr-rules-authenticate_cognito): *(Optional `object(authenticate_cognito)`)*<a name="attr-rules-authenticate_cognito"></a>

    Configuration block for using Amazon Cognito to authenticate users.
    Specify only when `type` is `authenticate-cognito`.

    Default is `[]`.

    The `authenticate_cognito` object accepts the following attributes:

    - [**`user_pool_arn`**](#attr-rules-authenticate_cognito-user_pool_arn): *(**Required** `string`)*<a name="attr-rules-authenticate_cognito-user_pool_arn"></a>

      ARN of the Cognito user pool.

    - [**`user_pool_domain`**](#attr-rules-authenticate_cognito-user_pool_domain): *(**Required** `string`)*<a name="attr-rules-authenticate_cognito-user_pool_domain"></a>

      Domain prefix or fully-qualified domain name of the Cognito user pool.

    - [**`user_pool_client_id`**](#attr-rules-authenticate_cognito-user_pool_client_id): *(**Required** `string`)*<a name="attr-rules-authenticate_cognito-user_pool_client_id"></a>

      Domain prefix or fully-qualified domain name of the Cognito user
      pool.

    - [**`authentication_request_extra_params`**](#attr-rules-authenticate_cognito-authentication_request_extra_params): *(Optional `map(string)`)*<a name="attr-rules-authenticate_cognito-authentication_request_extra_params"></a>

      Query parameters to include in the redirect request to the
      authorization endpoint. Accepts a maximum of 10 extra parameters.

    - [**`on_unauthenticated_request`**](#attr-rules-authenticate_cognito-on_unauthenticated_request): *(Optional `string`)*<a name="attr-rules-authenticate_cognito-on_unauthenticated_request"></a>

      Behavior if the user is not authenticated. Valid values are `deny`,
      `allow` and `authenticate`.

    - [**`scope`**](#attr-rules-authenticate_cognito-scope): *(Optional `string`)*<a name="attr-rules-authenticate_cognito-scope"></a>

      Set of user claims to be requested from the IdP.

    - [**`session_cookie_name`**](#attr-rules-authenticate_cognito-session_cookie_name): *(Optional `string`)*<a name="attr-rules-authenticate_cognito-session_cookie_name"></a>

      Name of the cookie used to maintain session information.

    - [**`session_timeout`**](#attr-rules-authenticate_cognito-session_timeout): *(Optional `number`)*<a name="attr-rules-authenticate_cognito-session_timeout"></a>

      Maximum duration of the authentication session, in seconds.

  - [**`authenticate_oidc`**](#attr-rules-authenticate_oidc): *(Optional `object(authenticate_oidc)`)*<a name="attr-rules-authenticate_oidc"></a>

    Configuration block for an identity provider that is compliant with
    OpenID Connect (OIDC). Specify only when `type` is
    `authenticate-oidc`.

    Default is `[]`.

    The `authenticate_oidc` object accepts the following attributes:

    - [**`authorization_endpoint`**](#attr-rules-authenticate_oidc-authorization_endpoint): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-authorization_endpoint"></a>

      Authorization endpoint of the IdP.

    - [**`client_id`**](#attr-rules-authenticate_oidc-client_id): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-client_id"></a>

      OAuth 2.0 client identifier.

    - [**`client_secret`**](#attr-rules-authenticate_oidc-client_secret): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-client_secret"></a>

      OAuth 2.0 client secret.

    - [**`issuer`**](#attr-rules-authenticate_oidc-issuer): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-issuer"></a>

      OIDC issuer identifier of the IdP.

    - [**`authentication_request_extra_params`**](#attr-rules-authenticate_oidc-authentication_request_extra_params): *(Optional `map(string)`)*<a name="attr-rules-authenticate_oidc-authentication_request_extra_params"></a>

      Query parameters to include in the redirect request to the
      authorization endpoint. Max: 10.

    - [**`on_unauthenticated_request`**](#attr-rules-authenticate_oidc-on_unauthenticated_request): *(Optional `string`)*<a name="attr-rules-authenticate_oidc-on_unauthenticated_request"></a>

      Behavior if the user is not authenticated. Valid values: `deny`,
      `allow` and `authenticate`.

    - [**`scope`**](#attr-rules-authenticate_oidc-scope): *(Optional `string`)*<a name="attr-rules-authenticate_oidc-scope"></a>

      Set of user claims to be requested from the IdP.

    - [**`session_cookie_name`**](#attr-rules-authenticate_oidc-session_cookie_name): *(Optional `string`)*<a name="attr-rules-authenticate_oidc-session_cookie_name"></a>

      Name of the cookie used to maintain session information.

    - [**`session_timeout`**](#attr-rules-authenticate_oidc-session_timeout): *(Optional `number`)*<a name="attr-rules-authenticate_oidc-session_timeout"></a>

      Maximum duration of the authentication session, in seconds.

    - [**`token_endpoint`**](#attr-rules-authenticate_oidc-token_endpoint): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-token_endpoint"></a>

      Token endpoint of the IdP.

    - [**`user_info_endpoint`**](#attr-rules-authenticate_oidc-user_info_endpoint): *(**Required** `string`)*<a name="attr-rules-authenticate_oidc-user_info_endpoint"></a>

      User info endpoint of the IdP.

- [**`rules_tags`**](#var-rules_tags): *(Optional `map(string)`)*<a name="var-rules_tags"></a>

  A map of tags to apply to all `aws_lb_listener_rule` resources.

  Default is `{}`.

### Module Configuration

- [**`module_enabled`**](#var-module_enabled): *(Optional `bool`)*<a name="var-module_enabled"></a>

  Specifies whether resources in the module will be created.

  Default is `true`.

- [**`module_tags`**](#var-module_tags): *(Optional `map(string)`)*<a name="var-module_tags"></a>

  A map of tags that will be applied to all created resources that accept tags.
  Tags defined with `module_tags` can be overwritten by resource-specific tags.

  Default is `{}`.

  Example:

  ```hcl
  module_tags = {
    environment = "staging"
    team        = "platform"
  }
  ```

- [**`module_depends_on`**](#var-module_depends_on): *(Optional `list(dependency)`)*<a name="var-module_depends_on"></a>

  A list of dependencies.
  Any object can be _assigned_ to this list to define a hidden external dependency.

  Default is `[]`.

  Example:

  ```hcl
  module_depends_on = [
    null_resource.name
  ]
  ```

## Module Outputs

The following attributes are exported in the outputs of the module:

- [**`lb_listener_rule`**](#output-lb_listener_rule): *(`object(lb_listener_rule)`)*<a name="output-lb_listener_rule"></a>

  All outputs of the created 'aws_lb_listener_rule' resource.

- [**`module_enabled`**](#output-module_enabled): *(`bool`)*<a name="output-module_enabled"></a>

  Whether this module is enabled.

- [**`module_tags`**](#output-module_tags): *(`map(string)`)*<a name="output-module_tags"></a>

  The map of tags that are being applied to all created resources that accept tags.

## External Documentation

### AWS Documentation

- https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html

### Terraform AWS Provider Documentation

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule

## Module Versioning

This Module follows the principles of [Semantic Versioning (SemVer)].

Given a version number `MAJOR.MINOR.PATCH`, we increment the:

1. `MAJOR` version when we make incompatible changes,
2. `MINOR` version when we add functionality in a backwards compatible manner, and
3. `PATCH` version when we make backwards compatible bug fixes.

### Backwards compatibility in `0.0.z` and `0.y.z` version

- Backwards compatibility in versions `0.0.z` is **not guaranteed** when `z` is increased. (Initial development)
- Backwards compatibility in versions `0.y.z` is **not guaranteed** when `y` is increased. (Pre-release)

## About Mineiros

[Mineiros][homepage] is a remote-first company headquartered in Berlin, Germany
that solves development, automation and security challenges in cloud infrastructure.

Our vision is to massively reduce time and overhead for teams to manage and
deploy production-grade and secure cloud infrastructure.

We offer commercial support for all of our modules and encourage you to reach out
if you have any questions or need help. Feel free to email us at [hello@mineiros.io] or join our
[Community Slack channel][slack].

## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Contributing

Contributions are always encouraged and welcome! For the process of accepting changes, we use
[Pull Requests]. If you'd like more information, please see our [Contribution Guidelines].

## Makefile Targets

This repository comes with a handy [Makefile].
Run `make help` to see details on each available target.

## License

[![license][badge-license]][apache20]

This module is licensed under the Apache License Version 2.0, January 2004.
Please see [LICENSE] for full details.

Copyright &copy; 2020-2022 [Mineiros GmbH][homepage]


<!-- References -->

[homepage]: https://mineiros.io/?ref=terraform-aws-lb-listener
[hello@mineiros.io]: mailto:hello@mineiros.io
[badge-license]: https://img.shields.io/badge/license-Apache%202.0-brightgreen.svg
[releases-terraform]: https://github.com/hashicorp/terraform/releases
[releases-aws-provider]: https://github.com/terraform-providers/terraform-provider-aws/releases
[apache20]: https://opensource.org/licenses/Apache-2.0
[slack]: https://mineiros.io/slack
[terraform]: https://www.terraform.io
[aws]: https://aws.amazon.com/
[semantic versioning (semver)]: https://semver.org/
[variables.tf]: https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/variables.tf
[examples/]: https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/examples
[issues]: https://github.com/mineiros-io/terraform-aws-lb-listener/issues
[license]: https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/LICENSE
[makefile]: https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/Makefile
[pull requests]: https://github.com/mineiros-io/terraform-aws-lb-listener/pulls
[contribution guidelines]: https://github.com/mineiros-io/terraform-aws-lb-listener/blob/main/CONTRIBUTING.md
