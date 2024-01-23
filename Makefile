include docker.mk

.DEFAULT_GOAL := build
build:
	$(call docker.build)
