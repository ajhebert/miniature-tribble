# Code based on excerpts from https://docs.pytest.org/en/7.1.x/example/nonpython.html
import pytest, os

FIX_CODE = bool(os.environ["FIX_CODE"]) if "FIX_CODE" in os.environ else False


def pytest_collect_file(parent, file_path):
    if file_path.suffix == ".yaml" and file_path.name.startswith("test"):
        return YamlFile.from_parent(parent, path=file_path)


class YamlFile(pytest.File):
    def collect(self):
        # We need a yaml parser, e.g. PyYAML.
        import yaml

        raw = yaml.safe_load(self.path.open())
        for name, spec in sorted(raw.items()):
            yield YamlItem.from_parent(self, name=name, spec=spec)


YamlParent = pytest.Function if FIX_CODE else pytest.Item


class YamlItem(YamlParent):  # type: ignore
    def __init__(self, *, spec, **kwargs):
        if FIX_CODE:
            super().__init__(callobj=self.runtest, **kwargs)  # type: ignore
        else:
            super().__init__(**kwargs)
        self.spec = spec

    def runtest(self):
        for name, value in sorted(self.spec.items()):
            # Some custom test execution (dumb example follows).
            if name != value:
                raise YamlException(self, name, value)

    def repr_failure(self, excinfo):
        """Called when self.runtest() raises an exception."""
        if isinstance(excinfo.value, YamlException):
            return "\n".join(
                [
                    "usecase execution failed",
                    "   spec failed: {1!r}: {2!r}".format(*excinfo.value.args),
                    "   no further details known at this point.",
                ]
            )

    def reportinfo(self):
        return self.path, 0, f"{self.name}"


class YamlException(Exception):
    """Custom exception for error reporting."""
