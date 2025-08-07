import React, { createContext, useContext, useEffect, type ReactNode } from 'react';
import { midnightTheme } from '../themes';

type Theme = typeof midnightTheme;

interface ThemeContextType {
  currentTheme: Theme;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

interface ThemeProviderProps {
  children: ReactNode;
}

export const ThemeProvider: React.FC<ThemeProviderProps> = ({ children }) => {
  const currentTheme = midnightTheme;

  // Aplicar tema al documento al inicializar
  useEffect(() => {
    const root = document.documentElement;
    root.setAttribute('data-theme', 'midnight');
  }, []);

  const value: ThemeContextType = {
    currentTheme,
  };

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
};

export const useTheme = (): ThemeContextType => {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
};