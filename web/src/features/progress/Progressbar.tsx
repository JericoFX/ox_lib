import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  container: {
    width: 350,
    height: 45,
    borderRadius: 0,
    backgroundColor: '#25262B',
    border: '1px solid #373A40',
    overflow: 'hidden',
    position: 'relative',
    boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      height: '1px',
      background: 'linear-gradient(90deg, transparent, #5C5F66, transparent)',
    }
  },
  wrapper: {
    width: '100%',
    height: '20%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    bottom: 0,
    position: 'absolute',
  },
  bar: {
    height: '100%',
    backgroundColor: '#373A40',
    position: 'relative',
    transition: 'background-color 0.2s ease',
    '&::after': {
      content: '""',
      position: 'absolute',
      top: 0,
      right: 0,
      width: '2px',
      height: '100%',
      background: '#C1C2C5',
      boxShadow: '0 0 4px rgba(193, 194, 197, 0.3)',
    }
  },
  labelWrapper: {
    position: 'absolute',
    display: 'flex',
    width: 350,
    height: 45,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 2,
  },
  label: {
    maxWidth: 320,
    padding: 8,
    textOverflow: 'ellipsis',
    overflow: 'hidden',
    whiteSpace: 'nowrap',
    fontSize: 14,
    fontWeight: 500,
    color: '#C1C2C5',
    letterSpacing: '0.02em',
    textShadow: '0 1px 2px rgba(0, 0, 0, 0.5)',
    fontFamily: 'Roboto',
  },
}));

const Progressbar: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = React.useState(false);
  const [label, setLabel] = React.useState('');
  const [duration, setDuration] = React.useState(0);

  useNuiEvent('progressCancel', () => setVisible(false));

  useNuiEvent<ProgressbarProps>('progress', (data) => {
    setVisible(true);
    setLabel(data.label);
    setDuration(data.duration);
  });

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible} onExitComplete={() => fetchNui('progressComplete')}>
          <Box className={classes.container}>
            <Box className={classes.labelWrapper}>
              <Text className={classes.label}>{label}</Text>
            </Box>
            <Box
              className={classes.bar}
              onAnimationEnd={() => setVisible(false)}
              sx={{
                animation: 'progress-bar linear',
                animationDuration: `${duration}ms`,
              }}
            />
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;
