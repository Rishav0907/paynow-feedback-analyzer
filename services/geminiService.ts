import { GoogleGenAI, Type } from "@google/genai";
import { SentimentAnalysisResult, SentimentType } from "../types";

// Initialize the Gemini client
// The API key is obtained from the environment variable as per instructions
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export const analyzeSentiment = async (text: string): Promise<SentimentAnalysisResult> => {
  if (!text || text.trim().length === 0) {
    throw new Error("Please provide text to analyze.");
  }

  const model = "gemini-2.5-flash";

  const prompt = `
    Analyze the following customer feedback text. 
    Determine the overall sentiment (Positive, Negative, or Neutral).
    Identify the single most critical pain point described in one sentence. If there are no complaints, state "None detected".
    Extract the single most positive quote verbatim from the text. If there is no positive feedback, state "None detected".
    
    Feedback Text:
    "${text}"
  `;

  try {
    const response = await ai.models.generateContent({
      model: model,
      contents: prompt,
      config: {
        responseMimeType: "application/json",
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            sentiment: {
              type: Type.STRING,
              enum: [SentimentType.Positive, SentimentType.Negative, SentimentType.Neutral],
              description: "The overall sentiment of the feedback."
            },
            painPoint: {
              type: Type.STRING,
              description: "The key pain point summarized in one sentence, or 'None detected'."
            },
            positiveQuote: {
              type: Type.STRING,
              description: "The most positive quote extracted verbatim, or 'None detected'."
            }
          },
          required: ["sentiment", "painPoint", "positiveQuote"],
          propertyOrdering: ["sentiment", "painPoint", "positiveQuote"]
        }
      }
    });

    const responseText = response.text;
    if (!responseText) {
      throw new Error("No response received from Gemini.");
    }

    const result = JSON.parse(responseText) as SentimentAnalysisResult;
    return result;

  } catch (error) {
    console.error("Gemini Analysis Error:", error);
    throw new Error("Failed to analyze sentiment. Please try again.");
  }
};