{
  resources: [
    // Enable "kubernetes/backup" as a kubernetes auth endpoint
    {
      path: '/v1/sys/auth/kubernetes/backup',
      'if-not-exists': true,
      payload: {
        type: 'kubernetes',
      },
    },

    // https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#configure-method
    {
      path: '/v1/auth/kubernetes/backup/config',
      payload: {
        kubernetes_host: 'https://kubernetes.default.svc',
      },
    },

    // https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#create-update-role
    {
      path: '/v1/auth/kubernetes/backup/role/nerc-vault-backup',
      payload: {
        bound_service_account_names: ['backup-job'],
        bound_service_account_namespaces: ['vault'],
        token_policies: [
          'nerc-vault-backup',
        ],
      },
    },

    {
      path: '/v1/sys/policy/nerc-vault-backup',
      payload: {
        policy: importstr 'policies/nerc-vault-backup.hcl',
      },
    },
  ],
}
