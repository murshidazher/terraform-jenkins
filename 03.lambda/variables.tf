variable "region" {
  description = "Choose region for your stack"
  type        = string
  default     = "us-east-1"
}

variable "lambda_function_name" {
  description = "Choose lambda function name"
  type        = string
  default     = "welcome"
}

variable "lambda_output_file_name" {
  description = "Choose lambda output file name"
  type        = string
  default     = "ouputs/welcome.zip"
}

variable "lambda_source_file_name" {
  description = "Choose lambda source file name"
  type        = string
  default     = "welcome.py"
}

variable "lambda_handler_name" {
  description = "Choose lambda handler function name"
  type        = string
  default     = "welcome.hello"
}

