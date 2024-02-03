import os
import tempfile
import json
import yaml
import logging
import jinja2
import _jsonnet as jsonnet

from pathlib import Path
from fnmatch import fnmatch
from contextlib import contextmanager

from .exceptions import InvalidFileTypeError

LOG = logging.getLogger(__name__)


class Loader:
    '''Load serialized data into a local cache.'''

    def __init__(self, import_directories=None):
        self.import_directories = import_directories or []
        self.paths = {}

    def __enter__(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        return self

    def __exit__(self, *args):
        self.tmpdir.cleanup()
        self.tmpdir = None

    def import_callback(self, parent, path):
        '''Resolve jsonnet imports'''

        LOG.debug("jsonnet import %s", path)
        for importdir in [parent] + self.import_directories:
            adjpath = os.path.join(importdir, path)
            try:
                with open(adjpath, "rb") as fd:
                    return path, fd.read()
            except FileNotFoundError:
                continue

        return None, None

    def load_yaml_file(self, path):
        with open(path) as fd:
            return yaml.safe_load(fd)

    def load_yaml_content(self, content):
        return yaml.safe_load(content)

    def process_template(self, path):
        with open(path) as fd:
            template = jinja2.Template(fd.read())

        return template.render()

    def load_json_file(self, path):
        with open(path) as fd:
            return json.load(fd)

    def load_jsonnet_file(self, path):
        content = jsonnet.evaluate_file(
            filename=path,
            import_callback=self.import_callback,
        )

        return json.loads(content)

    def load(self, path):
        '''Load a document into our local cache.

        This function unmarshals the given path into a Python data
        structure, and then writes it out as a JSON file in self.tmpdir.
        This pre-processing ensures that the files are syntactically
        correct and that any dependencies can be successfully resolved.
        '''

        LOG.debug("loading %s", path)
        if fnmatch(path, "*.yaml"):
            loader = self.load_yaml_file
        elif fnmatch(path, "*.j2.yaml"):
            loader = lambda path: self.load_yaml_content(self.process_template(path))
        elif fnmatch(path, "*.json"):
            loader = self.load_json_file
        elif fnmatch(path, "*.jsonnet"):
            loader = self.load_jsonnet_file
        else:
            raise InvalidFileTypeError(f"unsupported file extension: {path}")

        data = loader(path)
        cachefile = Path(self.tmpdir.name) / path.replace("/", "_")
        with cachefile.open("w") as fd:
            json.dump(data, fd)

        self.paths[path] = cachefile

    def get(self, path):
        if path not in self.paths:
            raise FileNotFoundError(path)

        with self.paths[path].open() as fd:
            return json.load(fd)

    def __iter__(self):
        return iter(self.paths)
