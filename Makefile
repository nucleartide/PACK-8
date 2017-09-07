# Run the program.
run: flow build
	@./pack8
	@./pack8 project/main.lua
	@./pack8 project/main.lua blah
.PHONY: run

# Build the project.
build: clean
	@mix escript.build
.PHONY: build

# Clean up build.
clean:
	@mix clean
.PHONY: clean

# Run tests.
test:
	@mix test
.PHONY: test

# Run linter.
lint:
	@mix credo list --strict
.PHONY: lint

# Run type check.
flow:
	@# @mix dialyzer >/dev/null # can't filter stderr :(
	@mix dialyzer
.PHONY: flow
