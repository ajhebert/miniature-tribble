# miniature-tribble
Reproduce issue with VSCode Python Extension

## Root Cause
[`_pytest_item.py`](src/vscode-python-2022.10.1/pythonFiles/testing_tools/adapter/pytest/_pytest_item.py)`:140` does not account for `pytest.Item` subclasses *except* for `pytest.Function`. Although it's easy to accomodate this condition, it may be difficult to discovery the root cause.

```python
def _get_item_kind(item):
    """Return (kind, isunittest) for the given item."""
    if isinstance(item, _pytest.doctest.DoctestItem):
        return "doctest", False
    elif isinstance(item, _pytest.unittest.TestCaseFunction):
        return "function", True
    elif isinstance(item, pytest.Function):
        # We *could* be more specific, e.g. "method", "subtest".
        return "function", False
    else:
        return None, False
```

## To Reproduce
Run `make` and examine [run_adapter.txt](output/run_adapter.txt), which contains a list of the parents and tests found during discovery. There are three parents and one test in this file. [conftest.py](src\conftest.py) specifies additional Collectors and Items for yaml files, and a user would expect these to appear in run_adpater.txt as well. [run_adapter.fixed.txt](output\run_adapter.fixed.txt) has the correct output.

```bash
source `ls .venv/*/activate` # system-agnostic .venv activation

# Generate 'incorrect' Results
python  ${RUN_ADAPTER} discover pytest -- --rootdir . -s --cache-clear src/tests

# Generate Correct Results
env FIX_CODE=true python  ${RUN_ADAPTER} discover pytest -- --rootdir . -s --cache-clear src/tests
```

From `src\vscode-python-2022.10.1\pythonFiles\testing_tools\adapter\pytest\_pytest_item.py:542`: