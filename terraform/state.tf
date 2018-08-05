// Remote state
terraform {
  backend "local" {
    path = "config/cluster.state.remote"
  }
}

//Outputs
output "path_module" {
  value = "${path.module}"
}
