# Usecase 2 - Malicious Assume Service Account

# Create a service account that can be assumed by anyone in the organization , without any permissions.
# When someone assumes this SA, it should trigger an alert.


# Create an SA that can be assumed by anyone in the organization , without any permissions.

# this service account can have WIF in order to allow any gke cluster workload to assume it

#to do this, you need to specify the namespace and the k8s service account name in the wif configuration of the use case

# the module does not interact with the k8s cluster! it only creates the necessary IAM bindings in GCP. this means that you need to specify a namespace and a service account that already exists in the k8s cluster, and annotate it with the following command:


#k annotate serviceaccount <k8s-sa-name> iam.gke.io/gcp-service-account=<sa-email>






# create a random lowercase id for the role
resource "random_id" "uc2" {
  count       = var.uc2_config.enable ? 1 : 0
  byte_length = 2
}

resource "google_service_account" "uc2_sa" {
  count        = var.uc2_config.enable ? 1 : 0
  account_id   = lower(replace(replace(format("%s-%s", var.uc2_config.sa_name, (random_id.uc2[0].id)), "_", "-"), " ", "-")) # replace spaces and underscores with hyphens
  display_name = format("%s", var.uc2_config.sa_name)
}

# create a custom role that has no permissions

resource "google_project_iam_custom_role" "uc2_role" {
  count       = var.uc2_config.enable ? 1 : 0
  role_id     = replace(replace(var.uc2_config.role_title, " ", "_"), "-", "_") # replace spaces and hyphens with underscores
  title       = var.uc2_config.role_title
  description = var.uc2_config.role_description
  permissions = var.uc2_config.role_permissions
}

# assign the custom role to the SA

resource "google_project_iam_member" "uc2_role" {
  count   = var.uc2_config.enable ? 1 : 0
  project = data.google_project.this.project_id
  role    = google_project_iam_custom_role.uc2_role[0].name
  member  = format("serviceAccount:%s", google_service_account.uc2_sa[0].email)
}






locals {



  uc2_log_sink_filter = try(<<EOF
  (protoPayload.authenticationInfo.principalEmail="${google_service_account.uc2_sa[0].email}" OR (protoPayload.authorizationInfo.permission="iam.serviceAccounts.getAccessToken" AND protoPayload.request.name="projects/-/serviceAccounts/${google_service_account.uc2_sa[0].email}") OR (protoPayload.resourceName="projects/${data.google_project.this.project_id}/roles/${google_service_account.uc2_sa[0].display_name}" AND protoPayload.methodName="google.iam.admin.v1.GetRole") OR (protoPayload.methodName="GenerateIdToken" AND protoPayload.metadata.identityDelegationChain="projects/-/serviceAccounts/${google_service_account.uc2_sa[0].email}"))
EOF
  , "")

  uc2_allowed_domains = var.uc2_config.enable ? coalesce(var.uc2_config.allowed_domains, var.allowed_domains) : []
}

# add the necessary permissions  so anyone in the organization can assume the SA
resource "google_service_account_iam_member" "uc2_allowed_domain" {
  for_each           = toset(local.uc2_allowed_domains)
  service_account_id = google_service_account.uc2_sa[0].account_id
  member             = format("domain:%s", each.value)
  role               = "roles/iam.serviceAccountTokenCreator"
}



#https://cloud.google.com/iam/docs/audit-logging#permission-type
resource "google_project_iam_audit_config" "logging" {
  count   = var.uc2_config.enable_audit_logging ? 1 : 0
  project = data.google_project.this.project_id

  service = "logging.googleapis.com"
  audit_log_config {
    log_type = "ADMIN_READ"
  }
  audit_log_config {
    log_type = "DATA_READ"
  }
  audit_log_config {
    log_type = "DATA_WRITE"
  }
}




# wif configuration

# gcloud iam service-accounts add-iam-policy-binding sa-gcp-test@$PROJECT_ID.iam.gserviceaccount.com --role roles/iam.workloadIdentityUser --member "serviceAccount:$PROJECT_ID.svc.id.goog[default/sa-k8-test]"


resource "google_service_account_iam_member" "name" {
  for_each = var.uc2_config.enable && var.uc2_config.wif.enable ? var.uc2_config.wif.clusters : {}

  service_account_id = google_service_account.uc2_sa[0].name
  member             = format("serviceAccount:%s.svc.id.goog[%s/%s]", data.google_project.this.project_id, each.value.namespace, each.value.service_account)
  role               = "roles/iam.workloadIdentityUser"
}
