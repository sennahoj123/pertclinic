variable "vm_map" {
  type = map(object({
    name = string
  }))
  default = {
    "vm1" = {
      name = "Testing"
    }
    "vm2" = {
      name = "Production"
    }
    "vm3" = {
      name = "Acceptance"
    }
  }
}
