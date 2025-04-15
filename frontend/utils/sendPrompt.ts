import type { IPromptResponse } from "@/types/messageTypes";

export default async function sendPrompt(
  prompt: string
): Promise<IPromptResponse> {
  try {
    const response = await fetch("http://localhost:8080/api/query", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        prompt,
      }),
    });
    const results = await response.json();
    return results;
  } catch (error) {
    throw new Error(`Error: ${error}`);
  }
}
