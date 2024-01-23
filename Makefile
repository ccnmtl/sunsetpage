APP=sunset
REGISTRY ?= docker.io/

include docker.mk

.DEFAULT_GOAL := build

main_target: build
	echo 'Docker build completed.'
