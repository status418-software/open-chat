IMAGE_NAME=alpine/llama3.2
CONTAINER_NAME=ollama3.2
MODEL_NAME=llama3.2

.PHONY: pull-image run pull-model test stop clean

pull-image:
	docker pull $(IMAGE_NAME)

run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p 11434:11434 \
		-v ollama_data:/root/.ollama \
		$(IMAGE_NAME)

pull-model:
	docker exec -it $(CONTAINER_NAME) ollama run $(MODEL_NAME)

test:
	curl -s http://localhost:11434/api/generate \
	  -H "Content-Type: application/json" \
	  -d '{"model": "$(MODEL_NAME)", "prompt": "What is software?", "stream": false}' | jq -r '.response'


stop:
	docker stop $(CONTAINER_NAME) || true
	docker rm $(CONTAINER_NAME) || truee

clean: stop
	docker volume rm ollama_data || true
