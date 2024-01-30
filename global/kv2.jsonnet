{
  resources: [
    {
      path: '/v1/sys/mounts/nerc/config',
      'if-not-exists': true,
      payload: {},
    },
  ],
}
