terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    databricks = {
      source = "databricks/databricks"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

data "databricks_aws_assume_role_policy" "this" {
  external_id = var.databricks_account_id
}

// New cross-account iam role for workspace deployment
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.resource_prefix}-crossaccount"
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json
}

data "databricks_aws_crossaccount_policy" "this" {
  policy_type = "customer"
}

# a walkaround using sleep to wait for role to be created
resource "time_sleep" "wait" {
  depends_on = [
    aws_iam_role.cross_account_role
  ]
  create_duration = "10s"
}

resource "databricks_mws_credentials" "this" {
  # account_id should not be specified in mws credentials
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.resource_prefix}-creds"
  depends_on       = [aws_iam_role_policy.cross_account, time_sleep.wait]
}


resource "aws_iam_role_policy" "cross_account" {
  name = "${var.resource_prefix}-crossaccount-policy"
  role = aws_iam_role.cross_account_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "NonResourceBasedPermissions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CancelSpotInstanceRequests",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribePrefixLists",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:RequestSpotInstances"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "FleetPermissions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeFleetHistory",
          "ec2:ModifyFleet",
          "ec2:DeleteFleets",
          "ec2:DescribeFleetInstances",
          "ec2:DescribeFleets",
          "ec2:CreateFleet",
          "ec2:DeleteLaunchTemplate",
          "ec2:GetLaunchTemplateData",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:ModifyLaunchTemplate",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:AssignPrivateIpAddresses",
          "ec2:GetSpotPlacementScores"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Sid" : "InstancePoolsSupport",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AssociateIamInstanceProfile",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ReplaceIamInstanceProfileAssociation"
        ],
        "Resource" : "arn:aws:ec2:${var.region}:${var.aws_account_id}:instance/*",
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "AllowEc2RunInstancePerTag",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/Vendor" : "Databricks"
        } }
      },
      {
        "Sid" : "AllowEc2RunInstancePerVPCid",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:security-group/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:vpc" : "arn:aws:ec2:${var.region}:${var.aws_account_id}:vpc/${var.vpc_id}"
          }
        }
      },
      {
        "Sid" : "AllowEc2RunInstanceOtherResources",
        "Effect" : "Allow",
        "Action" : "ec2:RunInstances",
        "NotResource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:network-interface/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:subnet/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:security-group/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:volume/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ]
      },
      {
        "Sid" : "DatabricksSuppliedImages",
        "Effect" : "Deny",
        "Action" : "ec2:RunInstances",
        "Resource" : [
          "arn:aws:ec2:*:*:image/*"
        ],
        "Condition" : {
          "StringNotEquals" : {
            "ec2:Owner" : "601306020600"
          }
        }
      },
      {
        "Sid" : "EC2TerminateInstancesTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:TerminateInstances"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:instance/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2AttachDetachVolumeTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AttachVolume",
          "ec2:DetachVolume"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:instance/*",
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2CreateVolumeByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateVolume"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "aws:RequestTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Sid" : "EC2DeleteVolumeByTag",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DeleteVolume"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.region}:${var.aws_account_id}:volume/*"
        ],
        "Condition" : {
          "StringEquals" : {
            "ec2:ResourceTag/Vendor" : "Databricks"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy"
        ],
        "Resource" : "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
        "Condition" : {
          "StringLike" : {
            "iam:AWSServiceName" : "spot.amazonaws.com"
          }
        }
      },
      {
        "Sid" : "VpcNonresourceSpecificActions",
        "Effect" : "Allow",
        "Action" : [
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress"
        ],
        "Resource" : "arn:aws:ec2:${var.region}:${var.aws_account_id}:security-group/${var.security_group_id}",
        "Condition" : {
          "StringEquals" : {
            "ec2:vpc" : "arn:aws:ec2:${var.region}:${var.aws_account_id}:vpc/${var.vpc_id}"
          }
        }
      }
    ]
    }
  )
}
