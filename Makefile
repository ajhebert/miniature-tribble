VERSION := 2022.10.1
VSCODE_PYTHON := vscode-python-${VERSION}
RUN_ADAPTER := src/${VSCODE_PYTHON}/pythonFiles/testing_tools/run_adapter.py

.PHONY: all clean
all: output/run_adapter.txt output/pytest.txt

output:
	mkdir -p output

# run_adapter
output/run_adapter.txt: output ${RUN_ADAPTER} src/${VSCODE_PYTHON} .venv
	source `find .venv -type f -name 'activate'` && \
	python  ${RUN_ADAPTER} discover pytest -- --rootdir . -s --cache-clear src/tests | black - > $@

output/pytest.txt: output .venv
	source `find .venv -type f -name 'activate'` && \
	pytest --rootdir . -s --cache-clear src/tests > $@

src/${VSCODE_PYTHON}: ${VSCODE_PYTHON}.zip
	unzip -u ${VSCODE_PYTHON}.zip -d src/

${VSCODE_PYTHON}.zip:
	curl -L https://github.com/microsoft/vscode-python/archive/${VERSION}.zip --output ${VSCODE_PYTHON}.zip

poetry.lock:
	poetry lock

.venv: pyproject.toml poetry.lock
	poetry install

clean:
	rm -rf output 
	rm -rf src/${VSCODE_PYTHON}
	rm -rf ${VSCODE_PYTHON}.zip
