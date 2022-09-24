variable "gw_name" {
  type = string
  description = "the name to reference the api gateway resource"
}

variable "lambdas" {
  type = map(object({
    description = string
    file_path = string
    handler = string
  }))
  description = "list of lambda function data to integrate with the pai gateway"
}

variable "dependency_path" {
  type = string
  description = "The path to the dependency zip file for the handlers"
}
