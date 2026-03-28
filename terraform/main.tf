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
  # Use absolute path relative to where terraform is run from
  sql_dir    = "${path.module}/../sql/views"
  view_files = fileset(local.sql_dir, "*.sql")

  views = {
    for f in local.view_files :
    trimsuffix(f, ".sql") => file("${local.sql_dir}/${f}")
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