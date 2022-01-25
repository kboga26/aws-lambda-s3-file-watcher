# S3 bucket for settlement file transfer ingress
resource "aws_s3_bucket" "s3_filewatcher" {
  bucket = "my-${var.env_id}-s3-filewatcher-bucket"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "my-${var.env_id}-filewatcher-application"
    Environment = var.env_id
    Description = "Used to store files for my filewatcher application."
    backup      = "true"
  }
}

resource "aws_lambda_permission" "s3_bucket_filewatcher" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_filewatcher.arn # arn of the lambda function
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_filewatcher.arn # bucket arn   
}

#settlement filewatcher bucket notification
resource "aws_s3_bucket_notification" "settlement_bucket_filewatcher" {
  bucket = aws_s3_bucket.s3_filewatcher.id # bucket runtime
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-filewatcher.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }
  depends_on = [aws_lambda_permission.allow_bucket_filewatcher]
}