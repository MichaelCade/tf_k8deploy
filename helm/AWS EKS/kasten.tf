resource "kubernetes_namespace" "kasten" {
  metadata {
    name = "kasten-io"
  }
}

resource "helm_release" "kasten" {
  name       = "k10"
  repository = "https://charts.kasten.io"
  chart      = "k10"
  namespace  = kubernetes_namespace.kasten.metadata[0].name

  set {
    name  = "secrets.awsAccessKeyId"
    value = aws_iam_access_key.kasten.id
  }

  set {
    name  = "secrets.awsSecretAccessKey"
    value = aws_iam_access_key.kasten.secret
  }

  set {
    name  = "externalGateway.create"
    value = "true"
  }
  set {
    name  = "auth.tokenAuth.enabled"
    value = "true"
  }
}

resource "aws_iam_user" "kasten" {
  name = "tfkasten"
  tags = local.tags
}

resource "aws_iam_access_key" "kasten" {
  user = aws_iam_user.kasten.name
}

# Minimal set of permissions needed by K10 for integrating with AWS EBS
# See: https://docs.kasten.io/latest/install/aws/aws_permissions.html#using-k10-with-aws-ebs
resource "aws_iam_user_policy" "kasten" {
  name = "kasten"
  user = aws_iam_user.kasten.name

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:CopySnapshot",
              "ec2:CreateSnapshot",
              "ec2:CreateTags",
              "ec2:CreateVolume",
              "ec2:DeleteTags",
              "ec2:DeleteVolume",
              "ec2:DescribeSnapshotAttribute",
              "ec2:ModifySnapshotAttribute",
              "ec2:DescribeAvailabilityZones",
              "ec2:DescribeSnapshots",
              "ec2:DescribeTags",
              "ec2:DescribeVolumeAttribute",
              "ec2:DescribeVolumesModifications",
              "ec2:DescribeVolumeStatus",
              "ec2:DescribeVolumes",
              "ec2:ResourceTag/*"
          ],
          "Resource": "*"
      },
      {
          "Effect": "Allow",
          "Action": "ec2:DeleteSnapshot",
          "Resource": "*",
          "Condition": {
              "StringLike": {
                  "ec2:ResourceTag/Name": "Kasten: Snapshot*"
              }
          }
      }
  ]
}
JSON
}

resource "aws_s3_bucket" "kasten_export" {
  bucket_prefix = "kasten-export-"
  acl           = "private"
  # We do this so that we can easily delete the bucket once we are done,
  # leave this out in prod
  force_destroy = true

  tags = local.tags
}

resource "aws_iam_user" "kasten_export" {
  name = "kasten-export"
  tags = local.tags
}

resource "aws_iam_user_policy" "kasten_export" {
  name = "kasten-export"
  user = aws_iam_user.kasten_export.name

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:PutBucketPolicy",
              "s3:ListBucket",
              "s3:DeleteObject",
              "s3:DeleteBucketPolicy",
              "s3:GetBucketLocation",
              "s3:GetBucketPolicy"
          ],
          "Resource": [
              "${aws_s3_bucket.kasten_export.arn}",
              "${aws_s3_bucket.kasten_export.arn}/*"
          ]
      }
  ]
}
JSON
}

resource "aws_iam_access_key" "kasten_export" {
  user = aws_iam_user.kasten_export.name
}

resource "kubernetes_secret" "kasten_export" {
  metadata {
    name      = "k10-s3-secret"
    namespace = "kasten-io"
  }

  data = {
    aws_access_key_id     = aws_iam_access_key.kasten_export.id
    aws_secret_access_key = aws_iam_access_key.kasten_export.secret
  }

  type = "secrets.kanister.io/aws"
}

output "kasten_export_bucket_name" {
  value = aws_s3_bucket.kasten_export.id
}