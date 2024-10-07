# Usecase 1 - Unauthorized Bucket Access

# this usecase has the objective of creating a private bucket with an attractive name to attract attackers and a few dummy files in it.

# Create a private bucket with a name that is attractive to attackers
# upload a few dummy files to the bucket



#generate a random name for the bucket
resource "random_pet" "uc1_bucket" {
  count     = var.uc1_config.enable && var.uc1_config.bucket_name == "" ? 1 : 0
  length    = 2
  separator = "-"
}

# create a random lowercase id for the bucket

resource "random_id" "uc1_bucket" {
  count       = var.uc1_config.enable && var.uc1_config.bucket_name == "" ? 1 : 0
  byte_length = 2
}


resource "google_storage_bucket" "uc1_bucket" {
  #checkov:skip=CKV_GCP_62:Bucket access logs are enabled at project level
  count                       = var.uc1_config.enable ? 1 : 0
  name                        = var.uc1_config.bucket_name != "" ? var.uc1_config.bucket_name : format("%s-%s", random_pet.uc1_bucket[0].id, lower(random_id.uc1_bucket[0].id))
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  soft_delete_policy {
    retention_duration_seconds = 0
  }
  public_access_prevention = "enforced"


}

# upload all files under gcp/uc1_files to the bucket
resource "google_storage_bucket_object" "uc1_bucket_object" {
  for_each = toset(local.uc1_list_of_files)

  name   = each.key
  bucket = google_storage_bucket.uc1_bucket[0].name
  source = "${path.module}/uc1_files/${each.key}"
}




locals {
  uc1_log_sink_filter = try(<<EOF
  (proto_payload.method_name=("storage.objects.get" OR "storage.objects.update" OR "storage.objects.create" OR "storage.objects.delete" ) ${local.uc1_log_sink_files_filter} AND resource.labels.bucket_name="${google_storage_bucket.uc1_bucket[0].name}")
EOF
  , "")

  uc1_list_of_files = var.uc1_config.enable == true ? tolist(fileset("${path.module}/uc1_files", "*")) : []

  uc1_log_sink_files_filter = length(local.uc1_list_of_files) > 0 ? format(" AND protoPayload.authorizationInfo.resource:(%s)", join(" OR ", [for file in local.uc1_list_of_files : format("\"/objects/%s\"", file)])) : ""

  # defaults to var.allowed_domains if uc1_config.allowed_domains is not set , empty or null
  uc1_allowed_domains = var.uc1_config.enable ? coalesce(var.uc1_config.allowed_domains, var.allowed_domains) : []
}


# add permissons to the bucket to allow anyone in the organization to access it
resource "google_storage_bucket_iam_member" "uc1_allowed_domain" {
  for_each = toset(local.uc1_allowed_domains)
  bucket   = google_storage_bucket.uc1_bucket[0].name
  member   = format("domain:%s", each.value)
  role     = "roles/storage.objectViewer"
}



#https://cloud.google.com/storage/docs/audit-logging
resource "google_project_iam_audit_config" "storage" {
  count   = var.uc1_config.enable_audit_logging ? 1 : 0
  project = data.google_project.this.project_id

  service = "storage.googleapis.com"
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
