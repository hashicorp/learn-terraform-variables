# Learn Terraform variables

You can use input variables to customize your Terraform configuration with
values that can be assigned by end users of your configuration. Input variables
allow users to re-use and customize configuration by providing a consistent
interface to change how a given configuration behaves.

Follow along with this [Learn Terraform variables](https://developer.hashicorp.com/terraform/tutorials/configuration-language/variables) tutorial.

# Proposed Changes
- Remove "enable_classiclink" and "enable_classiclink_dns_support" in .terraform/modules/vpc/main.tf line 35,36 and 1246
- Change domain = "eip" to domain = "vpc" on line 1013
