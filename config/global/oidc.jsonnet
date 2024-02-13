{
  resources: [
    {
      path: "/v1/sys/auth/oidc",
      "if-not-exists": true,
      payload: {
        type: "oidc",
        description: "OIDC authentication via Dex on nerc-ocp-infra",
        config: {
          listing_visibility: "unauth",
        },
      },
    },
    {
      path: "/v1/auth/oidc/config",
      payload: {
        oidc_client_id: "vault",
        oidc_client_secret: importstr "secrets/dex-client-secret",
        oidc_discovery_url: "https://dex-dex.apps.nerc-ocp-infra.rc.fas.harvard.edu",
        default_role: "ocp-user",
      },
    },
    {
      path: "/v1/auth/oidc/role/ocp-user",
      payload: {
        policies: "default",
        user_claim: "name",
        groups_claim: "groups",
        oidc_scopes: ["openid", "email", "groups", "profile"],
        allowed_redirect_uris: [
          "https://vault-ui-vault.apps.nerc-ocp-infra.rc.fas.harvard.edu/ui/vault/auth/oidc/oidc/callback",
        ],
      },
    },
  ],
}
