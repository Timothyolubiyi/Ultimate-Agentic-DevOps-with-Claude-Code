---
name: s3-versioning
description: Both buckets have versioning enabled with no lifecycle rules; unnecessary cost for static portfolio
metadata:
  type: project
---

**Resources:** 
- `aws_s3_bucket_versioning.site_bucket_versioning` (lines 28-34)
- `aws_s3_bucket_versioning.log_bucket_versioning` (lines 58-64)

**Current Problem:**
Versioning is enabled on both buckets but there are no lifecycle rules to expire old versions. Every time a file is overwritten, the previous version is retained indefinitely, costing storage.

**Cost Impact:**

1. **site_bucket versioning:**
   - For a static portfolio (10-20 objects, updated rarely), minimal impact: ~$0.23-0.46/month per full update cycle
   - But if objects change frequently, cost accumulates: e.g., 5 full updates = $1.15-2.30/month

2. **log_bucket versioning:**
   - More significant: Every log file written creates a new object. Logs are written constantly.
   - Estimated: Could cost $2-10/month depending on traffic volume and number of old versions retained

**Recommendation:**

**Option 1 (Recommended for this project):** Disable versioning entirely
- Static portfolio site doesn't need full version history
- Change `status = "Enabled"` to `status = "Suspended"` or remove the versioning block

**Option 2:** Keep versioning + add lifecycle rule
- Set lifecycle rule to delete non-current versions after N days (e.g., 30 days)
- For log_bucket: Expire objects older than 30 days entirely

**How to Apply (Option 1):**
- Set `status = "Suspended"` (or delete resource entirely for log_bucket)
- Existing versions will be retained but no new versions created

**How to Apply (Option 2):**
Add to main.tf:
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "site_versioning_cleanup" {
  bucket = aws_s3_bucket.site_bucket.id
  
  rule {
    id     = "delete-old-versions"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
```

**Priority:** High for site_bucket (cheap to fix), Very High for log_bucket (costs accumulate faster)
