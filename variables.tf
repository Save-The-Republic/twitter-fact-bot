variable "env" {
  default     = "prod"
  description = "The name of environment for WireGuard. Used to differentiate multiple deployments"
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt secrets related to this module."
}

variable "encrypted_slack_webhook" {
  description = "KMS encrypted Slack webhook URL."
}
