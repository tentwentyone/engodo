<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_logging_project_sink.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_project_iam_audit_config.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_project_iam_audit_config.secret_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_project_iam_audit_config.storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_project_iam_custom_role.uc2_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.uc2_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_topic.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_secret_manager_secret.uc3_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_version.uc3_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [google_service_account.uc2_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.uc2_allowed_domain](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.uc1_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.uc1_allowed_domain](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_object.uc1_bucket_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object) | resource |
| [random_id.uc1_bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.uc2](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.uc3_secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.uc3_secret_version](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_pet.uc1_bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_organization.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/organization) | data source |
| [google_project.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of domains that should be allowed to access the resources. | `list` | `[]` | no |
| <a name="input_organization_domain_id"></a> [organization\_domain\_id](#input\_organization\_domain\_id) | The id domain of the organization. | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be used for all resources not belonging to a specific usecase. | `string` | `"engodo"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resources will be created. | `string` | `"europe-west1"` | no |
| <a name="input_uc1_config"></a> [uc1\_config](#input\_uc1\_config) | Configuration for Use Case 1 - Unauthorized Bucket Access | <pre>object({<br/>    enable               = optional(bool, true)<br/>    bucket_name          = optional(string, "") # if empty, a random name will be generated<br/>    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for cloud storage<br/>    allowed_domains      = optional(list(string), null)<br/>  })</pre> | `{}` | no |
| <a name="input_uc2_config"></a> [uc2\_config](#input\_uc2\_config) | Configuration for Use Case 2 - Malicious Assume Service Account | <pre>object({<br/>    enable               = optional(bool, true)<br/>    role_title           = optional(string, "Organization Admin")<br/>    role_description     = optional(string, "Full access to all organization resources, including administrative tasks, financial data, and sensitive services. Be cautious with its usage.")<br/>    role_permissions     = optional(list(string), ["storage.buckets.list"])<br/>    sa_name              = optional(string, "devops mgmt pipeline")<br/>    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for iam<br/>    allowed_domains      = optional(list(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_uc3_config"></a> [uc3\_config](#input\_uc3\_config) | Configuration for Use Case 3 - Unauthorized Secret Store Access | <pre>object({<br/>    enable               = optional(bool, true)<br/>    secret_id            = optional(string, "Github Organization Token")<br/>    secret_content       = optional(string, "") # if empty, a random content will be generated<br/>    enable_audit_logging = optional(bool, true) # enable `ADMIN_READ`, `DATA_READ`, `DATA_WRITE` logs for secret manager<br/>  })</pre> | `{}` | no |
| <a name="input_whitelist_service_accounts"></a> [whitelist\_service\_accounts](#input\_whitelist\_service\_accounts) | List of service accounts that should be whitelisted. | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_sink_filter"></a> [log\_sink\_filter](#output\_log\_sink\_filter) | n/a |
| <a name="output_log_sink_size"></a> [log\_sink\_size](#output\_log\_sink\_size) | https://cloud.google.com/logging/quotas#:~:text=Length%20of%20a%20sink%20inclusion%20filter |
| <a name="output_organization"></a> [organization](#output\_organization) | n/a |
| <a name="output_project_info"></a> [project\_info](#output\_project\_info) | n/a |
| <a name="output_usecases"></a> [usecases](#output\_usecases) | n/a |
<!-- END_TF_DOCS -->