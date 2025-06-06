import { Button, createStyles, Group, Modal, Stack, useMantineTheme } from '@mantine/core';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { useLocales } from '../../providers/LocaleProvider';
import remarkGfm from 'remark-gfm';
import type { AlertProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';

const useStyles = createStyles((theme) => ({
  contentStack: {
    color: '#C1C2C5',
    position: 'relative',
  },
  headerText: {
    fontWeight: 500,
    letterSpacing: '0.02em',
    lineHeight: 1.3,
    position: 'relative',
    '&::after': {
      content: '""',
      position: 'absolute',
      bottom: -4,
      left: 0,
      width: '30%',
      height: '1px',
      background: 'linear-gradient(90deg, #5C5F66, transparent)',
      transition: 'width 0.3s ease',
    }
  },
  contentText: {
    lineHeight: 1.5,
    letterSpacing: '0.01em',
    '& p': {
      margin: '8px 0',
    },
    '& strong': {
      fontWeight: 500,
      color: '#A6A7AB',
    },
    '& code': {
      fontFamily: 'Roboto Mono',
      fontSize: '0.9em',
      padding: '2px 6px',
      background: '#25262B',
      border: '1px solid #373A40',
      letterSpacing: '0.05em',
    }
  },
  buttonGroup: {
    position: 'relative',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: -8,
      left: 0,
      right: 0,
      height: '1px',
      background: 'linear-gradient(90deg, transparent, #373A40, transparent)',
    }
  }
}));

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const [opened, setOpened] = useState(false);
  const [dialogData, setDialogData] = useState<AlertProps>({
    header: '',
    content: '',
  });

  const closeAlert = (button: string) => {
    setOpened(false);
    fetchNui('closeAlert', button);
  };

  useNuiEvent('sendAlert', (data: AlertProps) => {
    setDialogData(data);
    setOpened(true);
  });

  useNuiEvent('closeAlertDialog', () => {
    setOpened(false);
  });

  return (
    <>
      <Modal
        opened={opened}
        centered={dialogData.centered}
        size={dialogData.size || 'md'}
        overflow={dialogData.overflow ? 'inside' : 'outside'}
        closeOnClickOutside={false}
        onClose={() => {
          setOpened(false);
          closeAlert('cancel');
        }}
        withCloseButton={false}
        overlayOpacity={0.3}
        exitTransitionDuration={100}
        transitionDuration={100}
        transition="fade"
        title={
          <div className={classes.headerText}>
            <ReactMarkdown components={MarkdownComponents}>{dialogData.header}</ReactMarkdown>
          </div>
        }
        styles={{
          modal: {
            borderRadius: 0,
            border: '1px solid #373A40',
            boxShadow: 'none',
            backgroundColor: '#1A1B1E'
          },
          header: {
            borderBottom: '1px solid #373A40',
            padding: 16,
            fontWeight: 500,
            backgroundColor: '#25262B',
            color: '#C1C2C5'
          },
          body: {
            padding: 16,
            backgroundColor: '#1A1B1E'
          }
        }}
      >
        <Stack className={classes.contentStack} spacing={16}>
          <div className={classes.contentText}>
            <ReactMarkdown
              remarkPlugins={[remarkGfm]}
              components={{
                ...MarkdownComponents,
                img: ({ ...props }) => <img style={{ maxWidth: '100%', maxHeight: '100%' }} {...props} />,
              }}
            >
              {dialogData.content}
            </ReactMarkdown>
          </div>
          <Group position="right" spacing={8} className={classes.buttonGroup}>
            {dialogData.cancel && (
              <Button 
                variant="outline" 
                onClick={() => closeAlert('cancel')} 
                styles={{
                  root: {
                    borderRadius: 0,
                    border: '1px solid #373A40',
                    color: '#909296',
                    backgroundColor: 'transparent',
                    transition: 'all 0.2s ease',
                    position: 'relative',
                    overflow: 'hidden',
                    '&:hover': {
                      backgroundColor: '#25262B',
                      borderColor: '#5C5F66',
                      transform: 'scale(1.02)',
                    },
                    '&:active': {
                      transform: 'scale(0.98)',
                    }
                  }
                }}
              >
                {dialogData.labels?.cancel || locale.ui.cancel}
              </Button>
            )}
            <Button
              variant="filled"
              onClick={() => closeAlert('confirm')}
              styles={{
                root: {
                  borderRadius: 0,
                  backgroundColor: '#373A40',
                  border: '1px solid #373A40',
                  color: '#C1C2C5',
                  transition: 'all 0.2s ease',
                  position: 'relative',
                  overflow: 'hidden',
                  '&:hover': {
                    backgroundColor: '#5C5F66',
                    borderColor: '#5C5F66',
                    transform: 'scale(1.02)',
                  },
                  '&:active': {
                    transform: 'scale(0.98)',
                  }
                }
              }}
            >
              {dialogData.labels?.confirm || locale.ui.confirm}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </>
  );
};

export default AlertDialog;
