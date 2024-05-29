variable app_name {
  type        = string
  description = "App name"
  #default = "mybday"
}
variable log_retention_day {
  type        = number
}
variable desired_size{
  type        = number
}
variable max_size {
  type        = number
}
variable min_size {
  type        = number
}
variable cluster_name {}
variable vpc_cidr_block {}