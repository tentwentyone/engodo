# Usecase 1 - Unauthorized Bucket Access

# this usecase has the objective of creating a private bucket with an attractive name to attract attackers and a few dummy files in it.

# Create a private bucket with a name that is attractive to attackers
# upload a few dummy files to the bucket



#generate a random name for the bucket
resource "random_pet" "uc_1_bucket" {
  count     = var.enable_uc_1 ? 1 : 0
  length    = 2
  separator = "-"
}

# create a random lowercase id for the bucket

resource "random_id" "uc_1_bucket" {
  count       = var.enable_uc_1 ? 1 : 0
  byte_length = 2
}

resource "google_storage_bucket" "uc_1_bucket" {
  count                       = var.enable_uc_1 ? 1 : 0
  name                        = format("%s-%s-%s", var.decoys_prefix, random_pet.uc_1_bucket[0].id, lower(random_id.uc_1_bucket[0].id))
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
  soft_delete_policy {
    retention_duration_seconds = 0
  }
}

# upload all files under gcp/uc_1_files to the bucket
resource "google_storage_bucket_object" "uc_1_bucket_object" {
  for_each = var.enable_uc_1 == true ? fileset("${path.module}/uc_1_files", "*") : []

  name   = each.key
  bucket = google_storage_bucket.uc_1_bucket[0].name
  source = "${path.module}/uc_1_files/${each.key}"
}



locals {
  uc_1_log_sink_filter = try(<<EOF
  (resource.type="gcs_bucket" AND resource.labels.bucket_name="${google_storage_bucket.uc_1_bucket[0].name}" AND protoPayload.methodName="storage.objects.list" OR protoPayload.methodName="storage.objects.get" OR protoPayload.methodName="storage.getIamPermissions") OR (proto_payload.method_name="google.cloud.resourcemanager.v3.TagBindings.ListEffectiveTags" AND protoPayload.resourceName="projects/_/buckets/${google_storage_bucket.uc_1_bucket[0].name}" AND resource.type="audited_resource")
EOF
  , "")

}


output "log_sink_filter" {
  value = local.log_sink_filter
}


