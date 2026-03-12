resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = !var.is_public
  block_public_policy     = !var.is_public
  ignore_public_acls      = !var.is_public
  restrict_public_buckets = !var.is_public
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.is_public ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  depends_on = [aws_s3_bucket_public_access_block.public_access_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  count  = var.is_portfolio_website ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_s3_object" "index_html" {
  count        = var.auto_upload_documents ? 1 : 0
  bucket       = aws_s3_bucket.bucket.id
  key          = "index.html"
  source       = "${var.website_documents_path}/pages/index.html"
  etag         = filemd5("${var.website_documents_path}/pages/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  count        = var.auto_upload_documents ? 1 : 0
  bucket       = aws_s3_bucket.bucket.id
  key          = "error.html"
  source       = "${var.website_documents_path}/pages/error.html"
  etag         = filemd5("${var.website_documents_path}/pages/error.html")
  content_type = "text/html"
}

resource "aws_s3_object" "favicon" {
  count        = var.auto_upload_documents ? 1 : 0
  bucket       = aws_s3_bucket.bucket.id
  key          = "favicon/favicon.png"
  source       = "${var.website_documents_path}/favicon/favicon.png"
  etag         = filemd5("${var.website_documents_path}/favicon/favicon.png")
  content_type = "image/png"
}
