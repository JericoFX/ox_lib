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
    color: '#e2e8f0',
    position: 'relative',
  },
  headerText: {
    fontWeight: 500,
    letterSpacing: '0.025em',
    lineHeight: 1.3,
    position: 'relative',
    
    fontSize: 16,
  },
  contentText: {
    lineHeight: 1.5,
    letterSpacing: '0.02em',
    fontSize: 13,
    '& p': {
      margin: '8px 0',
    },
    '& strong': {
      fontWeight: 500,
      color: '#e2e8f0',
    },
    '& code': {
      fontFamily: 'Roboto Mono',
      fontSize: '0.9em',
      padding: '2px 6px',
      background: 'rgba(18, 18, 18, 0.8)',
      border: '1px solid rgba(59, 130, 246, 0.1)',
      letterSpacing: '0.05em',
      borderRadius: 0,
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
      background: 'linear-gradient(90deg, transparent 0%, rgba(59, 130, 246, 0.2) 40%, rgba(255, 255, 255, 0.3) 50%, rgba(59, 130, 246, 0.2) 60%, transparent 100%)',
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
            border: '1px solid rgba(59, 130, 246, 0.1)',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3)',
            backgroundColor: 'rgba(10, 10, 10, 1)'
          },
          header: {
            borderBottom: '1px solid rgba(59, 130, 246, 0.1)',
            padding: 16,
            fontWeight: 500,
            backgroundColor: 'rgba(18, 18, 18, 0.95)',
            color: '#e2e8f0',
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
          body: {
            padding: 16,
            backgroundColor: 'rgba(10, 10, 10, 0.95)'
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
                    border: '1px solid rgba(59, 130, 246, 0.1)',
                    color: '#64748b',
                    backgroundColor: 'transparent',
                    transition: 'all 0.15s ease',
                    fontSize: 12,
                    fontWeight: 500,
                    letterSpacing: '0.02em',
                    '&:hover': {
                      backgroundColor: 'rgba(59, 130, 246, 0.05)',
                      borderColor: 'rgba(59, 130, 246, 0.2)',
                      color: '#e2e8f0',
                    },
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
                  backgroundColor: '#3b82f6',
                  border: '1px solid #3b82f6',
                  color: '#ffffff',
                  transition: 'all 0.15s ease',
                  fontSize: 12,
                  fontWeight: 500,
                  letterSpacing: '0.02em',
                  boxShadow: '0 0 8px rgba(59, 130, 246, 0.3)',
                  '&:hover': {
                    backgroundColor: '#1e40af',
                    borderColor: '#1e40af',
                    boxShadow: '0 0 12px rgba(59, 130, 246, 0.4)',
                  },
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
