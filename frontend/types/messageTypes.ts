interface IMessageObject {
  from: string;
  message: string;
}

interface IPromptResponse {
  response: string;
}

export type { IMessageObject, IPromptResponse };
