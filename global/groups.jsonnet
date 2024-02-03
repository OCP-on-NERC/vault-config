local group(name, policy, type='external', auth_name='oidc', alias_name=null) = {
  name: name,
  type: type,
  policy: policy,
  auth_name: auth_name,
  alias_name: alias_name,
};

{
  groups: [
    group('nerc-ops', 'nerc-all-writer'),
    group('vault-admins', 'admin'),
    group('nerc-org-admins', 'admin'),
  ],
}
