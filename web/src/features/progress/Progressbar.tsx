import React from 'react';
import { Box, createStyles, Text } from '@mantine/core';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import ScaleFade from '../../transitions/ScaleFade';
import type { ProgressbarProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  container: {
    width: 350,
    height: 35,
    position: 'relative',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
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
  labelWrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
    zIndex: 2,
  },
  label: {
    fontSize: 21,
    fontWeight: 500,
    color: '#e2e8f0',
    letterSpacing: '0.025em',
    fontFamily: 'Roboto',
    textAlign: 'center',
  },
  progressTrack: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: 6,
    backgroundColor: '#252525',
    borderRadius: 1,

    overflow: 'hidden',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      right: 0,
      height: '100%',
      background: 'linear-gradient(90deg, transparent 0%, rgba(59, 130, 246, 0.1) 40%, rgba(255, 255, 255, 0.2) 50%, rgba(59, 130, 246, 0.1) 60%, transparent 100%)',
    }
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#3b82f6',
    position: 'relative',
    transition: 'width 0.2s ease-out',
    boxShadow: '0 0 4px rgba(59, 130, 246, 0.3)',
    '&::after': {
      content: '""',
      position: 'absolute',
      top: 0,
      right: -1,
      width: '2px',
      height: '100%',
      background: 'linear-gradient(180deg, rgba(255, 255, 255, 0.8) 0%, rgba(59, 130, 246, 0.6) 50%, rgba(255, 255, 255, 0.8) 100%)',
      boxShadow: '0 0 2px rgba(255, 255, 255, 0.5)',
      borderRadius: '1px',
    }
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
            <Box className={classes.progressTrack}>
              <Box
                className={classes.progressBar}
                onAnimationEnd={() => setVisible(false)}
                sx={{
                  animation: 'progress-bar-minimal linear',
                  animationDuration: `${duration}ms`,
                }}
              />
            </Box>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default Progressbar;
