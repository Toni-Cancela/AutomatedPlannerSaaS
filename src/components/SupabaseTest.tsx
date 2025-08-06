import { useState, useEffect } from 'react'
import { supabase } from '@/lib/supabase'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'

export function SupabaseTest() {
  const [connectionStatus, setConnectionStatus] = useState<'idle' | 'testing' | 'success' | 'error'>('idle')
  const [errorMessage, setErrorMessage] = useState<string>('')

  const testConnection = async () => {
    setConnectionStatus('testing')
    setErrorMessage('')
    
    try {
      // Test basic connection by getting the current session
      const { data, error } = await supabase.auth.getSession()
      
      if (error) {
        throw error
      }
      
      // If we get here, the connection is working
      setConnectionStatus('success')
    } catch (error) {
      setConnectionStatus('error')
      setErrorMessage(error instanceof Error ? error.message : 'Unknown error occurred')
    }
  }

  useEffect(() => {
    // Test connection on component mount
    testConnection()
  }, [])

  const getStatusColor = () => {
    switch (connectionStatus) {
      case 'success': return 'text-green-600'
      case 'error': return 'text-red-600'
      case 'testing': return 'text-yellow-600'
      default: return 'text-gray-600'
    }
  }

  const getStatusText = () => {
    switch (connectionStatus) {
      case 'success': return 'Connected successfully!'
      case 'error': return 'Connection failed'
      case 'testing': return 'Testing connection...'
      default: return 'Ready to test'
    }
  }

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader>
        <CardTitle>Supabase Connection Test</CardTitle>
        <CardDescription>
          Test the connection to your Supabase project
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className={`font-medium ${getStatusColor()}`}>
          {getStatusText()}
        </div>
        
        {errorMessage && (
          <div className="text-sm text-red-600 bg-red-50 p-2 rounded">
            {errorMessage}
          </div>
        )}
        
        <Button 
          onClick={testConnection} 
          disabled={connectionStatus === 'testing'}
          className="w-full"
        >
          {connectionStatus === 'testing' ? 'Testing...' : 'Test Connection'}
        </Button>
      </CardContent>
    </Card>
  )
}