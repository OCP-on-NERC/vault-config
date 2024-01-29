local cluster = import "cluster.libsonnet";

local service_account_namespaces = [
  "openshift-storage",
  "group-sync-operator",
  "openshift-config",
  "openshift-ingress",
  "openshift-logging",
  "openshift-ingress-operator"
];

cluster(
  "nerc-ocp-obs",
  "https://api.obs.nerc.mghpcc.org:6443",
  importstr "certs/letsencrypt_ca.crt",
  importstr "tokens/nerc-ocp-obs.txt",
  service_account_namespaces,
)
