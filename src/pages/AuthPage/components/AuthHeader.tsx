import React from 'react'

interface AuthHeaderProps {
  isSignUp: boolean
  setIsSignUp: (value: boolean) => void
}

export const AuthHeader: React.FC<AuthHeaderProps> = ({ isSignUp, setIsSignUp }) => {
  return (
    <div className="mb-8">
      <div className="flex items-center mb-8">
        <div className="w-8 h-8 theme-primary-bg rounded-lg flex items-center justify-center mr-3">
          <span className="text-white font-bold text-sm">G</span>
        </div>
        <span className="text-xl font-semibold theme-text">Glint</span>
      </div>
      
      {/* Tab Navigation */}
      <div className="relative flex theme-primary-light-bg rounded-lg p-1 mb-8">
        {/* Sliding indicator */}
        <div 
          className="absolute top-1 bottom-1 w-1/2 theme-primary-bg rounded-md transition-transform duration-300 ease-in-out"
          style={{
            transform: isSignUp ? 'translateX(0%)' : 'translateX(96%)'
          }}
        />
        
        <button
          onClick={() => setIsSignUp(true)}
          className={`relative z-10 flex-1 py-2 px-4 rounded-md text-sm font-regular transition-colors ${
            isSignUp
              ? 'theme-accent'
              : 'theme-text-secondary hover:theme-text'
          }`}
        >
          Sign Up
        </button>
        <button
          onClick={() => setIsSignUp(false)}
          className={`relative z-10 flex-1 py-2 px-4 rounded-md text-sm font-regular transition-colors ${
            !isSignUp
              ? 'theme-accent'
              : 'theme-text-secondary hover:theme-text'
          }`}
        >
          Sign In
        </button>
      </div>
    </div>
  )
}