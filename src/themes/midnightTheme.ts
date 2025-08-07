export const midnightTheme = {
  name: 'Dark Theme',
  type: 'midnight' as const,
  colors: {
    primary: '#F600CC',      // Hot magenta
    primaryDark: '#d1009e',  // Darker hot magenta
    secondary: '#FFB000',    // Selective yellow
    accent: '#83CFE1',       // Sky blue for accents
    background: '#115462',   // Midnight green as main background
    surface: '#0a3d47',      // Darker midnight green for surfaces
    text: '#ffffff',         // White text for contrast
    textSecondary: '#83CFE1', // Sky blue for secondary text
    border: '#0090A0',       // Teal for borders
    borderPrimary: '#F600CC', // Hot magenta for primary borders
    success: '#10b981',
    warning: '#f59e0b',
    error: '#ef4444',
    // Base colors adapted for dark theme
    baseGray100: '#0090A0',  // Teal
    baseGray200: '#83CFE1',  // Sky blue
    baseGray300: '#115462',  // Midnight green
    baseGray400: '#0a3d47',  // Darker midnight green
    baseGray500: '#083238',  // Even darker
    baseGray600: '#062529',  // Very dark
    baseGray700: '#04181b',  // Almost black
    baseGray800: '#020c0e',  // Near black
    baseGray900: '#000000'   // Pure black
  },
  
  // Variables CSS personalizadas
  cssVariables: {
    '--theme-primary': '#115462',
    '--theme-primary-light': '#1A6B7A',
    '--theme-primary-dark': '#0D4350',
    '--theme-base-white': '#FFFFFF',
    '--theme-base-gray-100': '#F3F4F6',
    '--theme-base-gray-200': '#E5E7EB',
    '--theme-accent': '#F600CC',
    '--theme-secondary': '#FFB000',
    '--theme-gradient-from': '#115462',
    '--theme-gradient-via': '#0090A0',
    '--theme-gradient-to': '#83CFE1',
  }
};

export type MidnightTheme = typeof midnightTheme;