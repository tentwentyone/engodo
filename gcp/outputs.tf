output "usecases" {
  value = {
    uc_1 = try({
      bucket_name     = google_storage_bucket.uc_1_bucket[0].name
      log_sink_filter = local.uc_1_log_sink_filter
    }, "")
    uc_2 = try({
      service_account = google_service_account.uc_2_sa[0].email
      log_sink_filter = local.uc_2_log_sink_filter
    }, "")
  }

}
