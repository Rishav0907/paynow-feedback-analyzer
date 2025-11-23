import React, { useState } from 'react';
import { analyzeSentiment } from './services/geminiService';
import { SentimentAnalysisResult } from './types';
import { Loader } from './components/Loader';
import { AnalysisCard } from './components/AnalysisCard';
import { ChartBarSquareIcon } from '@heroicons/react/24/solid';

const App: React.FC = () => {
  const [inputText, setInputText] = useState('');
  const [result, setResult] = useState<SentimentAnalysisResult | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleAnalyze = async () => {
    if (!inputText.trim()) {
      setError("Please enter some text to analyze.");
      return;
    }

    setIsLoading(true);
    setError(null);
    setResult(null);

    try {
      const analysis = await analyzeSentiment(inputText);
      setResult(analysis);
    } catch (err: any) {
      setError(err.message || "An unexpected error occurred.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleReset = () => {
    setResult(null);
    setInputText('');
  };

  return (
    <div className="min-h-screen bg-[#FAFAFA] flex flex-col font-sans">
      {/* Header */}
      <header className="bg-white border-b border-gray-100 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="bg-indigo-600 rounded-md p-1.5 shadow-sm">
              <ChartBarSquareIcon className="w-5 h-5 text-white" />
            </div>
            <span className="text-xl font-bold text-gray-900 tracking-tight">SentimentAI</span>
          </div>
          <div className="text-sm text-gray-500 font-medium hidden sm:block">
            Powered by Gemini 2.5
          </div>
        </div>
      </header>

      <main className="flex-grow flex flex-col items-center justify-start pt-12 sm:pt-16 px-4 sm:px-6 pb-12">
        <div className="w-full max-w-4xl text-center mb-10 space-y-4">
          <h1 className="text-4xl sm:text-5xl font-extrabold text-gray-900 leading-[1.15]">
            Turn Customer Feedback into<br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-violet-600">Actionable Insights</span>
          </h1>
          <p className="max-w-2xl mx-auto text-lg text-gray-600 leading-relaxed">
            Paste your reviews, emails, or survey responses below. Our AI will identify the
            sentiment, pinpoint the main problem, and highlight what's working.
          </p>
        </div>

        <div className="w-full max-w-2xl">
          {isLoading ? (
            <div className="bg-white rounded-2xl shadow-xl shadow-gray-200/50 border border-gray-100 p-16 flex justify-center items-center">
              <Loader />
            </div>
          ) : result ? (
            <AnalysisCard result={result} onReset={handleReset} />
          ) : (
            <div className="bg-white rounded-2xl shadow-xl shadow-gray-200/50 border border-gray-100 overflow-hidden transition-all duration-300 hover:shadow-2xl hover:shadow-gray-200/60">
              <div className="p-6 sm:p-8">
                <label htmlFor="feedback" className="block text-sm font-semibold text-gray-900 mb-3">
                  Customer Feedback
                </label>
                <div className="relative group">
                  <textarea
                    id="feedback"
                    rows={8}
                    className="block w-full rounded-xl border border-gray-200 bg-gray-50 p-4 text-gray-900 shadow-sm focus:border-indigo-500 focus:bg-white focus:ring-indigo-500 sm:text-sm resize-none placeholder-gray-400 transition-all duration-200 ease-in-out"
                    placeholder="Paste customer feedback here... (e.g., 'The product quality is great, but the shipping took way too long and customer service was unresponsive.')"
                    value={inputText}
                    onChange={(e) => setInputText(e.target.value)}
                  />
                  <div className="absolute bottom-3 right-3 pointer-events-none">
                    <div className="h-4 w-4 rounded-full bg-gray-200 group-focus-within:bg-indigo-100 transition-colors"></div>
                  </div>
                </div>
                
                {error && (
                  <div className="mt-4 p-4 rounded-xl bg-red-50 border border-red-100 flex items-start">
                    <div className="flex-shrink-0">
                      <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <div className="ml-3">
                      <p className="text-sm font-medium text-red-800">{error}</p>
                    </div>
                  </div>
                )}
                
                <div className="mt-6 flex items-center justify-between">
                  <span className="text-xs text-gray-400 font-medium font-mono">
                    {inputText.length} characters
                  </span>
                  <button
                    onClick={handleAnalyze}
                    disabled={!inputText.trim()}
                    className={`
                      inline-flex items-center px-6 py-2.5 border border-transparent text-sm font-semibold rounded-lg shadow-sm text-white 
                      transition-all duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500
                      ${!inputText.trim() 
                        ? 'bg-indigo-300 cursor-not-allowed opacity-70' 
                        : 'bg-indigo-600 hover:bg-indigo-700 hover:shadow-lg hover:-translate-y-0.5 active:translate-y-0'
                      }
                    `}
                  >
                    Analyze Feedback
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </main>

      <footer className="py-8 text-center text-gray-400 text-sm">
        <p>&copy; {new Date().getFullYear()} SentimentAI. Built with Gemini 2.5 Flash.</p>
      </footer>
    </div>
  );
};

export default App;