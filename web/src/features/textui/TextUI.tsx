import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems: 
      params.position === 'top-center' ? 'baseline' :
      params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent: 
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 13,
    padding: 12,
    margin: 8,
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    color: '#e2e8f0',
    fontFamily: 'Roboto',
    fontWeight: 400,
    letterSpacing: '0.02em',
    lineHeight: 1.4,
    borderRadius: 0,
    border: '1px solid rgba(59, 130, 246, 0.1)',
    position: 'relative',
    transition: 'all 0.15s ease',
    overflow: 'hidden',
    minWidth: 180,
    maxWidth: 350,
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: '2px',
      height: '100%',
      background: 'linear-gradient(180deg, rgba(59, 130, 246, 0.8), rgba(59, 130, 246, 0.3))',
    },
    '&:hover': {
      backgroundColor: 'rgba(26, 26, 26, 0.95)',
      borderColor: 'rgba(59, 130, 246, 0.2)',
      '&::before': {
        background: 'linear-gradient(180deg, rgba(59, 130, 246, 1), rgba(59, 130, 246, 0.5))',
      }
    },
    '& p': {
      margin: 0,
      lineHeight: 1.4,
    },
    '& strong': {
      fontWeight: 500,
      color: '#e2e8f0',
    },
    '& code': {
      fontFamily: 'Roboto Mono',
      fontSize: '0.9em',
      padding: '2px 4px',
      background: 'rgba(10, 10, 10, 0.8)',
      border: '1px solid rgba(59, 130, 246, 0.1)',
      letterSpacing: '0.05em',
      borderRadius: 0,
    }
  },
  iconContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 20,
    height: 20,
    border: '1px solid rgba(59, 130, 246, 0.1)',
    backgroundColor: 'rgba(10, 10, 10, 0.8)',
    transition: 'all 0.15s ease',
    '&:hover': {
      backgroundColor: 'rgba(18, 18, 18, 0.9)',
      borderColor: 'rgba(59, 130, 246, 0.2)',
    }
  }
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    position: 'right-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center'; // Default right position
    setData(data);
    setVisible(true);
  });

  useNuiEvent('textUiHide', () => setVisible(false));

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box style={data.style} className={classes.container}>
            <Group spacing={12}>
              {data.icon && (
                <Box 
                  className={classes.iconContainer}
                  style={{
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                  }}
                >
                  <LibIcon
                    icon={data.icon}
                    fixedWidth
                    animation={data.iconAnimation}
                    color={data.iconColor || '#64748b'}
                  />
                </Box>
              )}
              <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
                {data.text}
              </ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;
