import { useNuiEvent } from '../../hooks/useNuiEvent';
import { toast, Toaster } from 'react-hot-toast';
import ReactMarkdown from 'react-markdown';
import { Box, Center, createStyles, Group, keyframes, RingProgress, Stack, Text, ThemeIcon } from '@mantine/core';
import React, { useState } from 'react';
import tinycolor from 'tinycolor2';
import type { NotificationProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const useStyles = createStyles((theme) => ({
  container: {
    width: 300,
    height: 'fit-content',
    backgroundColor: '#25262B',
    color: '#C1C2C5',
    padding: 16,
    borderRadius: 0,
    fontFamily: 'Roboto',
    boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
    border: '1px solid #373A40',
    position: 'relative',
    overflow: 'hidden',
    transition: 'all 0.2s ease',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: '2px',
      height: '100%',
      background: 'linear-gradient(180deg, #5C5F66, #373A40)',
      transition: 'all 0.3s ease',
    },
    '&:hover': {
      backgroundColor: '#2C2E33',
      borderColor: '#5C5F66',
      transform: 'translateX(2px)',
      '&::before': {
        width: '3px',
        background: 'linear-gradient(180deg, #C1C2C5, #5C5F66)',
      }
    }
  },
  title: {
    fontWeight: 500,
    lineHeight: 1.4,
    fontSize: 14,
    letterSpacing: '0.02em',
    transition: 'all 0.2s ease',
    position: 'relative',
    '&::after': {
      content: '""',
      position: 'absolute',
      bottom: -2,
      left: 0,
      width: '0%',
      height: '1px',
      background: '#909296',
      transition: 'width 0.3s ease',
    }
  },
  description: {
    fontSize: 12,
    color: '#909296',
    fontFamily: 'Roboto',
    lineHeight: 1.4,
    fontWeight: 400,
    letterSpacing: '0.01em',
    transition: 'color 0.2s ease',
  },
  descriptionOnly: {
    fontSize: 14,
    color: '#909296',
    fontFamily: 'Roboto',
    lineHeight: 1.4,
    fontWeight: 400,
    letterSpacing: '0.01em',
    transition: 'color 0.2s ease',
  },
  iconContainer: {
    width: 24,
    height: 24,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    border: '1px solid #373A40',
    backgroundColor: '#1A1B1E',
    position: 'relative',
    transition: 'all 0.2s ease',
    '&::after': {
      content: '""',
      position: 'absolute',
      top: -1,
      right: -1,
      width: '4px',
      height: '4px',
      background: '#C1C2C5',
      opacity: 0,
      transition: 'opacity 0.2s ease',
    },
    '&:hover': {
      backgroundColor: '#25262B',
      borderColor: '#5C5F66',
      transform: 'scale(1.1)',
      '&::after': {
        opacity: 1,
      }
    }
  }
}));

const createAnimation = (from: string, to: string, visible: boolean) => keyframes({
  from: {
    opacity: visible ? 0 : 1,
    transform: `translate${from}`,
  },
  to: {
    opacity: visible ? 1 : 0,
    transform: `translate${to}`,
  },
});

const getAnimation = (visible: boolean, position: string) => {
  const animationOptions = visible ? '0.3s cubic-bezier(0.4, 0, 0.2, 1) forwards' : '0.2s ease-in forwards'
  let animation: { from: string; to: string };

  if (visible) {
    if (position.includes('right')) {
      animation = { from: 'X(50px)', to: 'X(0px)' };
    } else if (position.includes('left')) {
      animation = { from: 'X(-50px)', to: 'X(0px)' };
    } else {
      animation = { from: 'Y(-20px)', to: 'Y(0px)' };
    }
  } else {
    if (position.includes('right')) {
      animation = { from: 'X(0px)', to: 'X(120%)' }
    } else if (position.includes('left')) {
      animation = { from: 'X(0px)', to: 'X(-120%)' };
    } else if (position === 'top-center') {
      animation = { from: 'Y(0px)', to: 'Y(-120%)' };
    } else if (position === 'bottom') {
      animation = { from: 'Y(0px)', to: 'Y(120%)' };
    } else {
      animation = { from: 'X(0px)', to: 'X(120%)' };
    }
  }

  return `${createAnimation(animation.from, animation.to, visible)} ${animationOptions}`
};

const durationCircle = keyframes({
  '0%': { strokeDasharray: `0, ${15.1 * 2 * Math.PI}` },
  '100%': { strokeDasharray: `${15.1 * 2 * Math.PI}, 0` },
});

const Notifications: React.FC = () => {
  const { classes } = useStyles();
  const [toastKey, setToastKey] = useState(0);

  useNuiEvent<NotificationProps>('notify', (data) => {
    if (!data.title && !data.description) return;

    const toastId = data.id?.toString();
    const duration = data.duration || 3000;

    let iconColor: string;
    let position = data.position || 'top-right';

    data.showDuration = data.showDuration !== undefined ? data.showDuration : true;

    if (toastId) setToastKey(prevKey => prevKey + 1);

    // Backwards compat with old notifications
    switch (position) {
      case 'top':
        position = 'top-center';
        break;
      case 'bottom':
        position = 'bottom-center';
        break;
    }

    if (!data.icon) {
      switch (data.type) {
        case 'error':
          data.icon = 'circle-xmark';
          break;
        case 'success':
          data.icon = 'circle-check';
          break;
        case 'warning':
          data.icon = 'circle-exclamation';
          break;
        default:
          data.icon = 'circle-info';
          break;
      }
    }

    if (!data.iconColor) {
      switch (data.type) {
        case 'error':
          iconColor = 'red.6';
          break;
        case 'success':
          iconColor = 'teal.6';
          break;
        case 'warning':
          iconColor = 'yellow.6';
          break;
        default:
          iconColor = 'blue.6';
          break;
      }
    } else {
      iconColor = tinycolor(data.iconColor).toRgbString();
    }

    toast.custom(
      (t) => (
        <Box
          sx={{
            animation: getAnimation(t.visible, position),
            ...data.style,
          }}
          className={`${classes.container}`}
        >
          <Group noWrap spacing={12}>
            {data.icon && (
              <>
                <Box
                  className={classes.iconContainer}
                  style={{ 
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                  }}
                >
                  <LibIcon icon={data.icon} fixedWidth color={iconColor} animation={data.iconAnimation} />
                </Box>
              </>
            )}
            <Stack spacing={data.title && data.description ? 8 : 0}>
              {data.title && (
                <div>
                  <Text className={classes.title}>{data.title}</Text>
                  {data.description && <div className="divider-line" style={{ margin: '4px 0', height: '1px', background: 'linear-gradient(90deg, transparent, #373A40 20%, transparent 80%)' }} />}
                </div>
              )}
              {data.description && (
                <ReactMarkdown
                  components={MarkdownComponents}
                  className={`${!data.title ? classes.descriptionOnly : classes.description} description`}
                >
                  {data.description}
                </ReactMarkdown>
              )}
            </Stack>
          </Group>
        </Box>
      ),
      {
        id: toastId,
        duration: duration,
        position: position,
      }
    );
  });

  return <Toaster />;
};

export default Notifications;
