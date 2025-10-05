MODULE=forkmixer
SPHINXBUILD=sphinx-build
ALLSPHINXOPTS= -d $(BUILDDIR)/doctrees $(PAPEROPT_$(PAPER)) $(SPHINXOPTS) .
BUILDDIR=_build

all: $(VIRTUAL_ENV)

.PHONY: help
# target: help - Display callable targets
help:
	@egrep "^# target:" [Mm]akefile

.PHONY: clean
# target: clean - Clean repo
clean:
	@rm -rf build dist docs/_build
	find $(CURDIR)/$(MODULE) -name "*.pyc" -delete
	find $(CURDIR)/$(MODULE) -name "*.orig" -delete
	find $(CURDIR)/$(MODULE) -name "__pycache__" -delete


# ==============
#  Bump version
# ==============

.PHONY: release
VERSION?=minor
# target: release - Bump version
release:
	@uv run bump2version $(VERSION)
	@git checkout master
	@git merge develop
	@git checkout develop
	@git push origin master develop
	@git push --tags

.PHONY: minor
minor: release

.PHONY: patch
patch:
	make release VERSION=patch


# ===============
#  Build package
# ===============

.PHONY: upload
# target: upload - Upload module on PyPi
upload: clean
	@uv build
	@uv run twine upload dist/*.whl || true
	@uv run twine upload dist/*.tar.gz || true

.PHONY: docs
# target: docs - Compile the docs
docs: $(VIRTUAL_ENV)
	@uv run sphinx-build -b html docs/ docs/_build/html


# =============
#  Development
# =============

VIRTUAL_ENV 	?= $(CURDIR)/.venv

.PHONY: install
# target: install - Install project dependencies with uv
install:
	@command -v uv >/dev/null 2>&1 || { echo "uv is not installed. Please install it first: https://github.com/astral-sh/uv"; exit 1; }
	@uv sync --extra tests

.PHONY: dev
# target: dev - Setup development environment
dev: install

$(VIRTUAL_ENV): pyproject.toml
	@command -v uv >/dev/null 2>&1 || { echo "uv is not installed. Please install it first: https://github.com/astral-sh/uv"; exit 1; }
	@uv sync --extra tests
	@touch $(VIRTUAL_ENV)

TEST=tests
.PHONY: t
# target: t - Runs tests
t: clean $(VIRTUAL_ENV)
	uv run pytest $(TEST) -s

.PHONY: audit
# target: audit - Audit code
audit: $(VIRTUAL_ENV)
	@uv run pylama $(MODULE) -i E501

.PHONY: serve
# target: serve - Run HTTP server with compiled docs
serve:
	pyserve docs/_build/html/

.PHONY: pep8
pep8:
	find $(MODULE) -name "*.py" | xargs -n 1 autopep8 -i
