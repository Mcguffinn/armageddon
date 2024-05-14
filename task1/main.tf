terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  project = "arma-422614"
  region = "us-central1"
  zone = "us-central1-a"
  credentials = "arma-422614-1f0053d9ea86.json"
}

resource "google_storage_bucket_object" "static_website" {
  name   = "boilerplate"
  source = "index.html"
  bucket = google_storage_bucket.bucket.id
}

resource "google_storage_bucket" "bucket" {
  name = "arma_bucket"
  location = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page  = "404.html"
  }

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }

}

# output "website_url" {
#   value = "https://storage.googleapis.com/${google_storage_bucket_object.static_website.name}/index.html"
# }

// Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.bucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

// Public ACL for each HTML file
resource "google_storage_object_acl" "html_acl" {
  for_each       = google_storage_bucket_object.upload_html
  bucket         = google_storage_bucket_object.upload_html[each.key].bucket
  object         = google_storage_bucket_object.upload_html[each.key].name
  predefined_acl = "publicRead"
}

// Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_images" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.bucket.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

// Public ACL for each image file
resource "google_storage_object_acl" "image_acl" {
  for_each       = google_storage_bucket_object.upload_images
  bucket         = google_storage_bucket_object.upload_images[each.key].bucket
  object         = google_storage_bucket_object.upload_images[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.bucket.name}/index.html"
}