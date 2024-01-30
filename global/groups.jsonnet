local vault_groups = [
  {
    name: 'nerc-ops',
    policy: 'nerc-all-writer',
  },
  {
    name: 'vault-admins',
    policy: 'admin',
  },
  {
    name: 'nerc-org-admins',
    policy: 'admin',
  },
];

{
  resources: [
    {
      path: "v1/identity/group",
      payload: {
        name: group.name,
        type: "external",
        policies: [group.policy],
      },
    }
    for group in vault_groups
  ],
}
