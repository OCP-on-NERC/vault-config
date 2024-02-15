local cluster = import 'cluster.libsonnet';

local service_account_namespaces = [
  'openshift-storage',
  'group-sync-operator',
  'openshift-config',
  'openshift-ingress',
  'openshift-logging',
  'openshift-ingress-operator',
  'openshift-logging',
  'koku-metrics-operator',
  'curator-system',
];

cluster(
  'nerc-ocp-test',
  'https://api.nerc-ocp-test.rc.fas.harvard.edu:6443',
  importstr 'certs/nerc_test_api.crt',
  importstr 'tokens/nerc-ocp-test.txt',
  service_account_namespaces,
)
