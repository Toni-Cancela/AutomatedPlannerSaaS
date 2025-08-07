import React from 'react'
import { Check, X } from 'lucide-react'

interface PasswordStrengthIndicatorProps {
  password: string
  getPasswordStrength: (password: string) => string
  getPasswordStrengthIcon: (password: string) => React.ReactNode
}

export const PasswordStrengthIndicator: React.FC<PasswordStrengthIndicatorProps> = ({
  password,
  getPasswordStrength,
  getPasswordStrengthIcon,
}) => {
  return (
    <div>
      <div className="flex items-center space-x-2 mb-1">
        {getPasswordStrengthIcon(password)}
        <p className={`text-sm ${
          getPasswordStrength(password).includes('Weak') ? 'theme-error' :
          getPasswordStrength(password).includes('Medium') ? 'text-yellow-500' :
          'theme-primary-dark'
        }`}>
          {getPasswordStrength(password)}
        </p>
      </div>
      <div className="space-y-1 text-sm">
        <div className="flex items-center space-x-2">
          {!/[A-Z]/.test(password) ? (
            <X size={12} className="theme-error" />
          ) : (
            <Check size={12} className="theme-primary-dark" />
          )}
          <span className={!/[A-Z]/.test(password) ? 'theme-error' : 'theme-primary-dark'}>
            At least one uppercase letter
          </span>
        </div>
        <div className="flex items-center space-x-2">
          {!password || password.length < 8 ? (
            <X size={12} className="theme-error" />
          ) : (
            <Check size={12} className="theme-primary-dark" />
          )}
          <span className={!password || password.length < 8 ? 'theme-error' : 'theme-primary-dark'}>
            At least 8 characters
          </span>
        </div>
        <div className="flex items-center space-x-2">
          {!/[0-9]/.test(password) ? (
            <X size={12} className="theme-error" />
          ) : (
            <Check size={12} className="theme-primary-dark" />
          )}
          <span className={!/[0-9]/.test(password) ? 'theme-error' : 'theme-primary-dark'}>
            Contains a number or symbol
          </span>
        </div>
      </div>
    </div>
  )
}