locals {
  src_dir = var.website_source_dir != null ? var.website_source_dir : "${path.module}/../../files/Web"

  files_to_include = sort(distinct(concat(
    tolist(fileset(local.src_dir, "**/*.html")),
    tolist(fileset(local.src_dir, "css/**")),
    tolist(fileset(local.src_dir, "js/**")),
    tolist(fileset(local.src_dir, "i/**")),
  )))

  files_to_exclude = sort(distinct(concat(
    tolist(fileset(local.src_dir, "**/*.php")),
    tolist(fileset(local.src_dir, "**/.DS_Store")),
    tolist(fileset(local.src_dir, "**/Readme.txt")),
    tolist(fileset(local.src_dir, "**/License.txt")),
    tolist(fileset(local.src_dir, "scss/**")),
  )))

  files = {
    for f in setsubtract(local.files_to_include, local.files_to_exclude) :
    f => "${local.src_dir}/${f}"
  }

  file_extensions = {
    for f in keys(local.files) :
    f => lower(regex("\\.[^.]+$", f))
  }

  mime_types = {
    ".html"  = "text/html"
    ".css"   = "text/css"
    ".js"    = "application/javascript"
    ".json"  = "application/json"
    ".png"   = "image/png"
    ".jpg"   = "image/jpeg"
    ".jpeg"  = "image/jpeg"
    ".gif"   = "image/gif"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".txt"   = "text/plain"
    ".woff"  = "font/woff"
    ".woff2" = "font/woff2"
    ".ttf"   = "font/ttf"
    ".otf"   = "font/otf"
    ".eot"   = "application/vnd.ms-fontobject"
    ".map"   = "application/json"
  }
}

resource "aws_s3_object" "files" {
  for_each = local.files

  bucket = aws_s3_bucket.this.id
  key    = each.key
  source = each.value
  etag   = filemd5(each.value)

  content_type = lookup(
    local.mime_types,
    local.file_extensions[each.key],
    "application/octet-stream",
  )
}
