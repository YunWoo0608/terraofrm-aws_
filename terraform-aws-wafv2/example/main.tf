provider "aws" {
  region = "ap-northeast-2"
}

provider "random" {}

resource "random_string" "random" {
  length  = 4
  special = false
}

locals {
  visibility_config = {
    cloudwatch_metrics_enabled = true,
    sampled_requests_enabled   = true
  }
}

module "status" {
  source = "../"

  # tag
  env     = "test"
  team    = "devops"
  purpose = "wafv2"
  prefix  = "test"

  # logging
  logging_retention_in_days = 90

  # web_acl
  web_acl_config = {
    name           = "test"
    scope          = "REGIONAL"
    default_action = "block"
    managed_rules = [
      {
        name            = "AWSManagedRulesCommonRuleSet"
        priority        = 10
        override_action = "none"
        excluded_rules  = []

        visibility_config = local.visibility_config
      },
    ]
    ip_sets = [
      {
        name     = "test-ipset"
        priority = 20
        action   = "allow"

        visibility_config = {
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = false
        }
      },
    ]
    # required 
    rule_groups = [
      {
        priority        = 1
        override_action = "none"
        excluded_rules  = []

        visibility_config = local.visibility_config
      },
    ]
    visibility_config = local.visibility_config
  }

  # ip_set
  ip_set_v1_config = []
  ip_set_v2_config = [
    {
      description        = "test wafv2 ipset"
      scope              = "REGIONAL"
      ip_address_version = "IPV4"
      addresses          = ["33.23.21.13/32", "33.23.21.14/32"]
    },
  ]
  # regex_pattern_set 
  regex_pattern_set_config = {
    "test" = {
      name     = "test"
      scope    = "REGIONAL"
      arn      = null
      priority = 50
      action   = "allow"
      regular_expression_list = [
        "^\\/test\\/login1$",
        "^\\/test\\/login2$",
        "^\\/test\\/login3$",
        "^\\/test\\/login4$",
        "^\\/test\\/login5$",
        "^\\/test\\/login6$",
        "^\\/test\\/login7$",
        "^\\/test\\/login8$",
        "^\\/test\\/login9$",
      ]
      regex_pattern_set_reference_statements = [
        {
          field_to_match = {
            method = "uri_path"
          }
          text_transformation = {
            priority = 0
            type     = "NONE"
          }
        }
      ]
      visibility_config = local.visibility_config
    }
    "test2" = {
      name     = "test2"
      scope    = "REGIONAL"
      arn      = null
      priority = 50
      action   = "allow"
      regular_expression_list = [
        "^\\/test\\/login21$",
        "^\\/test\\/login22$",
        "^\\/test\\/login23$",
        "^\\/test\\/login24$",
        "^\\/test\\/login25$",
        "^\\/test\\/login26$",
        "^\\/test\\/login27$",
        "^\\/test\\/login28$",
        "^\\/test\\/login29$",
      ]
      regex_pattern_set_reference_statements = [
        {
          field_to_match = {
            method = "uri_path"
          }
          text_transformation = {
            priority = 0
            type     = "NONE"
          }
        }
      ]
      visibility_config = local.visibility_config
    }
  }

  # rule group
  rule_group_v1_config = []
  rule_group_v2_config = [
    {
      name        = "test"
      description = "test"
      scope       = "REGIONAL"
      capacity    = 100
      priority    = 1

      visibility_config = local.visibility_config

      rules = [
        {
          and_or            = "or"
          name              = "rule-1"
          priority          = 0
          action            = "allow"
          visibility_config = local.visibility_config

          statements = {
            byte_match_statements = [
              {
                positional_constraint = "EXACTLY"
                search_string         = "/test/login1"

                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              },
              {
                positional_constraint = "EXACTLY"
                search_string         = "/test/login2"

                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
            regex_pattern_set_reference_statements = [
              {
                regex_set_key = "test"
                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
          }
        },
        {
          and_or            = "or"
          name              = "rule-2"
          priority          = 1
          action            = "allow"
          visibility_config = local.visibility_config

          statements = {
            byte_match_statements = [
              {
                positional_constraint = "EXACTLY"
                search_string         = "/test/login1"

                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              },
              {
                positional_constraint = "EXACTLY"
                search_string         = "/test/login2"

                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
            regex_pattern_set_reference_statements = [
              {
                regex_set_key = "test2"
                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
          }
        },
      ]
    },
  ]
}

