local cluster = import 'cluster.libsonnet';

local service_account_namespaces = [
  'openshift-storage',
  'group-sync-operator',
  'openshift-config',
  'openshift-ingress',
  'openshift-logging',
];

cluster(
  'ocp-beta-test',
  'https://api.ocp-beta-test.nerc.mghpcc.org:6443',
  importstr 'certs/letsencrypt_ca.crt',
  importstr 'tokens/nerc-ocp-beta-test.txt',
  service_account_namespaces,
)
