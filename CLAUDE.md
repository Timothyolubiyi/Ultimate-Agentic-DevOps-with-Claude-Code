# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static HTML/CSS portfolio website deployed to AWS using S3 and CloudFront, provisioned with Terraform, and automated via GitHub Actions.



## Project Structure

```
├── index.html          # Main portfolio page (hero, about, courses, contact sections)
├── privacy.html        # Privacy policy page
├── terms.html          # Terms of service page
├── style.css           # All styling (responsive design, animations)
├── images/             # Portfolio assets
│   ├── logo.png
│   ├── profile.jpg
│   ├── awsCloud.jpg, Devops.jpg, Git.jpg  # Technology logos
│   └── other images
└── README.md           # Deployment guide for students
```

## No Build Process

This is a **zero-dependency** project:
- No npm/Node.js
- No build tools or transpilers
- No tests or linting
- Pure HTML, CSS, and images
Pure HTML5 and CSS3. No JavaScript. No build step. No framework.

## Key Requirement: Ownership Proof

**Before deployment, students MUST edit the footer in `index.html`** to add their details. This is a DMI requirement to prove ownership.

Look for the footer section (typically near the end of index.html) and ensure it displays something like:
```html
<p><strong>Deployed by:</strong> [Student Name] | DMI Cohort | Week 1 | [Date]</p>
```

This must be visible in browser screenshots submitted as proof of deployment.

## Deployment (Ubuntu + Nginx)

```bash
# SSH into Ubuntu VM
ssh user@public-ip

# Install Nginx
sudo apt update && sudo apt install nginx -y

# Copy files to web root
sudo cp -r * /var/www/html/

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Access at http://public-ip
```

## Development Notes

- **External dependencies:** FontAwesome (CDN-loaded in index.html)
- **Responsive design:** CSS media queries handle mobile/tablet/desktop
- **Navigation:** Smooth scrolling with anchor links and mobile hamburger menu
- **Images:** Use `loading="lazy"` for performance
- **No JavaScript required** for core functionality (small inline scripts for nav menu only)

## Common Edits

When helping students customize this site:
1. **Change name/title:** Update `<title>` in index.html and main `<h1>` headings
2. **Change profile image:** Replace `images/profile.jpg` or `images/image.png`
3. **Update content:** Edit text in relevant `<section>` tags
4. **Change colors:** Modify CSS color values in `style.css`
5. **Add/remove sections:** Add new `<section>` tags and corresponding CSS

## For future DMI cohorts:

Students should:
1. Clone this repo
2. Add their ownership proof to the footer
3. Customize the content (name, image, text)
4. Deploy to an Ubuntu VM with Nginx
5. Keep it live for 24 hours
6. Submit a browser screenshot showing their deployed site

## Commands Section
- terraform init
- terraform plan
- terraform apply

## Conventions Section
- All infrastructure changes go through Terraform — never modify AWS resources manually
- No JavaScript in this project
- CSS uses mobile-first approach with breakpoints at 900px, 768px, and 600px

## Safety section
Never put secrets in this file. No API keys, passwords, or AWS credentials.
