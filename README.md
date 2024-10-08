**THIS REPOSITORY IS DEPRECATED; SEE https://github.com/OCP-on-NERC/nerc-ocp-config/tree/main/vault/config/overlays/nerc-ocp-infra INSTEAD**

# NERC Vault Configuration

## Project structure

- `config/global` -- global vault configuration (configure authentication, groups, global policies, etc)
- `config/clusters` -- per-cluster configuration
- `lib/` -- [jsonnet] templates, vault [hcl] policies, certificates
- `data/` -- for secret data not stored in the repository (you will need to provision this manually)

[jsonnet]: https://jsonnet.org/
[hcl]: https://github.com/hashicorp/hcl

## Requiremnents

1. You have a vault token in the `VAULT_TOKEN` environment variable with sufficient privileges to make changes to the vault configuration.

1. You have administrative access to each cluster in order to generate ServiceAccount tokens.

1. You are able to generate or acquire a client secret for OIDC authentication using Dex on the infra cluster.

## Generate ServiceAccount Tokens

The Vault requires a service account token in order to authenticate against the remote Kubernetes clusters (...in order to authenticate tokens presented by the external secrets operator when requesting secrets). In our configuration, this means we need a token for the `eso-vault-auth` ServiceAccount in the `external-secrets-operator` namespace. In the `external-secrets-operator` namespace, you should fine one or more secrets named `eso-vault-auth-token-<something>`. To extract a token from one of these secrets:

```
kubectl -n external-secrets-operator get secret eso-vault-auth-token-rk4bt -o json |
  jq -r .data.token |
  base64 -d > data/tokens/nerc-ocp-prod.txt
```

You will need to generate a token for each target cluster.

## Extract dex secret from vault

In order to configure OIDC authentication on the vault, you will need a client secret from Dex. This should be placed in `data/secrets/dex-client-secret`.

## Apply the configuration

After you have the dex oidc secret and tokens for all the target clusters, you can run the `apply_vault_config.py` script:

```
python apply_vault_config.py
```

Before running the script you will need to follow standard conventions for installing the Python dependencies.

## Test authentication

To confirm things are configured correctly, acquire a token for one of the `vault-secret-reader` ServiceAccounts on a remote cluster:

```
TOKEN=$(kubectl -n openshift-config get secret vault-secret-reader -o json | jq -r .data.token | base64 -d)
```

Use the `vault` command to log in with the token:

```
vault write auth/kubernetes/nerc-ocp-prod/login role=secret-reader jwt="$TOKEN"
```

You should receive output like this:

```
Key                                       Value
---                                       -----
token                                     hvs....
token_accessor                            ...
token_duration                            768h
token_renewable                           true
token_policies                            ["default" "nerc-ocp-prod-reader"]
identity_policies                         []
policies                                  ["default" "nerc-ocp-prod-reader"]
token_meta_role                           secret-reader
token_meta_service_account_name           vault-secret-reader
token_meta_service_account_namespace      openshift-config
token_meta_service_account_secret_name    vault-secret-reader
token_meta_service_account_uid            ...
```

You can use the token returned by the `vault write` command to access the vault as the specified ServiceAccount:

```
VAULT_TOKEN=hvs.... vault kv get nerc/nerc-ocp-prod/openshift-config/github-client-secret
```

This should return something like:

```
======================== Secret Path ========================
nerc/data/nerc-ocp-prod/openshift-config/github-client-secret

======= Metadata =======
Key                Value
---                -----
created_time       2022-10-10T21:01:13.878553647Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1

======== Data ========
Key             Value
---             -----
clientSecret    ...
```

You should receive an error if you attempt to access a secret associated with another cluster. Using a token for `nerc-ocp-prod`, if we attempt to access a secret for the `nerc-ocp-infra` cluster...

```
VAULT_TOKEN=hvs.... vault kv get nerc/nerc-ocp-infra/openshift-config/github-client-secret
```

...we should see a failure like this:

```
Error reading nerc/data/nerc-ocp-infra/openshift-config/github-client-secret: Error making API request.

URL: GET https://vault-ui-vault.apps.nerc-ocp-infra.rc.fas.harvard.edu/v1/nerc/data/nerc-ocp-infra/openshift-config/github-client-secret
Code: 403. Errors:

* 1 error occurred:
        * permission denied
```
