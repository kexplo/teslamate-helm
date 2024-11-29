.PHONY: build

build:
	helm package teslamate
	helm repo index .
