#!/bin/sh

# Until this gets rolled into a playbook, temporarily record the oidc auth
# configuration here.

tmpfile=$(mktemp secretXXXXXX.json)
trap 'rm -f $tmpfile'
vault kv get --format json nerc/nerc-ocp-infra/dex/dex-clients > "$tmpfile"
VAULT_SECRET="$(jq -r .data.data.VAULT_SECRET "$tmpfile")"

vault auth enable oidc

vault write auth/oidc/config \
	oidc_discovery_url="https://dex-dex.apps.nerc-ocp-infra.rc.fas.harvard.edu" \
	oidc_client_id="vault" \
	oidc_client_secret="$VAULT_SECRET" \
	default_role="ocp-user"

vault write auth/oidc/role/ocp-user \
	policies=default \
	user_claim=name \
	groups_claim=groups \
	allowed_redirect_uris="https://vault-ui-vault.apps.nerc-ocp-infra.rc.fas.harvard.edu/ui/vault/auth/oidc/oidc/callback" \
	oidc_scopes=openid,email,groups,profile
