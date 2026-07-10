---
name: project-portfolio-terraform-stack
description: Structure and recurring security gaps in this repo's terraform/ S3+CloudFront static-site stack
metadata:
  type: project
---

The `terraform/` directory provisions a minimal static-site stack for the DMI portfolio project: one `aws_s3_bucket` (private, OAC-fronted), `aws_s3_bucket_public_access_block` (all four flags true — good), `aws_s3_bucket_versioning` (enabled — good), one `aws_cloudfront_origin_access_control` + `aws_cloudfront_distribution` (OAC, not legacy OAI — good), and a bucket policy scoped via `AWS:SourceArn` condition to the specific distribution. No IAM roles/policies or OIDC trust resources exist in this stack (confirmed by grep for `iam|oidc|assume_role` across `**/*.tf` — no matches as of 2026-07-10).

As of 2026-07-10, this stack (read at that commit) was missing: S3 server-side encryption config block, S3 access logging, CloudFront access logging, a CloudFront response-headers policy (no CSP/X-Frame-Options/HSTS), and a WAFv2 web ACL association. The S3 bucket name interpolates the raw AWS account ID (`"${var.project_name}-${data.aws_caller_identity.current.account_id}-${var.region}"`), which is a minor info-disclosure pattern worth flagging each time it recurs. `backend.tf` intentionally ships with the S3 remote backend commented out (documented bootstrap workflow: apply once locally, then migrate) — this is by design, not a bug, but local state should never be committed to git.

**Why:** These are the concrete findings from the most recent full audit; useful to check whether they've been fixed before re-flagging them as new.
**How to apply:** On re-review, verify each gap above still exists (grep for `server_side_encryption_configuration`, `logging_config`, `aws_cloudfront_response_headers_policy`, `aws_wafv2_web_acl`) rather than assuming; only report as new/still-open if still absent. See [[pattern-recurring-tf-gaps]] for the general checklist this stack repeatedly fails.
