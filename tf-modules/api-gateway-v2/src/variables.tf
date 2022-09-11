variable "gw_name" {
  type = string
  description = "the name to reference the api gateway resource"
}

variable "lambdas" {
  type = list(object({
    description = string
    uri = string
    integration_method = string
  }))
  description = "list of lambda function data to integrate with the pai gateway"
}
