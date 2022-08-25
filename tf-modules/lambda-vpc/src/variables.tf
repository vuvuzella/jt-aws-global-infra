variable "function_name" {
  type = string
  description = "The name for the lambda handler"
}

variable "file_path" {
  type = string
  description = "The relative file path and filename of the packaged handler archive"
}

variable "handler" {
  type = string
  description = "The dot notation reference to the specific handler"
}

variable runtime {
  type = string
  default = "nodejs16.x"
  description = "The runtime environment to execute the handler"
}
