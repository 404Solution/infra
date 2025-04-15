locals {
  dependency_paths = read_terragrunt_config(find_in_parent_folders("dependencies.hcl"))
}

dependencies {
  paths = local.dependency_paths.dependency_paths
}
