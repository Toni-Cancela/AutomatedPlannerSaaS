import React from 'react'
import { Input } from '@/components/ui/input'
import { Eye, EyeOff } from 'lucide-react'
import type { UseFormRegister, FieldErrors } from 'react-hook-form'
import { PasswordStrengthIndicator } from './PasswordStrengthIndicator'

interface AuthFormData {
  email: string
  password: string
}

interface PasswordFieldProps {
  register: UseFormRegister<AuthFormData>
  errors: FieldErrors<AuthFormData>
  showPassword: boolean
  setShowPassword: (value: boolean) => void
  isSignUp: boolean
  password: string
  getPasswordStrength: (password: string) => string
  getPasswordStrengthIcon: (password: string) => React.ReactNode
}

export const PasswordField: React.FC<PasswordFieldProps> = ({
  register,
  errors,
  showPassword,
  setShowPassword,
  isSignUp,
  password,
  getPasswordStrength,
  getPasswordStrengthIcon,
}) => {
  return (
    <div>
      <div className="flex justify-between items-center mb-2">
        <div className="flex w-full items-center justify-between space-x-4">
          <label className="block text-sm font-medium theme-text">
            Password
          </label>
          {!isSignUp && (
            <button
              type="button"
              className="text-sm theme-primary-dark hover:theme-secondary"
            >
              Forgot Password?
            </button>
          )}
        </div>
      </div>
      <div className="relative">
        <Input
          type={showPassword ? 'text' : 'password'}
          placeholder="Enter Password"
          {...register('password', {
            required: 'Password is required',
            minLength: {
              value: 8,
              message: 'Password must be at least 8 characters',
            },
          })}
          className="h-12 pr-10 theme-border-primary focus:theme-border-primary focus:shadow-md transition-shadow"
        />
        <button
          type="button"
          onClick={() => setShowPassword(!showPassword)}
          className="absolute right-3 top-1/2 transform -translate-y-1/2 theme-primary hover:theme-primary-dark"
        >
          {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
        </button>
      </div>
      {errors.password && (
        <p className="theme-error text-sm mt-1">{errors.password?.message}</p>
      )}
      
      {/* Password Requirements - Always reserve space */}
      <div className="h-24 mt-3">
        {isSignUp && (
          <PasswordStrengthIndicator
            password={password}
            getPasswordStrength={getPasswordStrength}
            getPasswordStrengthIcon={getPasswordStrengthIcon}
          />
        )}
      </div>
    </div>
  )
}