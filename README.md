# OpenPGP README

## WKD Policy File Options

The policy file can be completely empty - that's actually the most common configuration and works fine. But here are the valid flags you can include (one per line):

### Available Flags

| flag                | description                                                                                                                                                                                                              |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| mailbox-only        | Tells clients that submissions should only be sent to the submission address, not the user's email Relevant only if you're running a WKS (Web Key Service) server for submissions You don't need this for static hosting |
| dane-only           | Indicates keys are ONLY for DANE (DNS-based Authentication of Named Entities) Tells clients NOT to use these keys for regular email encryption Don't use this unless you specifically know you need DANE                 |
| auth-submit         | Indicates the submission process requires authentication Only matters for WKS servers Irrelevant for static hosting                                                                                                      |
| protocol-version: N | Specifies protocol version support Currently only version 1 exists No point in setting this                                                                                                                              |

## Cloudflare Pages Setup Instructions

> The following assumes this repo is setup with a openpgpkeys

1. Push your repo to GitHub
2. Go to Cloudflare Pages
3. Click "Create a project" → "Connect to Git"
4. Select your repository
5. Set Build settings:

```text
Framework preset: None
Build command: (leave empty)
Build output directory: /
```

1. In Cloudflare Pages → Custom domains
2. Add openpgpkey.example.com
3. Follow DNS instructions (usually adds CNAME automatically)

## Validate the Repository

```bash
# Check the key file
curl -I https://openpgpkey.example.com/.well-known/openpgpkey/hu/<wkd-hash>

# Should return:
# HTTP/2 200
# content-type: application/octet-stream
# access-control-allow-origin: *

# Check the policy file
curl -I https://openpgpkey.example.com/.well-known/openpgpkey/policy

# Actually download and test the key
curl https://openpgpkey.example.com/.well-known/openpgpkey/hu/<wkd-hash> -o test.key
gpg --show-keys test.key

# Test with GPG (this is the real test)
gpg --locate-keys --auto-key-locate clear,wkd,nodefault john.doe@example.com
```
