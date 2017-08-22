# Build the project.
build:
	@mix escript.build
.PHONY: build

# Clean up build.
clean:
	@rm -rf _build/
.PHONY: clean
