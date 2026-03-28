output "view_ids" {
  value = {
    for k, v in google_bigquery_table.views : k => v.id
  }
}