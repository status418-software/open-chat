IMAGE_NAME=alpine/llama3.2
CONTAINER_NAME=ollama3.2
MODEL_NAME=llama3.2
PROMPT="What is software?"

.PHONY: pull-image run pull-model chat test stop clean

pull-image:
	docker pull $(IMAGE_NAME)

run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 11434:11434 \
		-v ollama_data:/root/.ollama \
		$(IMAGE_NAME)

# leaves the terminal open in a usable prompt
# pull-model:
# 	docker exec -it $(CONTAINER_NAME) ollama run $(MODEL_NAME)

# pulls the model but does not leave it running in the terminal
pull-model:
	docker exec $(CONTAINER_NAME) ollama pull $(MODEL_NAME)

# allows you to exec into the container and run a chat in terminal
chat:
	docker exec -it $(CONTAINER_NAME) ollama run $(MODEL_NAME)

# runs a test query against the model (Ollama) and will stream the response to the terminal. replace prompt variable at the top with a string with your own
test:
	@echo "Waiting for Ollama to be ready..."
	@counter=0; \
	until curl -s -f http://localhost:11434 | grep -q "Ollama is running"; do \
		if [ $$counter -ge 15 ]; then \
			echo "Ollama not ready after 30 seconds."; \
			exit 1; \
		fi; \
		echo "Waiting..."; \
		sleep 2; \
		counter=$$((counter + 1)); \
	done; \
	echo "Ollama is ready. Streaming response..."; \
	curl -Ns http://localhost:11434/api/generate \
	  -H "Content-Type: application/json" \
	  -d '{"model": "$(MODEL_NAME)", "prompt": $(PROMPT), "stream": true}' \
	  | jq -rc --unbuffered 'select(.response) | .response' \
	  | while IFS= read -r token; do \
	      printf "%s" "$$token"; \
	    done; \
	echo ""

# stops the container and removes it
stop:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || truee

# runs make stop then removes the volume
clean: stop
	docker volume rm ollama_data || true
