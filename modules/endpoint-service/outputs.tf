#########
#OutPuts
#########
output "endpoint_service_names" {
  description = "Service names tenants use to create Interface VPC Endpoints (aws_vpc_endpoint.service_name)"
  value = {
    for svc_key, svc in aws_vpc_endpoint_service.privatelink_service :
    svc_key => svc.service_name
  }
}
