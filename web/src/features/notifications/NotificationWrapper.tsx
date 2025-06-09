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
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    color: '#e2e8f0',
    padding: 16,
    borderRadius: 0,
    fontFamily: 'Roboto',
    border: '1px solid rgba(59, 130, 246, 0.1)',
    position: 'relative',
    overflow: 'hidden',
    transition: 'all 0.15s ease',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: '2px',
      height: '100%',
      background: 'linear-gradient(180deg, rgba(59, 130, 246, 0.8), rgba(59, 130, 246, 0.3))',
      transition: 'all 0.2s ease',
    },
    '&:hover': {
      backgroundColor: 'rgba(26, 26, 26, 0.95)',
      borderColor: 'rgba(59, 130, 246, 0.2)',
      '&::before': {
        width: '3px',
        background: 'linear-gradient(180deg, rgba(59, 130, 246, 1), rgba(59, 130, 246, 0.5))',
      }
    }
  },
  title: {
    fontWeight: 500,
    lineHeight: 1.4,
    fontSize: 13,
    letterSpacing: '0.025em',
    transition: 'all 0.15s ease',
    position: 'relative',
  },
  description: {
    fontSize: 11,
    color: '#64748b',
    fontFamily: 'Roboto',
    lineHeight: 1.4,
    fontWeight: 400,
    letterSpacing: '0.02em',
    transition: 'color 0.15s ease',
  },
  descriptionOnly: {
    fontSize: 13,
    color: '#64748b',
    fontFamily: 'Roboto',
    lineHeight: 1.4,
    fontWeight: 400,
    letterSpacing: '0.02em',
    transition: 'color 0.15s ease',
  },
  iconContainer: {
    width: 20,
    height: 20,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    border: '1px solid rgba(59, 130, 246, 0.1)',
    backgroundColor: 'rgba(10, 10, 10, 0.8)',
    position: 'relative',
    transition: 'all 0.15s ease',
    '&:hover': {
      backgroundColor: 'rgba(18, 18, 18, 0.9)',
      borderColor: 'rgba(59, 130, 246, 0.2)',
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
