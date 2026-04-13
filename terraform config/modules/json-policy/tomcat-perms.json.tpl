{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "sessionManagerServiceAccessPlusSSMRunCommandAccess",
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3BucketLevelAccess",
            "Effect": "Allow",
            "Action": [
                "s3:GetEncryptionConfiguration"
            ],
            "Resource": "*"
        },
        {
            "Sid": "S3ObjectWriteAccess",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                
                "arn:aws:s3:::zeus-ec2ssm-logsbu/ssm/*"
            ]
        },
        {
            "Sid": "KmsDecryptAccess",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt"
            ],
            "Resource": "arn:aws:kms:${region}:${account_id}:key/${kms_key_id}"
        },
        {
            "Sid": "KmsGenerateDataKeyAccess",
            "Effect": "Allow",
            "Action": [
                "kms:GenerateDataKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowEFSMounting",
            "Effect": "Allow",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:DescribeMountTargets"
            ],
            "Resource": [
                "arn:aws:elasticfilesystem:${region}:${account_id}:file-system/${efs_id}",
                "arn:aws:elasticfilesystem:${region}:${account_id}:access-point/${efs_accesspt_id}"
            ] 
        },
        {
            "Sid": "AllowRDSDBConnectWithIAMDBAUTHENTICATION",
             "Effect": "Allow",
             "Action": "rds-db:connect",
             "Resource": [
               "arn:aws:rds-db:${region}:${account_id}:dbuser:${db_resource_id}/admin",
               "arn:aws:rds-db:${region}:${account_id}:dbuser:${db_resource_id}/app_user"
             ]
        },
        {
            "Sid": "secretsManagerAccess",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": "${db_admin_secretARN}"
        }
    ]
}
