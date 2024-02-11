function(
  cluster_name,
  kubernetes_host="https://kubernetes.default.svc",
  kubernetes_ca_cert=null,
  token_reviewer_jwt=null,
  service_account_namespaces="*",
  service_account_name="vault-secret-reader",
) {
  metadata: {
    name: cluster_name,
  },
  resources: [

    // Enable "kubernetes/<cluster_name>" as a kubernetes auth endpoint
    {
      path: std.format("/v1/sys/auth/kubernetes/%s", cluster_name),
      "if-not-exists": true,
      payload: {
        type: "kubernetes",
      },
    },

    // https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#configure-method
    {
      path: std.format("/v1/auth/kubernetes/%s/config", cluster_name),
      payload: {
        kubernetes_host: kubernetes_host,
      } + if kubernetes_ca_cert == null then {} else {
        kubernetes_ca_cert: kubernetes_ca_cert,
      } + if token_reviewer_jwt == null then {} else {
        token_reviewer_jwt: token_reviewer_jwt,
      },
    },

    // https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#create-update-role
    {
      path: std.format("/v1/auth/kubernetes/%s/role/secret-reader", cluster_name),
      payload: {
        bound_service_account_names: [
          service_account_name,
        ],
        bound_service_account_namespaces: service_account_namespaces,
        token_policies: [
          "nerc-common-reader",
          std.format("%s-reader", cluster_name),
        ],
      },
    },

    // https://developer.hashicorp.com/vault/api-docs/system/policy#create-update-policy
    {
      path: std.format("/v1/sys/policy/%s-reader", cluster_name),
      payload: {
        policy: std.format(|||
          path "nerc/data/%s/*" {
            capabilities = ["read"]
          }
        |||, cluster_name),
      },
    },
    {
      path: std.format("/v1/sys/policy/%s-writer", cluster_name),
      payload: {
        policy: std.format(|||
          path "nerc/data/%s-ocp-obs/*" {
            capabilities = ["create", "read", "update", "delete", "list", "sudo"]
          }
        |||, cluster_name),
      },
    },
  ],
}
