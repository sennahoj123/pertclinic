variable "vm_map" {
  type = map(object({
    name = string
  }))
  default = {
    "vm1" = {
      name = "vm1"
    }
    "vm2" = {
      name = "vm2"
    }
    "production" = {
      name = "production"
    }
  }
}
