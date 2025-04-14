CONTAINER_NAME=ollama3.2
MODEL_NAME=llama3.2
API_DIR=backend/api
OLLAMA_DIR=backend/ollama
GO_API_IMAGE_NAME=go-api
GO_API_CONTAINER_NAME=api

.PHONY: build create-network ollama ollama-stop api api-stop pull-model

build: ollama api pull-model
	
create-network:
	docker network create ollama-net || true

ollama: create-network
	cd $(OLLAMA_DIR); docker compose up -d

ollama-stop:
	cd $(OLLAMA_DIR); docker compose down -v

api:
	cd $(API_DIR); docker compose up --build -d

api-stop:
	cd $(API_DIR); docker compose down -v

pull-model:
	docker exec $(CONTAINER_NAME) ollama pull $(MODEL_NAME)
