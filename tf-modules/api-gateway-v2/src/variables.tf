variable "gw_name" {
  type = string
  description = "the name to reference the api gateway resource"
}

variable "lambdas" {
  type = list(object({
    function_name = string
    description = string
    file_path = string
    handler = string
  }))
  description = "list of lambda function data to integrate with the pai gateway"
}
