terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Store Terraform state in GCS
  backend "gcs" {
    bucket = "cicd-491607-tf-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
}

# 1. Create a BigQuery dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = "my_dataset"
  location   = var.location
}

# 2. Create a BigQuery view
resource "google_bigquery_table" "my_view" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "my_view"
  deletion_protection = false

  view {
    query          = <<-EOT
      SELECT
        1 AS id
    EOT
    use_legacy_sql = false
  }
}