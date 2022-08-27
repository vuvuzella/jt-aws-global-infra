variable "function_name" {
  type = string
  description = "The name for the lambda handler"
}

variable "file_path" {
  type = string
  description = "The path and filename of the packaged handler archive relative to where the src is"
}

variable "handler" {
  type = string
  description = "The dot notation reference to the specific handler"
}

variable "runtime" {
  type = string
  default = "nodejs16.x"
  description = "The runtime environment to execute the handler"
}

variable "dependency_path" {
  type = string
  description = "The path to the dependencies archive relative to where the src is"
}
