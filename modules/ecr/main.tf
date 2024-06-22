resource "aws_ecr_repository" "aeis_ecr_repository" {
  name = "test-infra-repository-image-aeis"
}

output "url_ecr_repository" {
  value = aws_ecr_repository.aeis_ecr_repository.repository_url
}