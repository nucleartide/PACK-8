# Run the program.
run: build
	@./pack
.PHONY: run

# Build the project.
build: clean
	@mix escript.build
.PHONY: build

# Clean up build.
clean:
	@mix clean
.PHONY: clean
