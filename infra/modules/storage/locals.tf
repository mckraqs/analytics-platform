locals {
  requirements_path      = "requirements.txt"
  requirements_path_full = format("%s/%s", path.root, local.requirements_path)
}