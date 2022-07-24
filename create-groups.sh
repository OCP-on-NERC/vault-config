#!/bin/bash

# Record group creation process until we roll it into the playbook

tmpfile=$(mktemp vaultXXXXXX.json)
trap 'rm -f $tmpfile' EXIT

vault auth list --format json > "$tmpfile"
oidc_accessor="$(jq -r '."oidc/".accessor' "$tmpfile")"

create_group() {
	local group_name="$1"
	local policy="$2"

	if ! vault read -format json "identity/group/name/$group_name" > "$tmpfile"; then
		vault write -format json identity/group type=external name="group_name" policies="$policy" > /dev/null
		vault read -format json "identity/group/name/$group_name" > "$tmpfile"
	fi

	group_id="$(jq -r .data.id "$tmpfile")"
	group_alias="$(jq -r .data.alias.name "$tmpfile")"

	if [[ $group_alias != "$group_name" ]]; then
		vault write identity/group-alias name="$group_name" mount_accessor="$oidc_accessor" canonical_id="$group_id"
	fi
}

create_group nerc-org-admins admin
create_group nerc-ops nerc-all-writer
