local cluster = import "cluster.libsonnet";

local service_account_namespaces = [
  "external-secrets-operator",
];

cluster(
  "hypershift1",
  "https://api.hypershift1.int.massopen.cloud:6443",
  importstr "certs/letsencrypt_ca.crt",
  importstr "tokens/hypershift1.txt",
  service_account_namespaces,
)
