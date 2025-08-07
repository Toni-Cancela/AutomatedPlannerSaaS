export { midnightTheme } from './midnightTheme';

import { midnightTheme } from './midnightTheme';

// Exportar el tema disponible
export const availableThemes = {
  midnight: midnightTheme,
} as const;

export type ThemeKey = keyof typeof availableThemes;
export type Theme = typeof midnightTheme;