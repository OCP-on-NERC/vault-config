function(
  cluster_name,
  kubernetes_host,
  kubernetes_ca_cert,
  token_reviewer_jwt,
  service_account_namespaces,
) {
  metadata: {
    name: cluster_name,
  },
  resources: {
    [std.format('/v1/auth/kubernetes/%s/config', cluster_name)]: {
      payload: {
        kubernetes_ca_cert: kubernetes_ca_cert,
        kubernetes_host: kubernetes_host,
        token_reviewer_jwt: token_reviewer_jwt,
      },
    },
    [std.format('/v1/auth/kubernetes/%s/role/secret-reader', cluster_name)]: {
      payload: {
        bound_service_account_names: [
          'vault-secret-reader',
        ],
        bound_service_account_namespaces: service_account_namespaces,
        name: 'secret-reader',
      },
    },
    [std.format('/v1/sys/auth/kubernetes/%s', cluster_name)]: {
      'if-not-exists': true,
      payload: {
        type: 'kubernetes',
      },
    },
    [std.format('/v1/sys/policy/%s-reader', cluster_name)]: {
      payload: {
        policy: std.format(|||
          path "nerc/data/%s/*" {
            capabilities = ["read"]
          }
        |||, cluster_name),
      },
    },
    [std.format('/v1/sys/policy/%s-writer', cluster_name)]: {
      payload: {
        policy: std.format(|||
          path "nerc/data/%s-ocp-obs/*" {
            capabilities = ["create", "read", "update", "delete", "list", "sudo"]
          }
        |||, cluster_name),
      },
    },
  },
}
