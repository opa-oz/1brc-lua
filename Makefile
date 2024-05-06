.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


generate: ## Generate file with defined lines amount
	python generator/main.py 1000000

.PHONY: generate

clear: ## Clear output directory
	@rm -rf output
	@mkdir -p output

.PHONY: clear

build: clear ## Build using LuaC
	@luac -o ./output/impl.out ./implementation/impl.lua

.PHONY: build

run: build ## Build and run Lua code
	@lua ./output/impl.out

.PHONY: run

production: build ## Generate 1B rows and make production run of compiled lua
	@echo "Generate 1B rows"
	@python generator/main.py 100000000
	@echo "You see me rollin'"
	@lua ./output/impl.out

.PHONY: production