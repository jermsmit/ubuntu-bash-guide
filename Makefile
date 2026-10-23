IMAGE ?= ubuntu-bash-guide-lab
RUN   := docker run --rm -v "$(CURDIR):/work" -w /work $(IMAGE)

.PHONY: help lab shell test screenshots book serve lint clean

help:            ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-12s %s\n", $$1, $$2}'

lab:             ## Build the Ubuntu 26.04 lab image
	docker build -t $(IMAGE) .

shell: lab       ## Open an interactive shell in the lab
	docker run --rm -it $(IMAGE)

test: lab        ## Run every <!-- test --> example in the lab
	$(RUN) scripts/check-examples.sh

screenshots: lab ## Render real command output to src/images/*.svg
	docker run --rm --user "$$(id -u):$$(id -g)" -e HOME=/tmp -v "$(CURDIR):/work" -w /work $(IMAGE) scripts/make-screenshots.sh

book:            ## Build the site into ./book (needs mdbook installed)
	mdbook build

serve:           ## Live-preview at http://localhost:3000
	mdbook serve --open

lint:            ## Lint the Markdown (needs npx)
	npx --yes markdownlint-cli2 "src/**/*.md" "*.md"

clean:           ## Remove build output and generated images
	rm -rf book src/images/*.svg src/images/*.png
