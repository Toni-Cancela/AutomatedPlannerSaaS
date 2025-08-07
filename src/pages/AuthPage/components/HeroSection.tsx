import React, { useState, useEffect } from 'react'
import { HeroSlide } from './HeroSlide'

interface SlideData {
  title1: string
  subtitle1: string
  title2: string
  subtitle2: string
}

const slidesData: SlideData[] = [
  {
    title1: "Welcome to Glint",
    subtitle1: "Your Workflow, Organized by AI",
    title2: "Clear Roadmaps, Zero Setup",
    subtitle2: "Connect GitHub and get instant,<br />intelligent project plans."
  },
  {
    title1: "Smart Planning",
    subtitle1: "Clarity, Control, and Coordination in One Place",
    title2: "Track Less, Build More",
    subtitle2: "Glint keeps your roadmap in shape<br />while you focus on shipping."
  },
  {
    title1: "Don't Lose Your Vibe",
    subtitle1: "Iterate Your Vibe Code as a Team of Experts",
    title2: "Smarter Project Management",
    subtitle2: "Let Glint structure your work,<br />directly from GitHub."
  }
]

export const HeroSection: React.FC = () => {
  const [currentSlide, setCurrentSlide] = useState(0)

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentSlide((prev) => (prev + 1) % slidesData.length)
    }, 7000)

    return () => clearInterval(interval)
  }, [])

  return (
    <div className="w-1/2 flex items-center justify-center p-6">
      <div className="w-full h-full theme-gradient relative overflow-hidden flex items-center justify-center rounded-2xl">
        <div className="absolute inset-0 bg-[url('data:image/svg+xml,%3Csvg%20width%3D%2260%22%20height%3D%2260%22%20viewBox%3D%220%200%2060%2060%22%20xmlns%3D%22http%3A//www.w3.org/2000/svg%22%3E%3Cg%20fill%3D%22none%22%20fill-rule%3D%22evenodd%22%3E%3Cg%20fill%3D%22%23ffffff%22%20fill-opacity%3D%220.1%22%3E%3Cpath%20d%3D%22M36%2034v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6%2034v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6%204V0H4v4H0v2h4v4h2V6h4V4H6z%22/%3E%3C/g%3E%3C/g%3E%3C/svg%3E')] opacity-20 rounded-2xl"></div>
        
        <div className="relative z-10 flex flex-col justify-evenly h-full px-16 text-white text-center">
            <HeroSlide
              {...slidesData[currentSlide]}
              index={currentSlide}
            />

          {/* Pagination dots - centered */}
          <div className="flex justify-center space-x-2">
            {slidesData.map((_, index) => (
              <button
                key={index}
                onClick={() => setCurrentSlide(index)}
                className={`h-2 rounded-full transition-all duration-300 ${
                  index === currentSlide
                    ? 'w-8 bg-white'
                    : 'w-2 bg-white/50 hover:bg-white/70'
                }`}
              />
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}