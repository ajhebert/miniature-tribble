VERSION := 2022.10.1
VSCODE_PYTHON := vscode-python-${VERSION}
RUN_ADAPTER := src/${VSCODE_PYTHON}/pythonFiles/testing_tools/run_adapter.py

.PHONY: all over clean
all: output/run_adapter.txt output/run_adapter.fixed.txt

over: clean all
# run clean, then all

output/:
	mkdir -p output

.FORCE:
# run_adapter
output/run_adapter.txt: .FORCE output/ .venv/ src/${VSCODE_PYTHON}/
	source `find .venv -type f -name 'activate'` && \
	python  ${RUN_ADAPTER} discover pytest -- --rootdir . -s --cache-clear src/tests \
	| black -q - > $@ || true 
# Black is used to make the log more readable.

output/run_adapter.fixed.txt: .FORCE output/ .venv/ src/${VSCODE_PYTHON}/
	source `find .venv -type f -name 'activate'` && \
	env FIX_CODE=true python  ${RUN_ADAPTER} discover pytest -- --rootdir . -s --cache-clear src/tests \
	| black -q - > $@ || true 

output/pytest.txt: .FORCE output/ .venv/
	source `find .venv -type f -name 'activate'` && \
	pytest --rootdir . -s --cache-clear src/tests \
	> $@ || true

src/${VSCODE_PYTHON}/: ${VSCODE_PYTHON}.zip
	unzip -u ${VSCODE_PYTHON}.zip -d src/

${VSCODE_PYTHON}.zip:
	curl -L https://github.com/microsoft/vscode-python/archive/${VERSION}.zip --output ${VSCODE_PYTHON}.zip

pyproject.toml:
	poetry update

poetry.lock: pyproject.toml
	poetry lock

.venv/: pyproject.toml poetry.lock
	poetry install

clean:
	rm -rf output 
	rm poetry.lock
	rm -rf src/${VSCODE_PYTHON}
	rm -rf ${VSCODE_PYTHON}.zip
