# NERC Vault configuration

With our current Vault installation we're not able to configure Vault through Kubernetes resources. We still want to have a record of our configuration (so that we understand *why* it looks the way it does, and so that we have a way to re-apply it in the event we need to rebuild from scratch). This repository is that record; we use Ansible and the [community.hashi_vault][] collection to configure our Vault instance.

[community.hashi_vault]: https://github.com/ansible-collections/community.hashi_vault
