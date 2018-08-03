REGISTRY := azurecontainerinstance.azurecr.io
APP := hello
GIT_TAG ?= latest

build:
	docker build -t ${REGISTRY}/${APP}:${GIT_TAG} .

login:
	docker login -u ${DOCKER_REGISTRY_USER} -p ${DOCKER_REGISTRY_PASSWORD} ${REGISTRY}

push:
	docker push ${REGISTRY}/${APP}

run:
	docker run --rm ${REGISTRY}/${APP}:${GIT_TAG}
