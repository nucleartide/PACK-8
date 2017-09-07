# Run the program.
run: build
	@(cd project/ && ../pack8 main.lua)
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
