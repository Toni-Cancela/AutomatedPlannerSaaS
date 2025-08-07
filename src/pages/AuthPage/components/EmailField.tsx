import React from 'react'
import { Input } from '@/components/ui/input'
import type { UseFormRegister, FieldErrors } from 'react-hook-form'

interface AuthFormData {
  email: string
  password: string
}

interface EmailFieldProps {
  register: UseFormRegister<AuthFormData>
  errors: FieldErrors<AuthFormData>
}

export const EmailField: React.FC<EmailFieldProps> = ({ register, errors }) => {
  return (
    <div>
      <label className="block text-sm font-medium theme-text mb-2">
        Email
      </label>
      <Input
        type="email"
        placeholder="Enter your email"
        {...register('email', {
          required: 'Email is required',
          pattern: {
            value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
            message: 'Invalid email address',
          },
        })}
        className="h-12 theme-border-primary focus:theme-border-primary focus:shadow-md transition-shadow"
      />
      {errors.email && (
        <p className="text-red-500 text-sm mt-1">{errors.email?.message}</p>
      )}
    </div>
  )
}