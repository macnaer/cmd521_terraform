# S3 Static Website Module

Provisions an S3 bucket configured for static website hosting, uploads the
content of `files/Web/` to it, and exposes the website endpoint.

## Resources

| Resource | Description |
|----------|-------------|
| `aws_s3_bucket.this` | The website bucket |
| `aws_s3_bucket_ownership_controls.this` | `BucketOwnerPreferred` ownership |
| `aws_s3_bucket_public_access_block.this` | Public access allowed (policy-based) |
| `aws_s3_bucket_acl.this` | Bucket ACL `public-read` |
| `aws_s3_bucket_website_configuration.this` | Index + error document |
| `aws_s3_bucket_server_side_encryption_configuration.this` | AES256 SSE |
| `aws_s3_bucket_versioning.this` | Optional versioning |
| `aws_s3_bucket_policy.this` | Public `s3:GetObject` policy |
| `aws_s3_object.files` (for_each) | All uploaded static assets |
| `aws_s3_object.error_document` | Synthetic 404 page |

## Uploaded files

The module uploads every regular file under `css/`, `js/`, `i/` and every
`*.html` file directly inside the source directory. Files with the following
patterns are excluded:

- `**/*.php`
- `**/.DS_Store`
- `**/Readme.txt`, `**/License.txt`
- `scss/**`

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `bucket_name`           | string | — | Globally unique bucket name |
| `force_destroy`         | bool   | `true`  | Allow Terraform to delete non-empty bucket |
| `versioning_enabled`    | bool   | `true`  | Enable bucket versioning |
| `website_index_document`| string | `index.html` | Index document suffix |
| `website_error_document`| string | `error.html` | Error document key |
| `website_source_dir`    | string | module-relative default | Source directory for uploads |
| `tags`                  | map    | `{ManagedBy=Terraform}` | Common tags |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id`         | Bucket name |
| `bucket_arn`        | Bucket ARN |
| `bucket_domain_name`| S3 REST endpoint (not website endpoint) |
| `website_endpoint`  | S3 website endpoint (no HTTPS) |
| `website_url`       | Full URL `http://<endpoint>` |
| `object_count`      | Number of uploaded objects |

## Notes

- The bucket uses the legacy S3 website endpoint (HTTP only, not
  `bucket.s3.amazonaws.com`). For HTTPS + CDN use CloudFront in front.
- Bucket policy grants `s3:GetObject` to all principals. Do not put any
  private data in this bucket.
