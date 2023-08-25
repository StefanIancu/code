# define a variable 
variable "subnet_prefix" {
  description = "cidrblock for the subnet"
  default = "10.0.0.0/24"
  type = string
}
