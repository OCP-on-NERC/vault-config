import argparse
import logging

from vault_config.loader import Loader
from vault_config.config import VaultConfig

import dotenv

dotenv.load_dotenv()

CONFIGS = [
    "config/global/kv2.jsonnet",
    "config/global/oidc.jsonnet",
    "config/global/groups.jsonnet",
    "config/global/policies.jsonnet",
    "config/clusters/hypershift1.jsonnet",
    "config/clusters/nerc-ocp-infra.jsonnet",
    "config/clusters/nerc-ocp-obs.jsonnet",
    "config/clusters/nerc-ocp-prod.jsonnet",
    "config/clusters/nerc-ocp-test.jsonnet",
]


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument(
        "--load-only",
        "-l",
        action="store_true",
        help="Validate configuration files but do not apply configuration",
    )
    p.add_argument("--verbose", "-v", action="count", default=0)
    p.add_argument(
        "--clusters",
        "-c",
        action="append",
        default=None,
        help="Specify cluster configurations to apply",
    )
    p.add_argument(
        "--no-resources",
        action="store_const",
        const=True,
        default=False,
        help="Do not apply resources",
    )
    p.add_argument(
        "--no-groups",
        action="store_const",
        const=True,
        default=False,
        help="Do not apply groups",
    )
    p.add_argument(
        "--path",
        "-p",
        action="append",
        help="Only apply resources that match the specified glob patterns",
    )

    p.add_argument('configs', nargs='*', default=CONFIGS)
    return p.parse_args()


def main():
    args = parse_args()

    loglevel = [logging.INFO, logging.DEBUG][min(args.verbose, 1)]
    logging.basicConfig(level=loglevel)

    loader = Loader(import_directories=["lib", "data"])
    vc = VaultConfig()

    with loader:
        # Only load files explicitly: no walking directories or wildcards.
        # This prevents us from accidentally picking up files that are
        # incomplete, inaccurate, or still under development.

        for path in args.configs:
            loader.load(path)

        if not args.load_only:
            vc.apply_config(
                loader,
                path_restrictions=args.path,
                config_resources=(not args.no_resources),
                config_groups=(not args.no_groups),
            )


if __name__ == "__main__":
    main()
