output "vpc_id" {
  value = aws_vpc.default_vpc.id
}
output "s3_endpoint" {
  value = aws_vpc_endpoint.s3

}
