variable "alarm_name" {
  type        = string
  description = "The descriptive name for the alarm. This name must be unique within the user's AWS account"
}

variable "namespace" {
  type        = string
  description = "The namespace for the alarm's associated metric"
}

variable "metric_name" {
  type        = string
  description = "The name for the alarm's associated metric"
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand"
}

variable "threshold" {
  type        = number
  description = "The value against which the specified statistic is compared"
}

variable "autoscaling_policy_arn" {
  type        = string
  description = "The ARN of the autoscaling policy"
}
