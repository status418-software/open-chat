CONTAINER_NAME=ollama
MODEL_NAME=llama3.2:1b
# MODEL_NAME=tinyllama
API_DIR=backend/api
OLLAMA_DIR=backend/ollama
TOOLS_DIR=tools
GO_API_IMAGE_NAME=api
GO_API_CONTAINER_NAME=api

help:
	@echo "Makefile for Ollama and API setup"
	@echo "Usage:"
	@echo "  make build          Build and start the Ollama and API containers, copies models from host or pulls them if unavailable"
	@echo "  make copy-model     Copy models from host to Ollama container"
	@echo "  make create-network Create Docker network for Ollama"
	@echo "  make remove-network Remove Docker network for Ollama"
	@echo "  make ollama-start   Start the Ollama container"
	@echo "  make ollama-stop    Stop the Ollama container"
	@echo "  make api-start      Start the API container"
	@echo "  make api-stop       Stop the API container"
	@echo "  make pull-model     Pull the model into the Ollama container"
	@echo "  make clean          Clean up Docker containers, volumes and images"
	@echo "  make clobber        Remove all Docker resources"
	@echo "  make restart        Restart the Ollama and API containers"

.PHONY: build copy-model pull-model create-network remove-network ollama-start ollama-stop api-start api-stop clean clobber restart 

# build will attempt to copy models from host, if not available it will pull them
build:
	@$(MAKE) ollama-start
	@$(MAKE) copy-model || $(MAKE) pull-model
	@$(MAKE) api-start

copy-model:
	@echo "Copying models into the running Ollama container..."
	docker cp "$(HOME)/.ollama/models/." $(CONTAINER_NAME):/root/.ollama/models

pull-model:
	docker exec $(CONTAINER_NAME) ollama pull $(MODEL_NAME)

create-network:
	docker network create ollama-net || true

remove-network:
	docker network rm ollama-net || true

ollama-start: create-network
	cd $(OLLAMA_DIR); docker compose up -d

ollama-stop:
	cd $(OLLAMA_DIR); docker compose down -v

api-start:
	cd $(API_DIR); docker compose up --build -d

api-stop:
	cd $(API_DIR); docker compose down -v

clean:
	cd $(TOOLS_DIR); chmod +x ./clean-docker.sh; ./clean-docker.sh

clobber:
	cd $(TOOLS_DIR); chmod +x ./clobber-docker.sh; ./clobber-docker.sh

restart: ollama-stop api-stop remove-network create-network ollama api
