variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}