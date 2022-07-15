path "nerc/data/{{ cluster_name }}/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
