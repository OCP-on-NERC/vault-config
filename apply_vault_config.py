import argparse
import logging

from vault_config.loader import Loader
from vault_config.config import VaultConfig

import dotenv
dotenv.load_dotenv()

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument('--load-only', action='store_true')
    p.add_argument('--verbose', '-v', action='count', default=0)
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
        loader.load("config/global/kv2.jsonnet")
        loader.load("config/global/policies.jsonnet")
        loader.load("config/global/oidc.jsonnet")
        loader.load("config/global/groups.jsonnet")
        loader.load("config/clusters/hypershift1.jsonnet")
        loader.load("config/clusters/nerc-ocp-prod.jsonnet")
        loader.load("config/clusters/nerc-ocp-obs.jsonnet")
        loader.load("config/clusters/nerc-ocp-infra.jsonnet")

        if not args.load_only:
            vc.apply_config(loader)

if __name__ == "__main__":
    main()
