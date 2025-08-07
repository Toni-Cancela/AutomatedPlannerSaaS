import React from 'react'

export const TermsFooter: React.FC = () => {
  return (
    <div className="absolute bottom-8 left-16 right-16">
      <p className="text-xs theme-text-secondary text-center">
        By signing up, you agree to our{' '}
        <a href="#" className="theme-accent hover:underline">
          Terms of Use
        </a>{' '}
        and{' '}
        <a href="#" className="theme-accent hover:underline">
          Privacy Policy
        </a>
        .
      </p>
    </div>
  )
}