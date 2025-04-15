APP_NAME = AWS Terragrunt Framework

.PHONY: help install repo

help:
	@echo "Usage: make [command]"
	@echo
	@echo "Available commands:"
	@echo "  install         Installs dependencies (pip3 + name) and configures pre-commit"
	@echo "  lint            Runs requirements and pre-commit hooks"
	@echo "  clean           Removes temporary files"


install:
	@echo "Installing collection amazon.aws..."
	ansible-galaxy collection install -r collections.yml

	pip3 install -r requirements.txt
	pre-commit install
	
lint:
	pre-commit run --all-files
	
clean:
	rm -rf __pycache__ .cache .pytest_cache
	find . -name '*.retry' -delete
	find . -name '*.pyc' -delete