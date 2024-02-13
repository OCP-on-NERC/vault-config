{
  resources: [
    {
      path: '/v1/sys/policy/admin',
      payload: {
        policy: importstr 'policies/admin.hcl',
      },
    },
    {
      path: '/v1/sys/policy/default',
      payload: {
        policy: importstr 'policies/default.hcl',
      },
    },
    {
      path: '/v1/sys/policy/nerc-common-reader',
      payload: {
        policy: importstr 'policies/nerc-common-reader.hcl',
      },
    },
    {
      path: '/v1/sys/policy/nerc-all-reader',
      payload: {
        policy: importstr 'policies/nerc-all-reader.hcl',
      },
    },
    {
      path: '/v1/sys/policy/nerc-all-writer',
      payload: {
        policy: importstr 'policies/nerc-all-writer.hcl',
      },
    },
  ],
}
