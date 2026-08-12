import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest

import yaml


ADDON_CONFIG = Path(__file__).parents[1] / "config.yaml"
LAUNCHER = Path(__file__).parents[1] / "rootfs/usr/local/bin/cognee-addon"


def load_launcher():
    loader = importlib.machinery.SourceFileLoader("cognee_addon", str(LAUNCHER))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.launcher = load_launcher()

    def test_addon_config_persists_state_and_exposes_api(self):
        config = yaml.safe_load(ADDON_CONFIG.read_text(encoding="utf-8"))
        self.assertIn(
            {"type": "addon_config", "read_only": False, "path": "/data"},
            config["map"],
        )
        self.assertEqual(config["ports"]["8000/tcp"], 8000)
        self.assertEqual(config["arch"], ["aarch64", "amd64"])

    def test_options_are_mapped_to_environment(self):
        with tempfile.TemporaryDirectory() as directory:
            self.launcher.STATE_DIR = Path(directory)
            self.launcher.SECRETS_FILE = Path(directory) / "secrets.json"
            self.launcher.configure_environment(
                {
                    "llm_api_key": "secret",
                    "llm_provider": "custom",
                    "embedding_dimensions": 768,
                }
            )
            self.assertEqual(os.environ["LLM_API_KEY"], "secret")
            self.assertEqual(os.environ["LLM_PROVIDER"], "custom")
            self.assertEqual(os.environ["EMBEDDING_DIMENSIONS"], "768")
            self.assertEqual(os.environ["REQUIRE_AUTHENTICATION"], "true")
            self.assertEqual(os.environ["ACCEPT_LOCAL_FILE_PATH"], "false")
            self.assertEqual(os.environ["DATA_ROOT_DIRECTORY"], f"{directory}/data")
            self.assertTrue((Path(directory) / "data").is_dir())
            self.assertTrue((Path(directory) / "system" / "databases").is_dir())
            self.assertTrue((Path(directory) / "cache").is_dir())
            self.assertTrue((Path(directory) / "logs").is_dir())

    def test_generated_secrets_are_stable_and_private(self):
        with tempfile.TemporaryDirectory() as directory:
            self.launcher.STATE_DIR = Path(directory)
            self.launcher.SECRETS_FILE = Path(directory) / "secrets.json"
            first = self.launcher.get_secrets()
            second = self.launcher.get_secrets()
            self.assertEqual(first, second)
            self.assertEqual(set(first), {"jwt", "verification", "password_reset"})
            self.assertEqual(self.launcher.SECRETS_FILE.stat().st_mode & 0o777, 0o600)
            self.assertEqual(
                json.loads(self.launcher.SECRETS_FILE.read_text(encoding="utf-8")),
                first,
            )


if __name__ == "__main__":
    unittest.main()
