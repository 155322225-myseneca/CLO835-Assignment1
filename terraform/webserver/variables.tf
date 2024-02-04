# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Daphne"
  #  "App"   = "Web"
  }
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

# Prefix to identify resources
variable "prefix" {
  default     = "dev"
  type        = string
  description = "Name prefix"
}
