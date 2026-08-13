import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest

import yaml


LAUNCHER = Path(__file__).parents[1] / "rootfs/usr/local/bin/litellm-addon"
BUNDLED_CONFIG = Path(__file__).parents[1] / "rootfs/etc/litellm-addon/litellm.yaml"
ADDON_CONFIG = Path(__file__).parents[1] / "config.yaml"


def load_launcher():
    loader = importlib.machinery.SourceFileLoader("litellm_addon", str(LAUNCHER))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class LauncherTests(unittest.TestCase):
    def setUp(self):
        self.launcher = load_launcher()

    def test_default_config_is_valid_yaml_with_required_sections(self):
        config = yaml.safe_load(BUNDLED_CONFIG.read_text(encoding="utf-8"))
        self.assertEqual(config["model_list"], [])
        self.assertIn("guardrails", config)
        self.assertIn("master_key", config["general_settings"])
        self.assertEqual(
            config["general_settings"]["database_url"],
            "os.environ/DATABASE_URL",
        )
        self.assertNotIn("cache", config["litellm_settings"])
        self.assertNotIn("cache_params", config["litellm_settings"])

    def test_addon_config_directory_is_mounted_writable(self):
        config = yaml.safe_load(ADDON_CONFIG.read_text(encoding="utf-8"))
        self.assertIn(
            {"type": "addon_config", "read_only": False},
            config["map"],
        )
        self.assertEqual(
            config["options"]["database_host"],
            "db21ed7f-postgres",
        )
        self.assertEqual(config["schema"]["database_host"], "str")
        self.assertNotIn("database_url", config["options"])
        self.assertNotIn("database_url", config["schema"])
        self.assertNotIn("openrouter_api_key", config["options"])
        self.assertNotIn("openrouter_api_key", config["schema"])
        self.assertNotIn("redis_url", config["options"])
        self.assertNotIn("redis_url", config["schema"])

    def test_database_host_option_is_exported_as_url(self):
        original_options_file = self.launcher.OPTIONS_FILE
        original_data_dir = self.launcher.DATA_DIR
        original_salt_key_path = self.launcher.SALT_KEY_PATH
        original_chatgpt_token_dir_path = self.launcher.CHATGPT_TOKEN_DIR
        original_database_url = self.launcher.os.environ.get("DATABASE_URL")
        original_chatgpt_token_dir = self.launcher.os.environ.get("CHATGPT_TOKEN_DIR")
        persistent_variables = [
            "HOME",
            "XDG_CONFIG_HOME",
            "XDG_DATA_HOME",
            "XDG_STATE_HOME",
        ]
        original_persistent_environment = {
            variable: self.launcher.os.environ.get(variable)
            for variable in persistent_variables
        }
        try:
            with tempfile.TemporaryDirectory() as directory:
                directory_path = Path(directory)
                options_file = directory_path / "options.json"
                options_file.write_text(
                    '{"database_host": "db.example"}',
                    encoding="utf-8",
                )
                self.launcher.OPTIONS_FILE = options_file
                self.launcher.DATA_DIR = directory_path / "data"
                self.launcher.SALT_KEY_PATH = self.launcher.DATA_DIR / "salt_key"
                self.launcher.CHATGPT_TOKEN_DIR = self.launcher.DATA_DIR / "chatgpt"

                self.launcher.configure_environment()

                self.assertEqual(
                    self.launcher.os.environ["DATABASE_URL"],
                    "postgresql://postgres:homeassistant@db.example:5432/litellm",
                )
                self.assertEqual(
                    self.launcher.os.environ["CHATGPT_TOKEN_DIR"],
                    str(self.launcher.CHATGPT_TOKEN_DIR),
                )
                self.assertTrue(self.launcher.CHATGPT_TOKEN_DIR.is_dir())
                expected_directories = {
                    "HOME": self.launcher.DATA_DIR / "home",
                    "XDG_CONFIG_HOME": self.launcher.DATA_DIR / "home/.config",
                    "XDG_DATA_HOME": self.launcher.DATA_DIR / "home/.local/share",
                    "XDG_STATE_HOME": self.launcher.DATA_DIR / "home/.local/state",
                }
                for variable, expected_directory in expected_directories.items():
                    self.assertEqual(
                        self.launcher.os.environ[variable],
                        str(expected_directory),
                    )
                    self.assertEqual(expected_directory.stat().st_mode & 0o777, 0o700)
        finally:
            self.launcher.OPTIONS_FILE = original_options_file
            self.launcher.DATA_DIR = original_data_dir
            self.launcher.SALT_KEY_PATH = original_salt_key_path
            self.launcher.CHATGPT_TOKEN_DIR = original_chatgpt_token_dir_path
            if original_database_url is None:
                self.launcher.os.environ.pop("DATABASE_URL", None)
            else:
                self.launcher.os.environ["DATABASE_URL"] = original_database_url
            if original_chatgpt_token_dir is None:
                self.launcher.os.environ.pop("CHATGPT_TOKEN_DIR", None)
            else:
                self.launcher.os.environ["CHATGPT_TOKEN_DIR"] = original_chatgpt_token_dir
            for variable, original_value in original_persistent_environment.items():
                if original_value is None:
                    self.launcher.os.environ.pop(variable, None)
                else:
                    self.launcher.os.environ[variable] = original_value

    def test_salt_key_is_stable_and_private(self):
        with tempfile.TemporaryDirectory() as directory:
            self.launcher.DATA_DIR = Path(directory)
            self.launcher.SALT_KEY_PATH = Path(directory) / "salt_key"
            first = self.launcher.get_salt_key()
            second = self.launcher.get_salt_key()
            self.assertEqual(first, second)
            self.assertTrue(first.startswith("sk-salt-"))
            self.assertEqual(
                self.launcher.SALT_KEY_PATH.stat().st_mode & 0o777,
                0o600,
            )


if __name__ == "__main__":
    unittest.main()
