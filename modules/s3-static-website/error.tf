resource "aws_s3_object" "error_document" {
  bucket       = aws_s3_bucket.this.id
  key          = var.website_error_document
  content_type = "text/html"

  content = <<-EOT
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>404 — Page Not Found</title>
      <style>
        body { font-family: system-ui, -apple-system, sans-serif; text-align: center; padding: 4rem; color: #333; }
        h1   { font-size: 4rem; margin: 0; color: #0d6efd; }
        p    { font-size: 1.25rem; }
      </style>
    </head>
    <body>
      <h1>404</h1>
      <p>The requested page was not found.</p>
      <p><a href="/">Return to homepage</a></p>
    </body>
    </html>
  EOT
}
