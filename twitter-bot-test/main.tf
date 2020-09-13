module "terraform-aws-twitter-bot" {
  source                  = "../"
  kms_key_arn             = "arn:aws:kms:us-east-1:415898136109:key/ca887a7f-5376-4386-9823-0190fa2a350d"
  encrypted_slack_webhook = "AQICAHjZ8UjkEExX4Vu6NrOILFA77DIrCzw3M4zAgqs67aWAiQEqdk62Fv+9HI4Dy6DIMa4EAAAAszCBsAYJKoZIhvcNAQcGoIGiMIGfAgEAMIGZBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDBZN4+wkgIitOyNuRgIBEIBsI1HVH04NpVR/kSNt54RGDX8wyYxMsQGqiwoLhJOWywfGB2IWIB1CLwCpfYY2tkk9m8Pw4IMHkDZAtgi74urUoqnHiFF6wbNwdO1DzGbZ+3qKcQZDrNqWXZln5qCJM3mDfkAQaHQuyMLMzebo"
  env                     = "prod"
}