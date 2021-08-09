variable "aws_region" {
  description = "AWS region for all resources."
  type    = string
}

variable "aws_profile" {
  description = "AWS profile for all resources."
  type    = string
}

variable "owm_base_url" {
  description = "OpenWeatherMap"
  type    = string
}

variable "owm_appid" {
  description = "OpenWeatherMap App Id"
  type    = string
}
