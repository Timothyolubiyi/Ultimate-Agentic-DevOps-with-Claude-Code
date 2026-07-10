---
name: cloudfront-logging
description: Separate log bucket adds unnecessary costs; consider disabling for low-traffic portfolio
metadata:
  type: project
---

**Resources:**
- `aws_s3_bucket.log_bucket` (lines 37-45) — entire separate bucket
- `aws_s3_bucket_logging.site_bucket_logging` (lines 79-85) — S3 access logs
- `aws_cloudfront_distribution.s3_distribution.logging_config` (lines 162-166) — CloudFront logs

**Current Problem:**
Two separate logging mechanisms writing to a separate bucket:
1. S3 access logs for site_bucket (what requests hit S3 before CloudFront)
2. CloudFront access logs (all user requests)

For a low-traffic portfolio site, this is overkill and costs:
- $0.50/month for log_bucket storage (AWS minimum)
- Storage for accumulated logs
- S3 access logging API calls (minimal but not free)

**Cost Impact:**
- **Estimated annual savings: $6-12/year** if disabling logging entirely + deleting log_bucket
- One-time savings: Eliminate log_bucket completely (~0.50/month storage fee)
- Ongoing: No log storage accumulation costs

**Alternative: Keep logs but rotate them**
If you need logs for debugging:
- Add lifecycle rule to expire logs after 7 days instead of keeping indefinitely
- Estimated savings: 85-90% reduction in log storage costs

**Recommendation for this project:**
Disable ALL logging (both S3 and CloudFront) since:
- Portfolio site is not a production system
- Low traffic = minimal debugging value from logs
- Student project with no compliance/audit requirements
- Simplifies infrastructure

**How to Apply:**
1. Delete `aws_s3_bucket.log_bucket` resource entirely (lines 37-45)
2. Delete `aws_s3_bucket_logging.site_bucket_logging` resource (lines 79-85)
3. Delete `logging_config` block from `aws_cloudfront_distribution` (lines 162-166)
4. Update `aws_s3_bucket_public_access_block.log_bucket_pab` to remove depends_on reference if needed

**Priority:** High — eliminates entire resource and recurring costs with no downside for student portfolio
