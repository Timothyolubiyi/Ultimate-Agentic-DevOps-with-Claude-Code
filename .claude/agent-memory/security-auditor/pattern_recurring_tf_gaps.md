---
name: pattern-recurring-tf-gaps
description: Common security gaps found in small student/portfolio S3+CloudFront Terraform stacks in this repo family
metadata:
  type: project
---

Across reviews of DMI-style static-site Terraform stacks (S3 + CloudFront + OAC, no IAM/OIDC resources), the same categories of gap recur even when the core access-control basics (public access block, OAC instead of OAI, HTTPS redirect) are done correctly:

1. No explicit `aws_s3_bucket_server_side_encryption_configuration` — relies on AWS's default SSE-S3, but not declared, so it's not enforceable/auditable in code.
2. No `aws_s3_bucket_logging` and no `logging_config` block on `aws_cloudfront_distribution` — access logging gap, no audit trail for who accessed what.
3. No `aws_cloudfront_response_headers_policy` attached to the default cache behavior — missing Content-Security-Policy, X-Frame-Options, Strict-Transport-Security, X-Content-Type-Options.
4. No WAFv2 web ACL association on the CloudFront distribution.
5. Repo-level: missing `.gitignore` for `terraform/` — risk of committing `.terraform/` provider binaries, `*.tfstate`, and `*.tfvars` (which can contain secrets or account IDs) to git history.
6. S3 bucket names or tags sometimes interpolate the raw AWS account ID directly, causing minor info disclosure if the bucket name is ever exposed (e.g., in CloudFront error responses or bucket-not-found errors).

**Why:** These aren't one-off mistakes — they show up repeatedly across this project's terraform stacks, suggesting the base template/course material doesn't cover them. Worth checking every review even when the "big" items (public access, OAC, HTTPS) look clean.
**How to apply:** Always explicitly check for items 1-6 above in addition to the standard checklist (IAM wildcards, OIDC scoping, hardcoded creds) — don't assume they're covered just because public-access basics are correct. See [[project-portfolio-terraform-stack]] for the specific stack these were last observed in.
