import React from 'react';

export const Loader: React.FC = () => {
  return (
    <div className="flex justify-center items-center p-4">
      <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
      <span className="ml-3 text-indigo-600 font-medium">Analyzing feedback...</span>
    </div>
  );
};