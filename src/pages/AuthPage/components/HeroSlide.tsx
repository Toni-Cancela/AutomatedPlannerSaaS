import React from 'react'

interface HeroSlideProps {
  title1: string
  subtitle1: string
  title2: string
  subtitle2: string
  index: number
}

export const HeroSlide: React.FC<HeroSlideProps> = ({
  title1,
  subtitle1,
  title2,
  subtitle2
}) => {
  return (
    <div className="flex flex-col justify-between h-[70%] mt-10 text-white text-center">
      <div className="mb-12">
        <h1 className="text-6xl font-bold mb-4">{title1}</h1>
        <p className="text-2xl opacity-90">{subtitle1}</p>
      </div>
      
      <div className="mb-8">
        <h2 className="text-4xl font-bold mb-4">{title2}</h2>
        <p className="text-xl opacity-90" dangerouslySetInnerHTML={{ __html: subtitle2 }} />
      </div>
    </div>
  )
}