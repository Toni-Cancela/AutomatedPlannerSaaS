import React from 'react'
import { Button } from '@/components/ui/button'
import type { UseFormHandleSubmit, UseFormRegister, FieldErrors } from 'react-hook-form'
import { EmailField } from './EmailField'
import { PasswordField } from './PasswordField'
import { SocialLogin } from './SocialLogin'

interface AuthFormData {
  email: string
  password: string
}

interface AuthFormProps {
  handleSubmit: UseFormHandleSubmit<AuthFormData>
  register: UseFormRegister<AuthFormData>
  errors: FieldErrors<AuthFormData>
  onSubmit: (data: AuthFormData) => Promise<void>
  showPassword: boolean
  setShowPassword: (value: boolean) => void
  isSignUp: boolean
  password: string
  loading: boolean
  error: string | null
  isPasswordValid: (password: string) => boolean
  getPasswordStrength: (password: string) => string
  getPasswordStrengthIcon: (password: string) => React.ReactNode
}

export const AuthForm: React.FC<AuthFormProps> = ({
  handleSubmit,
  register,
  errors,
  onSubmit,
  showPassword,
  setShowPassword,
  isSignUp,
  password,
  loading,
  error,
  isPasswordValid,
  getPasswordStrength,
  getPasswordStrengthIcon,
}) => {
  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
      <EmailField register={register} errors={errors} />
      
      <PasswordField
        register={register}
        errors={errors}
        showPassword={showPassword}
        setShowPassword={setShowPassword}
        isSignUp={isSignUp}
        password={password}
        getPasswordStrength={getPasswordStrength}
        getPasswordStrengthIcon={getPasswordStrengthIcon}
      />

      {error && (
        <div className="theme-error text-sm">{error}</div>
      )}

      {/* Submit Button */}
      <Button
        type="submit"
        disabled={loading || (isSignUp && !isPasswordValid(password))}
        className="w-full m-0 h-12 theme-primary-bg hover:theme-primary-dark-bg theme-secondary font-medium"
      >
        {loading ? 'Loading...' : isSignUp ? 'Create Account' : 'Sign In'}
      </Button>

      <SocialLogin />
    </form>
  )
}