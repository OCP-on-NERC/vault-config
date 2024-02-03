local groups = [
  { name: 'nerc-ops', policy: 'nerc-all-writer' },
  { name: 'vault-admins', policy: 'admin' },
  { name: 'nerc-org-admins', policy: 'admin' },
];

{
  groups: [
    {
      name: group.name,
      type: 'external',
      policy: group.policy,
      auth_name: 'oidc',
    }
    for group in groups
  ],
}
