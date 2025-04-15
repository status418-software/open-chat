CONTAINER_NAME=ollama
# MODEL_NAME=llama3.2:1b
MODEL_NAME=tinyllama
API_DIR=backend/api
OLLAMA_DIR=backend/ollama
GO_API_IMAGE_NAME=api
GO_API_CONTAINER_NAME=api

help:
	@echo "Makefile for Ollama and API setup"
	@echo "Usage:"
	@echo "  make build          Build and start the Ollama and API containers"
	@echo "  make create-network Create Docker network for Ollama"
	@echo "  make remove-network Remove Docker network for Ollama"
	@echo "  make ollama         Start the Ollama container"
	@echo "  make ollama-stop    Stop the Ollama container"
	@echo "  make api           Start the API container"
	@echo "  make api-stop      Stop the API container"
	@echo "  make pull-model    Pull the model into the Ollama container"
	@echo "  make clean         Clean up Docker containers, volumes and images"
	@echo "  make clobber       Remove all Docker resources"
	@echo "  make restart       Restart the Ollama and API containers"

.PHONY: build create-network remove-network ollama ollama-stop api api-stop pull-model clean clobber restart

build: ollama api pull-model
	
create-network:
	docker network create ollama-net || true

remove-network:
	docker network rm ollama-net || true

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

clean:
	cd utility; chmod +x ./clean-docker.sh; ./clean-docker.sh

clobber:
	cd utility; chmod +x ./clobber-docker.sh; ./clobber-docker.sh

restart: ollama-stop api-stop remove-network create-network ollama api
