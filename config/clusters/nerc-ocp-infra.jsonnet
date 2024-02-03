local cluster = import "cluster.libsonnet";

local service_account_namespaces = [
  "external-secrets-operator",
];

cluster(
  "nerc-ocp-infra",
  service_account_namespaces=service_account_namespaces,
)
