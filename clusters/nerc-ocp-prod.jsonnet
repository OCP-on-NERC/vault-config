local cluster = import "cluster.libsonnet";

local service_account_namespaces = [
  "acct-mgt",
  "openshift-storage",
  "group-sync-operator",
  "openshift-config",
  "openshift-ingress",
  "openshift-logging",
  "openshift-ingress-operator"
];

cluster(
  "nerc-ocp-prod",
  "https://api.shift.nerc.mghpcc.org:6443",
  importstr "certs/letsencrypt_ca.crt",
  importstr "tokens/nerc-ocp-prod.txt",
  service_account_namespaces,
)
