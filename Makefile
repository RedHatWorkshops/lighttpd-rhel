
IMAGE_NAME = lighttpd-rhel

.PHONY: build
build:
	sudo docker build -t $(IMAGE_NAME) .

.PHONY: test
test:
	sudo docker build -t $(IMAGE_NAME)-candidate .
	IMAGE_NAME=$(IMAGE_NAME)-candidate test/run
