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
    fontSize: 14,
    padding: 16,
    margin: 8,
    backgroundColor: '#25262B',
    color: '#C1C2C5',
    fontFamily: 'Roboto',
    fontWeight: 400,
    letterSpacing: '0.01em',
    lineHeight: 1.4,
    borderRadius: 0,
    border: '1px solid #373A40',
    boxShadow: 'inset 0 1px 0 rgba(0, 0, 0, 0.05)',
    position: 'relative',
    transition: 'all 0.2s ease',
    overflow: 'hidden',
    minWidth: 200,
    maxWidth: 400,
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 0,
      width: '3px',
      height: '100%',
      background: 'linear-gradient(180deg, #5C5F66, #373A40)',
    },
    '&:hover': {
      backgroundColor: '#2C2E33',
      borderColor: '#5C5F66',
      transform: 'translateY(-1px)',
      '&::before': {
        background: 'linear-gradient(180deg, #C1C2C5, #5C5F66)',
      }
    },
    '& p': {
      margin: 0,
      lineHeight: 1.4,
    },
    '& strong': {
      fontWeight: 500,
      color: '#A6A7AB',
    },
    '& code': {
      fontFamily: 'Roboto Mono',
      fontSize: '0.9em',
      padding: '2px 4px',
      background: '#1A1B1E',
      border: '1px solid #373A40',
      letterSpacing: '0.05em',
    }
  },
  iconContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 24,
    height: 24,
    border: '1px solid #373A40',
    backgroundColor: '#1A1B1E',
    transition: 'all 0.2s ease',
    '&:hover': {
      backgroundColor: '#25262B',
      borderColor: '#5C5F66',
      transform: 'scale(1.05)',
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
                    color={data.iconColor || '#C1C2C5'}
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
