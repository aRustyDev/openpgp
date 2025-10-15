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
