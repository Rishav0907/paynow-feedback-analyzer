export enum SentimentType {
  Positive = 'Positive',
  Negative = 'Negative',
  Neutral = 'Neutral'
}

export interface SentimentAnalysisResult {
  sentiment: SentimentType;
  painPoint: string;
  positiveQuote: string;
}

export interface AnalysisError {
  message: string;
}