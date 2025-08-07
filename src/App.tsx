import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { AuthProvider } from '@/contexts/AuthContext'
import { ThemeProvider } from '@/contexts/ThemeContext'
import { ToastProvider } from '@/contexts/ToastContext'
import { AuthPage } from '@/pages/AuthPage'
import { Dashboard } from '@/pages/Dashboard'
import { ProtectedRoute } from '@/components/ProtectedRoute'
import { ToastContainer } from '@/components/ui/Toast'
import './App.css'

function App() {
  return (
    <ThemeProvider>
      <ToastProvider>
        <div className="min-h-screen theme-bg theme-text">
          <AuthProvider>
            <Router>
              <Routes>
                <Route path="/auth" element={<AuthPage />} />
                <Route 
                  path="/" 
                  element={
                    <ProtectedRoute>
                      <Dashboard />
                    </ProtectedRoute>
                  } 
                />
                <Route 
                  path="/dashboard" 
                  element={
                    <ProtectedRoute>
                      <Dashboard />
                    </ProtectedRoute>
                  } 
                />
              </Routes>
            </Router>
          </AuthProvider>
          <ToastContainer />
        </div>
      </ToastProvider>
    </ThemeProvider>
  )
}

export default App
