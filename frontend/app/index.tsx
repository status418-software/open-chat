import { IMessageObject } from "@/types/messageTypes";
import sendPrompt from "@/utils/sendPrompt";
import { useEffect, useRef, useState } from "react";
import {
  Text,
  KeyboardAvoidingView,
  TextInput,
  FlatList,
  Keyboard,
  TouchableWithoutFeedback,
} from "react-native";

export default function Index() {
  const [messages, setMessages] = useState<IMessageObject[]>([
    { from: "chatbot", message: "Hello, how can I help you today?" },
  ]);
  const [userInput, setUserInput] = useState("");
  const flatListRef = useRef<FlatList>(null);

  const handleSubmitMessage = async () => {
    const inputText = userInput.trim();
    if (inputText === "") return;

    const newMessage = {
      from: "user",
      message: inputText,
    };

    setMessages((prev) => [...prev, newMessage]);
    setUserInput("");
    const reply = await sendPrompt(inputText);
    setMessages((prev) => [
      ...prev,
      {
        from: "chatbot",
        message: reply.response,
      },
    ]);
  };

  useEffect(() => {
    setTimeout(() => {
      flatListRef.current?.scrollToEnd({ animated: true });
    }, 100);
  }, [messages]);

  return (
    <KeyboardAvoidingView style={{ flex: 1 }}>
      <TouchableWithoutFeedback onPress={Keyboard.dismiss}>
        <FlatList
          data={messages}
          renderItem={({ item }) => (
            <Text
              style={
                item.from === "user"
                  ? {
                      margin: 5,
                      padding: 10,
                      alignSelf: "flex-end",
                      backgroundColor: "#ddd",
                      borderRadius: 20,
                    }
                  : {
                      margin: 5,
                      padding: 10,
                      backgroundColor: "blue",
                      alignSelf: "flex-start",
                      color: "#fff",
                      borderRadius: 20,
                    }
              }
            >
              {item.message}
            </Text>
          )}
          keyExtractor={(item, index) => `${item.message} + ${index}`}
          contentContainerStyle={{ marginVertical: 10 }}
          ref={flatListRef}
        />
      </TouchableWithoutFeedback>
      <TextInput
        value={userInput}
        onChangeText={setUserInput}
        onSubmitEditing={handleSubmitMessage}
        placeholder="Type a message..."
        style={{
          backgroundColor: "#fff",
          borderTopWidth: 1,
          borderBottomWidth: 1,
          padding: 10,
        }}
        returnKeyType="send"
      />
    </KeyboardAvoidingView>
  );
}
