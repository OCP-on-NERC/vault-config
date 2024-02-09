import os
import requests
import logging
import fnmatch

from urllib.parse import urljoin

LOG = logging.getLogger(__name__)


class VaultConfig:
    def __init__(self, vault_url=None, vault_token=None, dryrun=False):
        self.vault_url = vault_url or os.environ["VAULT_ADDR"]
        self.session = requests.Session()
        self.session.headers["x-vault-token"] = vault_token or os.environ["VAULT_TOKEN"]
        self.dryrun = dryrun

    def get_mount_accessor(self, auth_name):
        res = self.get(f"/v1/sys/auth/{auth_name}")
        return res["data"]["accessor"]

    def get_group(self, group_name):
        try:
            res = self.get(f"/v1/identity/group/name/{group_name}")
        except requests.exceptions.HTTPError as e:
            if e.response.status_code != 404:
                raise

            raise KeyError(group_name)

        return res

    def create_or_update_group(
        self,
        group_name,
        group_type,
        group_policy,
    ):
        group = {
            "name": group_name,
            "type": group_type,
            "policies": [group_policy],
        }

        LOG.info("update group %s", group_name)
        self.post("/v1/identity/group", data=group)

        # If the group already exists, the previous call updates it
        # but returns no content, so we explicitly fetch the group
        # in order to return it to caller.
        return self.get_group(group_name)

    def delete_group(self, group_name):
        self.delete(f"/v1/identity/group/name/{group_name}")

    def group_exists(self, group_name):
        try:
            self.get_group(group_name)
        except KeyError:
            return False

        return True

    def create_group_alias(self, auth_name, group_name, alias_name=None):
        alias_name = alias_name or group_name
        mount_accessor = self.get_mount_accessor(auth_name)
        group = self.get_group(group_name)

        if (
            "alias" in group["data"]
            and group["data"]["alias"]["name"] == alias_name
            and group["data"]["alias"]["mount_accessor"] == mount_accessor
        ):
            LOG.info("not modifying group alias %s: no changes", alias_name)
            return

        alias = {
            "name": alias_name,
            "mount_accessor": mount_accessor,
            "canonical_id": group["data"]["id"],
        }

        LOG.info("create group alias %s", alias_name)
        res = self.post("v1/identity/group-alias", data=alias)
        res.raise_for_status()

    def post(self, resource, data):
        if self.dryrun:
            return

        url = urljoin(self.vault_url, resource)
        res = self.session.post(url, json=data)
        res.raise_for_status()

        try:
            return res.json()
        except requests.exceptions.JSONDecodeError:
            return

    def get(self, resource):
        url = urljoin(self.vault_url, resource)
        res = self.session.get(url)
        res.raise_for_status()

        try:
            return res.json()
        except requests.exceptions.JSONDecodeError:
            return

    def delete(self, resource):
        url = urljoin(self.vault_url, resource)
        res = self.session.get(url)
        res.raise_for_status()

    def apply_config(
        self, loader, path_restrictions=None, config_resources=True, config_groups=True
    ):
        for path in loader:
            LOG.info("apply config from %s", path)
            data = loader.get(path)

            if config_resources:
                for resource in data.get("resources", []):
                    url = resource["path"]
                    if path_restrictions:
                        for pattern in path_restrictions:
                            if fnmatch.fnmatch(url, pattern):
                                break
                        else:
                            LOG.info("skipping %s: does not match restrictions", url)
                            continue

                    if resource.get("if-not-exists"):
                        try:
                            self.get(url)
                        except requests.exceptions.HTTPError:
                            pass
                        else:
                            LOG.info(
                                "not creating %s: already exists", resource["path"]
                            )
                            continue

                    LOG.info("update %s", resource["path"])
                    self.post(url, data=resource["payload"])

            if config_groups:
                for group in data.get("groups", []):
                    self.create_or_update_group(
                        group["name"], group["type"], group["policy"]
                    )
                    if group["type"] == "external":
                        self.create_group_alias(
                            group["auth_name"],
                            group["name"],
                            alias_name=group.get("alias_name"),
                        )
