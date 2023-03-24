# EC2 config
resource "aws_iam_role" "allow_instance_ec2" {
  name = "allow_all_ec2"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(local.common_tags, {
    Version = "1.0.0"
  })

}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.allow_instance_ec2.name
}

resource "aws_iam_role_policy" "allow_ec2_all" {
  name = "allow_all_ec2"
  role = aws_iam_role.allow_instance_ec2.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}