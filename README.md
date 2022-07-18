# miniature-tribble
Reproduce issue with VSCode Python Extension

```python
import run_tests
>>> os.system(f"{str(python_exe)} {str(run_adapter)} discover pytest -- --rootdir . -s --cache-clear src/tests")

```