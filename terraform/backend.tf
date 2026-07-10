# Terraform Backend Configuration
# IMPORTANT: Uncomment the backend block below after you:
# 1. Create an S3 bucket for Terraform state (e.g., "my-terraform-state-bucket")
# 2. Enable versioning on the bucket
# 3. Run: terraform init (without backend)
# 4. Run: terraform apply (to create initial resources)
# 5. Uncomment the backend block below
# 6. Run: terraform init -migrate-state (to migrate state to S3)

# terraform {
#   backend "s3" {
#     bucket         = "change-me-terraform-state-bucket"
#     key            = "portfolio-site/terraform.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }
