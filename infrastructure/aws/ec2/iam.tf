# EC2 config
resource "aws_iam_role" "allow_instance_describe_ec2" {
  name = "allow_describe_ec2"

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

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-allow_instance_describe_ec2_role"
  })

}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile"
  role = aws_iam_role.allow_instance_describe_ec2.name
}

resource "aws_iam_role_policy" "describe_ec2" {
  name = "allow_all_describe_ec2"
  role = aws_iam_role.allow_instance_describe_ec2.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "view_eks" {
  name = "view_k8s"
  role = aws_iam_role.allow_instance_describe_ec2.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster"
      ],
      "Resource": "arn:aws:eks:*:902770729603:cluster/*"
    }
  ]
}
EOF
}