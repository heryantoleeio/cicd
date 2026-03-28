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
locals {
  view_files = fileset("${path.module}/../sql/views", "*.sql")

  views = {
    for f in local.view_files :
    trimsuffix(f, ".sql") => file("${path.module}/../sql/views/${f}")
  }
}

resource "google_bigquery_table" "views" {
  for_each = local.views

  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = each.key
  deletion_protection = false

  view {
    query          = each.value
    use_legacy_sql = false
  }
}