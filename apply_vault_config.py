import argparse
import logging

from vault_config.loader import Loader
from vault_config.config import VaultConfig

import dotenv

dotenv.load_dotenv()

CLUSTERS = [
    "hypershift1",
    "nerc-ocp-prod",
    "nerc-ocp-infra",
    "nerc-ocp-obs",
]


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--load-only", action="store_true")
    p.add_argument("--verbose", "-v", action="count", default=0)
    p.add_argument("--clusters", "-c", action="append", default=None)
    p.add_argument(
        "--no-clusters",
        action="store_const",
        const=True,
        default=False,
    )
    p.add_argument(
        "--no-global",
        action="store_const",
        const=True,
        default=False,
    )
    return p.parse_args()


def main():
    args = parse_args()
    if args.clusters is None:
        args.clusters = CLUSTERS
    else:
        args.clusters = [name for group in args.clusters for name in group.split(",")]

    loglevel = [logging.INFO, logging.DEBUG][min(args.verbose, 1)]
    logging.basicConfig(level=loglevel)

    loader = Loader(import_directories=["lib", "data"])
    vc = VaultConfig()

    with loader:
        # Only load files explicitly: no walking directories or wildcards.
        # This prevents us from accidentally picking up files that are
        # incomplete, inaccurate, or still under development.

        if not args.no_global:
            loader.load("config/global/kv2.jsonnet")
            loader.load("config/global/policies.jsonnet")
            loader.load("config/global/oidc.jsonnet")
            loader.load("config/global/groups.jsonnet")

        if not args.no_clusters:
            for cluster in args.clusters:
                loader.load(f"config/clusters/{cluster}.jsonnet")

        if not args.load_only:
            vc.apply_config(loader)


if __name__ == "__main__":
    main()
