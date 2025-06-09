import { Box, createStyles, Text } from '@mantine/core';
import React from 'react';

const useStyles = createStyles((theme) => ({
  container: {
    textAlign: 'center',
    borderRadius: 0,
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    border: '1px solid rgba(59, 130, 246, 0.08)',
    height: 55,
    width: 384,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
    overflow: 'hidden',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      height: '1px',
      background: 'linear-gradient(90deg, transparent 0%, rgba(59, 130, 246, 0.2) 40%, rgba(255, 255, 255, 0.4) 50%, rgba(59, 130, 246, 0.2) 60%, transparent 100%)',
    }
  },
  heading: {
    fontSize: 14,
    textTransform: 'uppercase',
    fontWeight: 500,
    color: '#e2e8f0',
    letterSpacing: '0.1em',
    fontFamily: 'Roboto',
  },
}));

const Header: React.FC<{ title: string }> = ({ title }) => {
  const { classes } = useStyles();

  return (
    <Box className={classes.container}>
      <Text className={classes.heading}>{title}</Text>
    </Box>
  );
};

export default React.memo(Header);
