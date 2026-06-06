output "alb_dns_name" {
  value = module.compute.alb_dns_name
}

output "s3_bucket_name" {
  value = module.storage.s3_bucket_name
}

#output "cloudfront_domain" {
#  value = module.storage.cloudfront_domain
#}

#output "cloudfront_distribution_id" {
 # value = module.storage.cloudfront_distribution_id
#}

output "redis_endpoint" {
  value = module.compute.redis_endpoint
}

output "backend_log_group" {
  value = module.monitoring.backend_log_group
}