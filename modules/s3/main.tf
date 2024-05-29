resource "aws_s3_bucket" "bucket" {
   bucket = "${var.app_name}-${var.cluster_name}"

   tags = {
     Name = "my bucket"
     Environment = "Dev"
   }
 }