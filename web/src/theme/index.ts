import { MantineThemeOverride } from '@mantine/core';

export const theme: MantineThemeOverride = {
  colorScheme: 'dark',
  fontFamily: 'Roboto',
  shadows: {
    sm: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
    md: 'inset 0 2px 0 rgba(0, 0, 0, 0.1)',
    xl: 'inset 0 3px 0 rgba(0, 0, 0, 0.15)',
  },
  radius: {
    xs: 1,
    sm: 2,
    md: 3,
    lg: 4,
    xl: 5,
  },
  colors: {
    dark: [
      '#C1C2C5',
      '#A6A7AB',
      '#909296',
      '#5C5F66',
      '#373A40',
      '#2C2E33',
      '#25262B',
      '#1A1B1E',
      '#141517',
      '#101113',
    ],
    gray: [
      '#495057',
      '#3C4043',
      '#343A40',
      '#2D3436',
      '#212529',
      '#1A1D21',
      '#151619',
      '#0F1012',
      '#0A0B0C',
      '#000000',
    ],
  },
  primaryColor: 'dark',
  components: {
    Button: {
      styles: {
        root: {
          border: '1px solid #373A40',
          borderRadius: 0,
          boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
          fontWeight: 400,
          backgroundColor: '#25262B',
          color: '#C1C2C5',
          transition: 'all 0.2s ease',
          letterSpacing: '0.025em',
          position: 'relative',
          overflow: 'hidden',
          '&:hover': {
            backgroundColor: '#373A40',
            borderColor: '#5C5F66',
            transform: 'scale(1.02)',
            boxShadow: 'inset 0 2px 0 rgba(0, 0, 0, 0.1)',
          },
          '&:active': {
            transform: 'scale(0.98)',
            boxShadow: 'inset 0 3px 0 rgba(0, 0, 0, 0.15)',
          },
          '&:disabled': {
            opacity: 0.4,
            transform: 'none',
            backgroundColor: '#1A1B1E',
            borderColor: '#2C2E33',
            color: '#5C5F66',
          },
          '&::before': {
            content: '""',
            position: 'absolute',
            top: 0,
            left: '-100%',
            width: '100%',
            height: '100%',
            background: 'linear-gradient(90deg, transparent, rgba(193, 194, 197, 0.1), transparent)',
            transition: 'left 0.5s ease',
          },
          '&:hover::before': {
            left: '100%',
          },
        },
      },
    },
    Modal: {
      styles: {
        modal: {
          borderRadius: 0,
          boxShadow: 'inset 0 2px 0 rgba(0, 0, 0, 0.1)',
          border: '1px solid #373A40',
          backgroundColor: '#1A1B1E',
          animation: 'modalSlideIn 0.3s ease-out',
        },
        header: {
          borderRadius: 0,
          borderBottom: '1px solid #373A40',
          padding: '16px',
          backgroundColor: '#25262B',
          position: 'relative',
          '&::after': {
            content: '""',
            position: 'absolute',
            bottom: 0,
            left: 0,
            width: '100%',
            height: '1px',
            background: 'linear-gradient(90deg, transparent, #5C5F66, transparent)',
          },
        },
        body: {
          padding: '16px',
          backgroundColor: '#1A1B1E',
        },
      },
    },
    Input: {
      styles: {
        input: {
          borderRadius: 0,
          border: '1px solid #373A40',
          backgroundColor: '#25262B',
          color: '#C1C2C5',
          transition: 'all 0.2s ease',
          fontWeight: 400,
          letterSpacing: '0.01em',
          '&:focus': {
            borderColor: '#5C5F66',
            backgroundColor: '#2C2E33',
            boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05), 0 0 0 1px #5C5F66',
            transform: 'translateY(-1px)',
          },
          '&:hover:not(:focus)': {
            borderColor: '#5C5F66',
            backgroundColor: '#2C2E33',
          },
        },
      },
    },
    ThemeIcon: {
      styles: {
        root: {
          borderRadius: 0,
          transition: 'all 0.2s ease',
          '&:hover': {
            transform: 'scale(1.05)',
          },
        },
      },
    },
    Card: {
      styles: {
        root: {
          borderRadius: 0,
          boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
          border: '1px solid #373A40',
          backgroundColor: '#25262B',
          transition: 'all 0.2s ease',
          '&:hover': {
            backgroundColor: '#2C2E33',
            borderColor: '#5C5F66',
          },
        },
      },
    },
  },
};
