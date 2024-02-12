path "sys/backup/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "sys/restore/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "nerc/*" {
  capabilities = ["read"]
}

path "/sys/storage/raft/snapshot"
{
  capabilities = ["read"]
}

path "/sys/storage/raft/configuration"
{
  capabilities = ["read"]
}

path "auth/kubernetes/backup" {
  capabilities = ["create", "read"]
}

path "auth/kubernetes/backup/backup/" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/kubernetes/backup/login" {
  capabilities = ["create"]
}
