local cluster = import "cluster.libsonnet";

local service_account_namespaces = [
  "external-secrets-operator",
];

cluster(
  "nerc-ocp-obs",
  "https://api.obs.nerc.mghpcc.org:6443",
  importstr "certs/letsencrypt_ca.crt",
  importstr "tokens/nerc-ocp-obs.txt",
  service_account_namespaces,
)
