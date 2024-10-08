# Usecase 3 - Unauthorized Secret Store Access
# create a random lowercase id for the secret

resource "random_id" "uc3_secret" {
  count       = var.uc3_config.enable ? 1 : 0
  byte_length = 2
}


resource "google_secret_manager_secret" "uc3_secret" {
  count     = var.uc3_config.enable ? 1 : 0
  secret_id = local.uc3_secret_id
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }


}

# create a random version for the secret

resource "random_id" "uc3_secret_version" {
  count       = var.uc3_config.enable ? 1 : 0
  byte_length = 32
}

resource "google_secret_manager_secret_version" "uc3_secret_version" {
  count       = var.uc3_config.enable ? 1 : 0
  secret      = google_secret_manager_secret.uc3_secret[0].name
  secret_data = base64encode(random_id.uc3_secret_version[0].hex)
}


locals {
  uc3_secret_id = replace(replace(format("%s-%s", var.uc3_config.secret_id, random_id.uc3_secret[0].id), " ", "_"), "-", "_") # replace spaces and hyphens with underscores

  uc3_log_sink_filter = try(<<EOF

  (protoPayload.resourceName:"${google_secret_manager_secret.uc3_secret[0].name}" AND  (
  protoPayload.methodName=("google.cloud.secretmanager.v1.SecretManagerService.EnableSecretVersion" OR  "google.cloud.secretmanager.v1.SecretManagerService.AddSecretVersion" OR  "google.cloud.secretmanager.v1.SecretManagerService.DisableSecretVersion" OR  "google.iam.admin.v1.GetPolicyDetails" OR  "google.cloud.location.Locations.GetLocation" OR  "google.cloud.location.Locations.ListLocations" OR  "google.cloud.secretmanager.v1.SecretManagerService.GetIamPolicy" OR  "google.cloud.secretmanager.v1.SecretManagerService.GetSecret" OR  "google.cloud.secretmanager.v1.SecretManagerService.GetSecretVersion" OR  "google.cloud.secretmanager.v1.SecretManagerService.ListSecretVersions" OR  "google.cloud.secretmanager.v1.SecretManagerService.ListSecrets" OR  "google.cloud.secretmanager.v1.SecretManagerService.CreateSecret" OR  "google.cloud.secretmanager.v1.SecretManagerService.DeleteSecret" OR  "google.cloud.secretmanager.v1.SecretManagerService.DestroySecretVersion" OR  "google.cloud.secretmanager.v1.SecretManagerService.SetIamPolicy" OR  "google.cloud.secretmanager.v1.SecretManagerService.UpdateSecret" OR  "google.cloud.secretmanager.v1.SecretManagerService.AccessSecretVersion")))

EOF
  , "")
}






#https://cloud.google.com/secret-manager/docs/audit-logging#permission-type
resource "google_project_iam_audit_config" "secret_manager" {
  count   = var.uc3_config.enable_audit_logging ? 1 : 0
  project = data.google_project.this.project_id

  service = "secretmanager.googleapis.com"
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
