---
name: portfolio-cloudfront-price
description: Current PriceClass_200, recommend PriceClass_100 for 20-30% savings if global coverage not needed
metadata:
  type: project
---

**Resource:** `aws_cloudfront_distribution.s3_distribution` (line 159 in main.tf)

**Current Configuration:**
```hcl
price_class = "PriceClass_200"
```

**CloudFront Price Classes:**
- `PriceClass_All` (~131 edge locations) — Most expensive, global coverage
- `PriceClass_200` (~130 edge locations) — Current choice, covers NA, EU, Asia, Australia, Middle East, Africa
- `PriceClass_100` (~87 edge locations) — Cheapest, focuses on NA, EU, parts of Asia

**Recommendation:**
Change to `PriceClass_100` if traffic is primarily from North America and Europe (likely for a student portfolio site)

**Cost Impact:**
- **Estimated savings: 20-30% reduction in CloudFront data transfer charges**
- Example: If paying $100/month for CloudFront at PriceClass_200, could save $20-30/month at PriceClass_100
- For low-traffic portfolio site: likely minimal absolute dollars, but good practice

**Trade-off:** Slower performance for users in Asia, Australia, Middle East, Africa (fewer nearby edge locations)

**How to Apply:** Change line 159 in `terraform/main.tf` from `PriceClass_200` to `PriceClass_100`

**Priority:** Medium — depends on target audience. If all users are expected to be in NA/EU, do it.
