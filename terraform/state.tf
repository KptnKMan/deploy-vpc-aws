// Define state location of this template (Used for remote state elsewhere)
# terraform {
#   backend "local" {
#     path = "config/terraform.tfstate"
#   }
# }

//Outputs
output "path_module" {
  value = path.module
}

