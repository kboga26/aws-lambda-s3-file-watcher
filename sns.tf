resource "aws_sns_topic" "s3_filewatcher" {
  name = "s3-${var.end_id}-filewatcher-sns-topic"
}