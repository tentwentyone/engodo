# Usecase 2 - Malicious Assume Service Account
# Create a service account that can be assumed by anyone in the organization , without any permissions.
# When someone assumes this SA, it should trigger an alert.


# Create an SA that can be assumed by anyone in the organization , without any permissions.


# generate a random name for the role

resource "random_pet" "uc_2_role" {
  count     = var.enable_uc_2 ? 1 : 0
  length    = 2
  separator = "_"
}

# create a random lowercase id for the role
resource "random_id" "uc_2_role" {
  count       = var.enable_uc_2 ? 1 : 0
  byte_length = 2
}

resource "google_service_account" "uc_2_sa" {
  count        = var.enable_uc_2 ? 1 : 0
  account_id   = format("%s-%s-%s", var.decoys_prefix, replace(random_pet.uc_2_role[0].id, "_", "-"), lower(random_id.uc_2_role[0].id))
  display_name = format("%s-%s-%s", var.decoys_prefix, replace(random_pet.uc_2_role[0].id, "_", "-"), lower(random_id.uc_2_role[0].id))
}

# create a custom role that has no permissions

resource "google_project_iam_custom_role" "uc_2_role" {
  count       = var.enable_uc_2 ? 1 : 0
  role_id     = format("%s_%s_%s", var.decoys_prefix, random_pet.uc_2_role[0].id, lower(random_id.uc_2_role[0].id))
  title       = var.uc2_config.role_title
  description = var.uc2_config.role_description
  permissions = var.uc2_config.permissions
}

# assign the custom role to the SA

resource "google_project_iam_member" "uc_2_role" {
  count   = var.enable_uc_2 ? 1 : 0
  project = data.google_project.this.project_id
  role    = google_project_iam_custom_role.uc_2_role[0].name
  member  = format("serviceAccount:%s", google_service_account.uc_2_sa[0].email)
}

locals {
  uc_2_log_sink_filter = try(<<EOF
  (protoPayload.authenticationInfo.principalEmail="${google_service_account.uc_2_sa[0].email}" OR (protoPayload.authorizationInfo.permission="iam.serviceAccounts.getAccessToken" AND protoPayload.request.name="projects/-/serviceAccounts/${google_service_account.uc_2_sa[0].email}") OR (protoPayload.resourceName="projects/ccoe-lab-000002/roles/${google_service_account.uc_2_sa[0].display_name}" AND protoPayload.methodName="google.iam.admin.v1.GetRole"))
EOF
  , "")

}
