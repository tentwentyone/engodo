output "usecases" {
  value = {
    uc1 = try({
      bucket_name     = google_storage_bucket.uc1_bucket[0].name
      log_sink_filter = local.uc1_log_sink_filter
    }, "")
    uc2 = try({
      service_account = google_service_account.uc2_sa[0].email
      log_sink_filter = local.uc2_log_sink_filter
    }, "")
    uc3 = try({
      secret_id       = google_secret_manager_secret.uc3_secret[0].name
      log_sink_filter = local.uc3_log_sink_filter
    }, "")
  }

  description = "Use cases related information"

}

output "log_sink_filter" {
  value       = local.log_sink_filter
  description = "The log sink filter containing all use cases and whitelist"
}



#https://cloud.google.com/logging/quotas#:~:text=Length%20of%20a%20sink%20inclusion%20filter
output "log_sink_size" {
  value       = format("%d/20000", length(local.log_sink_filter))
  description = "Current log sink size in characters"
}

