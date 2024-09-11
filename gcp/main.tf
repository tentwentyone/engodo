


# data resource to get the project id

data "google_project" "this" {
}


# create a pub sub topic to receive the logs

# create a log sink to export the logs to a pub sub




resource "google_pubsub_topic" "this" {
  name                       = format("%s-topic", var.prefix)
  message_retention_duration = "86600s"
}


resource "google_logging_project_sink" "this" {
  name        = format("%s-log-sink", var.prefix)
  destination = format("pubsub.googleapis.com/projects/%s/topics/%s", data.google_project.this.project_id, google_pubsub_topic.this.name)
  filter      = local.log_sink_filter #this must concatenate all the filters for all usecases
}



resource "google_pubsub_subscription" "this" {
  name                 = format("%s-subscription", var.prefix)
  topic                = google_pubsub_topic.this.name
  ack_deadline_seconds = 10

  #   push_config {
  #     push_endpoint = "https://hassio.darkercode.duckdns.org/webhook"
  #     no_wrapper {
  #       write_metadata = true
  #     }
  #   }
}



# create an sa to be used by log sink to export logs to pub sub

resource "google_service_account" "this" {
  account_id   = format("%s-log-sink", var.prefix)
  display_name = format("%s-log-sink", var.prefix)
}

# add the necessary permissions to the sa

resource "google_project_iam_member" "this" {
  project = data.google_project.this.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-785058079325@gcp-sa-logging.iam.gserviceaccount.com"
}



locals {
  log_sink_filter = join(" OR ", [local.uc_1_log_sink_filter, local.uc_2_log_sink_filter])
}
