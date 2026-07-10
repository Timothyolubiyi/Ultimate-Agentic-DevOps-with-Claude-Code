---
name: s3-lifecycle-rules
description: No lifecycle rules on log_bucket; logs accumulate indefinitely
metadata:
  type: project
---

**Resource:** `aws_s3_bucket.log_bucket` — S3 bucket storing CloudFront and S3 access logs

**Current Problem:** Logs accumulate in Standard storage indefinitely with no cleanup

**Recommended Lifecycle Policy:**
```
- Transition objects to Intelligent-Tiering after 30 days
- Expire (delete) objects after 90 days
OR
- Expire objects after 30 days (simpler, fewer moving parts)
```

**Cost Impact:**
- Expiring after 30 days: Saves ~$0.023/GB/month for objects in months 2+ (90% reduction in long-term log storage)
- For a typical portfolio site generating ~50GB logs/month, could save ~$1-2/month after 30-day retention window

**How to Apply:** Add `aws_s3_bucket_lifecycle_configuration` resource with expiration rule (if keeping logging enabled)

**Priority:** Medium — only applies if keeping CloudFront/S3 logging enabled. If logging is disabled entirely, this is moot.
