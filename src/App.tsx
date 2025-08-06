import { useState } from 'react'
import { Button, Card, CardContent, CardDescription, CardHeader, CardTitle, Input } from '@/components'
import { CheckCircle, Zap, Calendar, Users } from 'lucide-react'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            AutomatedPlanner SaaS
          </h1>
          <p className="text-xl text-gray-600 mb-8">
            Tailwind CSS + Shadcn UI Setup Complete! 🎉
          </p>
          
          {/* Counter Demo */}
          <div className="flex items-center justify-center gap-4 mb-8">
            <Button 
              variant="outline" 
              onClick={() => setCount(count - 1)}
              disabled={count <= 0}
            >
              -
            </Button>
            <span className="text-2xl font-semibold px-4">{count}</span>
            <Button onClick={() => setCount(count + 1)}>
              +
            </Button>
          </div>
        </div>

        {/* Feature Cards */}
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-12">
          <Card className="hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="flex items-center gap-2">
                <CheckCircle className="h-6 w-6 text-green-500" />
                <CardTitle>Tailwind CSS</CardTitle>
              </div>
              <CardDescription>
                Utility-first CSS framework configured and ready
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Custom theme with CSS variables, dark mode support, and responsive design utilities.
              </p>
            </CardContent>
          </Card>

          <Card className="hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Zap className="h-6 w-6 text-yellow-500" />
                <CardTitle>Shadcn UI</CardTitle>
              </div>
              <CardDescription>
                Beautiful, accessible components built with Radix UI
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Pre-built components with variants, proper TypeScript support, and customizable styling.
              </p>
            </CardContent>
          </Card>

          <Card className="hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Calendar className="h-6 w-6 text-blue-500" />
                <CardTitle>Ready for Development</CardTitle>
              </div>
              <CardDescription>
                Project structure and tooling configured
              </CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Path aliases, ESLint, Prettier, and TypeScript all set up for efficient development.
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Demo Form */}
        <Card className="max-w-md mx-auto">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Users className="h-5 w-5" />
              Component Demo
            </CardTitle>
            <CardDescription>
              Test the UI components
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <label className="text-sm font-medium">Email</label>
              <Input type="email" placeholder="Enter your email" />
            </div>
            <div className="space-y-2">
              <label className="text-sm font-medium">Name</label>
              <Input type="text" placeholder="Enter your name" />
            </div>
            <div className="flex gap-2">
              <Button className="flex-1">Primary</Button>
              <Button variant="outline" className="flex-1">Secondary</Button>
            </div>
            <Button variant="ghost" className="w-full">
              Ghost Button
            </Button>
          </CardContent>
        </Card>

        {/* Footer */}
        <div className="text-center mt-12 text-gray-500">
          <p>Built with React + TypeScript + Vite + Tailwind CSS + Shadcn UI</p>
        </div>
      </div>
    </div>
  )
}

export default App
