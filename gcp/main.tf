


# data resource to get the project id

data "google_project" "this" {
}

data "google_organization" "this" {
  organization = var.organization_domain_id
}



# create a pub sub topic to receive the logs
resource "google_pubsub_topic" "this" {
  name                       = format("%s-topic", var.prefix)
  message_retention_duration = "86600s"
}

# create a pub sub subscription to the topic to enable message ordering and integration with external systems
resource "google_pubsub_subscription" "this" {
  name                    = format("%s-subscription", var.prefix)
  topic                   = google_pubsub_topic.this.name
  ack_deadline_seconds    = 10
  enable_message_ordering = true
}

# create a log sink to export the logs to a pub sub
resource "google_logging_project_sink" "this" {
  name        = format("%s-log-sink", var.prefix)
  destination = format("pubsub.googleapis.com/projects/%s/topics/%s", data.google_project.this.project_id, google_pubsub_topic.this.name)
  filter      = local.log_sink_filter #this must concatenate all the filters for all usecases
  # only the default logging  service account can be used to export logs to pub sub

  project = data.google_project.this.project_id
  dynamic "exclusions" {
    for_each = toset(var.whitelist_service_accounts)
    content {
      name   = format("exclude_SA_%s", split("@", exclusions.value)[0])
      filter = format("proto_payload.authentication_info.principal_email=\"%s\"", exclusions.value)
    }

  }

}

# add the necessary permissions to the default logging service account to be able to export logs to pub sub

resource "google_pubsub_topic_iam_member" "this" {
  project = data.google_project.this.project_id
  topic   = google_pubsub_topic.this.name
  role    = "roles/pubsub.publisher"
  member  = format("serviceAccount:service-%s@gcp-sa-logging.iam.gserviceaccount.com", data.google_project.this.number)
}


locals {
  log_sink_filter = format("%s", join(" OR ", [local.uc1_log_sink_filter, local.uc2_log_sink_filter, local.uc3_log_sink_filter]))

}
