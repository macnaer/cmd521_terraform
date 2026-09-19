variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "website_index_document" {
  description = "Default index document for the static website"
  type        = string
  default     = "index.html"
}

variable "website_error_document" {
  description = "Default error document for the static website (also uploaded by the module)"
  type        = string
  default     = "error.html"
}

variable "website_source_dir" {
  description = "Filesystem path to the directory containing static website assets to upload. If null, defaults to <module>/../../files/Web."
  type        = string
  default     = null
  nullable    = true
}

variable "tags" {
  description = "Common tags applied to the bucket"
  type        = map(string)
  default     = { ManagedBy = "Terraform" }
}
