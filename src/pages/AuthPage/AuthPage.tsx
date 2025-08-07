import React, { useState } from 'react'
import { useForm } from 'react-hook-form'
import { useAuth } from '@/contexts/AuthContext'
import { Check, X } from 'lucide-react'
import { HeroSection } from './components/HeroSection'
import { AuthHeader } from './components/AuthHeader'
import { AuthForm } from './components/AuthForm'
import { TermsFooter } from './components/TermsFooter'

interface AuthFormData {
  email: string
  password: string
}

export const AuthPage: React.FC = () => {
  const [isSignUp, setIsSignUp] = useState(true)
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const { signUp, signIn } = useAuth()

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
  } = useForm<AuthFormData>()

  const password = watch('password')

  const onSubmit = async (data: AuthFormData) => {
    setLoading(true)
    setError(null)

    try {
      const { error } = isSignUp
        ? await signUp(data.email, data.password)
        : await signIn(data.email, data.password)

      if (error) {
        setError(error.message)
      }
    } catch (err) {
      setError('An unexpected error occurred')
    } finally {
      setLoading(false)
    }
  }

  const getPasswordStrength = (password: string) => {
    if (!password) return 'Password Strength - Weak'
    if (password.length < 8) return 'Password Strength - Weak'
    
    const hasLowerCase = /[a-z]/.test(password)
    const hasUpperCase = /[A-Z]/.test(password)
    const hasNumbers = /[0-9]/.test(password)
    const hasSymbols = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)
    
    const criteriaCount = [hasLowerCase, hasUpperCase, hasNumbers, hasSymbols].filter(Boolean).length
    
    if (password.length >= 8 && criteriaCount >= 2) {
      if (criteriaCount >= 4) return 'Password Strength - Strong'
      if (criteriaCount >= 3) return 'Password Strength - Medium'
      return 'Password Strength - Medium'
    }
    
    return 'Password Strength - Weak'
  }

  const getPasswordStrengthIcon = (password: string) => {
    const strength = getPasswordStrength(password)
    if (strength.includes('Strong')) return <Check size={12} className="theme-primary-dark" />
    if (strength.includes('Medium')) return <span className="text-yellow-500 text-xs font-bold">-</span>
    return <X size={12} className="theme-error" />
  }

  const isPasswordValid = (password: string): boolean => {
    return !!(password && password.length >= 8 && /[0-9]/.test(password))
  }

  return (
    <div className="h-screen flex">
      <HeroSection />
      
      {/* Right Panel - Auth Form */}
      <div className="w-1/2 theme-bg flex flex-col justify-center px-16 relative">
        <div className="max-w-md mx-auto w-full">
          <AuthHeader isSignUp={isSignUp} setIsSignUp={setIsSignUp} />
          
          <AuthForm
            handleSubmit={handleSubmit}
            register={register}
            errors={errors}
            onSubmit={onSubmit}
            showPassword={showPassword}
            setShowPassword={setShowPassword}
            isSignUp={isSignUp}
            password={password}
            loading={loading}
            error={error}
            isPasswordValid={isPasswordValid}
            getPasswordStrength={getPasswordStrength}
            getPasswordStrengthIcon={getPasswordStrengthIcon}
          />
          
          <TermsFooter />
        </div>
      </div>
    </div>
  )
}