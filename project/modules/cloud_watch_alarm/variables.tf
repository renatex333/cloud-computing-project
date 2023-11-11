variable "alarm_name" {
  type        = string
  description = "The descriptive name for the alarm. This name must be unique within the user's AWS account"
}

variable "comparison_operator" {
  type        = string
  description = "The arithmetic operation to use when comparing the specified Statistic and Threshold. The specified Statistic value is used as the first operand"
}

variable "evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold"
}

variable "metric_name" {
  type        = string
  description = "The name for the alarm's associated metric"
}

variable "namespace" {
  type        = string
  description = "The namespace for the alarm's associated metric"
}

variable "dimensions" {
  type        = map(string)
  description = "The dimensions for the alarm's associated metric"
}

variable "threshold" {
  type        = number
  description = "The value against which the specified statistic is compared"
}