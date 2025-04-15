package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

type OllamaRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
	Stream bool   `json:"stream"`
}

type OllamaResponse struct {
	Response string `json:"response"`
	Done     bool   `json:"done"`
}

func queryOllama(model string, prompt string) (string, error) {
	ollamaURL := "http://ollama:11434/api/generate"

	requestData := OllamaRequest{
		Model:  model,
		Prompt: prompt,
		Stream: true, // for streaming responses, I still need to mess with this so the response chunks and returns like chatgpt does in its prompt window.
	}

	requestBody, err := json.Marshal(requestData)
	if err != nil {
		return "", fmt.Errorf("error marshalling request: %w", err)
	}

	client := &http.Client{
		Timeout: 60 * time.Second, // 60 second timeout for now
	}

	resp, err := client.Post(ollamaURL, "application/json", bytes.NewBuffer(requestBody))
	if err != nil {
		return "", fmt.Errorf("error sending request to Ollama: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("Ollama API error: %s - %s", resp.Status, string(bodyBytes))
	}

	var fullResponse string
	decoder := json.NewDecoder(resp.Body)
	for {
		var response OllamaResponse
		err := decoder.Decode(&response)
		if err == io.EOF {
			break
		}
		if err != nil {
			return "", fmt.Errorf("error decoding Ollama response: %w", err)
		}
		fullResponse += response.Response
		if response.Done {
			break
		}
	}

	return fullResponse, nil
}

func queryHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var reqData map[string]string
	err := json.NewDecoder(r.Body).Decode(&reqData)
	if err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	prompt, ok := reqData["prompt"]
	if !ok {
		http.Error(w, "Missing 'prompt' in request body", http.StatusBadRequest)
		return
	}

	// TODO: variable so models can be selected, from now this defaults to tinyllama
	model := os.Getenv("OLLAMA_MODEL")
	if model == "" {
		model = "tinyllama" // Defaults to a smaller model to keep rebuilds down.
	}

	response, err := queryOllama(model, prompt)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error querying Ollama: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"response": response})
}

func main() {
	http.HandleFunc("/api/query", queryHandler)
	port := os.Getenv("GO_API_PORT")
	if port == "" {
		port = "8080"
	}
	fmt.Printf("Go API server listening on port %s...\n", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}
