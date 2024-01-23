ORG ?= ccnmtl

ifeq ($(origin TAG), undefined)
	IMAGE ?= $(REGISTRY)$(ORG)/$(APP)
else
	IMAGE ?= $(REGISTRY)$(ORG)/$(APP):$(TAG)
endif

build:
	docker build -t $(IMAGE) .
