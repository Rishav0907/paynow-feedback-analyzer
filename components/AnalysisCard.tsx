import React from 'react';
import { SentimentAnalysisResult, SentimentType } from '../types';
import { 
  CheckCircleIcon, 
  ExclamationTriangleIcon, 
  ChatBubbleLeftRightIcon, 
  ArrowPathIcon,
  MinusCircleIcon,
  ExclamationCircleIcon
} from '@heroicons/react/24/solid';

interface AnalysisCardProps {
  result: SentimentAnalysisResult;
  onReset: () => void;
}

export const AnalysisCard: React.FC<AnalysisCardProps> = ({ result, onReset }) => {
  const getSentimentBadge = (sentiment: SentimentType) => {
    switch (sentiment) {
      case SentimentType.Positive:
        return (
          <span className="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-semibold bg-green-50 text-green-700 border border-green-200 shadow-sm">
            <CheckCircleIcon className="w-4 h-4 mr-1.5 text-green-600" />
            Positive
          </span>
        );
      case SentimentType.Negative:
        return (
          <span className="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-semibold bg-red-50 text-red-700 border border-red-200 shadow-sm">
            <ExclamationCircleIcon className="w-4 h-4 mr-1.5 text-red-600" />
            Negative
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center px-4 py-1.5 rounded-full text-sm font-semibold bg-gray-50 text-gray-700 border border-gray-200 shadow-sm">
            <MinusCircleIcon className="w-4 h-4 mr-1.5 text-gray-500" />
            Neutral
          </span>
        );
    }
  };

  return (
    <div className="w-full bg-white rounded-2xl shadow-xl shadow-gray-200/60 border border-gray-100 overflow-hidden animate-fade-in-up">
      {/* Header */}
      <div className="px-8 py-6 border-b border-gray-100 flex items-start justify-between bg-white">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Analysis Results</h2>
          <p className="text-sm text-gray-500 mt-1 font-medium">Insights extracted from customer feedback</p>
        </div>
        <div>
          {getSentimentBadge(result.sentiment)}
        </div>
      </div>

      {/* Body with Timeline */}
      <div className="p-8 relative bg-white">
        {/* Timeline line background */}
        <div className="absolute left-8 top-10 bottom-10 w-0.5 bg-gray-100 ml-[11px] z-0 hidden sm:block"></div>

        <div className="space-y-10 relative z-10">
          {/* Pain Point Item */}
          <div className="flex flex-col sm:flex-row sm:items-start gap-5">
            <div className="hidden sm:flex flex-shrink-0 relative">
              <div className="w-6 h-6 rounded-full bg-amber-400 border-4 border-white ring-1 ring-gray-100 shadow-sm z-10"></div>
            </div>
            <div className="flex-grow">
              <div className="flex items-center mb-2">
                <ExclamationTriangleIcon className="w-4 h-4 text-amber-500 mr-2 sm:hidden" />
                <span className="text-xs font-bold text-amber-500 uppercase tracking-widest flex items-center">
                  <ExclamationTriangleIcon className="w-3.5 h-3.5 mr-2 hidden sm:inline-block opacity-80" />
                  Key Pain Point
                </span>
              </div>
              <p className="text-gray-900 text-lg font-medium leading-relaxed">
                {result.painPoint}
              </p>
            </div>
          </div>

          {/* Highlight Item */}
          <div className="flex flex-col sm:flex-row sm:items-start gap-5">
            <div className="hidden sm:flex flex-shrink-0 relative">
               <div className="w-6 h-6 rounded-full bg-indigo-500 border-4 border-white ring-1 ring-gray-100 shadow-sm z-10"></div>
            </div>
            <div className="flex-grow">
              <div className="flex items-center mb-2">
                <ChatBubbleLeftRightIcon className="w-4 h-4 text-indigo-500 mr-2 sm:hidden" />
                <span className="text-xs font-bold text-indigo-500 uppercase tracking-widest flex items-center">
                   <ChatBubbleLeftRightIcon className="w-3.5 h-3.5 mr-2 hidden sm:inline-block opacity-80" />
                   Top Positive Highlight
                </span>
              </div>
              <p className="text-gray-900 text-lg font-medium italic leading-relaxed">
                "{result.positiveQuote}"
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="bg-gray-50 px-8 py-5 border-t border-gray-100 flex justify-end">
        <button 
          onClick={onReset}
          className="inline-flex items-center text-sm font-semibold text-gray-600 hover:text-indigo-600 transition-colors group"
        >
          <ArrowPathIcon className="w-4 h-4 mr-2 group-hover:rotate-180 transition-transform duration-500" />
          Analyze Another
        </button>
      </div>
    </div>
  );
};