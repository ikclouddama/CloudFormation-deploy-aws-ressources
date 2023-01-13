resource "aws_efs_file_system" "efs_example" {
   creation_token = "efs-example"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted  = "true"
  
   tags = {
    Environment = var.environment
    Team        = "Network"
    Name        = "efsExample"
  }
 }

 resource "aws_efs_mount_target" "efs_mount" {

  count        = length(slice(local.az_names, 0, 2))  
  file_system_id = aws_efs_file_system.efs_example.id
  subnet_id      = aws_subnet.efs_public[count.index].id
  security_groups = ["${aws_security_group.efs_access_sg.id}"]
}

resource "aws_efs_access_point" "efs_access_point" {
    
  file_system_id = aws_efs_file_system.efs_example.id

  posix_user {
    gid = 1000
    uid = 1000
  }  

  root_directory {
      path = "/access"

      creation_info {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "777"
      }
  }
 
}


resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.efs_example.id

  bypass_policy_lockout_safety_check = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.efs_example.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite",
                "elasticfilesystem:ClientRootAccess"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}