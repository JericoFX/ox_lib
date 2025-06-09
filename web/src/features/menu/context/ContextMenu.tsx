import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, createStyles, Flex, Stack, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { ContextMenuProps } from '../../../typings';
import ContextButton from './components/ContextButton';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';
import HeaderButton from './components/HeaderButton';
import ScaleFade from '../../../transitions/ScaleFade';
import MarkdownComponents from '../../../config/MarkdownComponents';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const useStyles = createStyles((theme) => ({
  container: {
    position: 'absolute',
    top: '15%',
    right: '25%',
    width: 320,
    height: 580,
  },
  header: {
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
    gap: 6,
  },
  titleContainer: {
    borderRadius: 0,
    flex: '1 85%',
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    border: '1px solid rgba(59, 130, 246, 0.08)',
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
  titleText: {
    color: '#e2e8f0',
    padding: 12,
    textAlign: 'center',
    fontWeight: 500,
    letterSpacing: '0.025em',
    fontSize: 13,
    fontFamily: 'Roboto',
  },
  buttonsContainer: {
    height: 560,
    overflowY: 'scroll',
    backgroundColor: 'rgba(10, 10, 10, 0.95)',
    border: '1px solid rgba(59, 130, 246, 0.08)',
    borderRadius: 0,
    padding: 4,
    position: 'relative',
    '&::before': {
      content: '""',
      position: 'absolute',
      top: 0,
      left: 4,
      right: 4,
      height: '1px',
      background: 'linear-gradient(90deg, transparent 0%, rgba(59, 130, 246, 0.15) 40%, rgba(255, 255, 255, 0.2) 50%, rgba(59, 130, 246, 0.15) 60%, transparent 100%)',
    }
  },
  buttonsFlexWrapper: {
    gap: 1,
  },
}));

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });

  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
  };

  // Hides the context menu on ESC
  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (['Escape'].includes(e.code)) closeContext();
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  useNuiEvent('hideContext', () => setVisible(false));

  useNuiEvent<ContextMenuProps>('showContext', async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setContextMenu(data);
    setVisible(true);
  });

  return (
    <Box className={classes.container}>
      <ScaleFade visible={visible}>
        <Flex className={classes.header}>
          {contextMenu.menu && (
            <HeaderButton icon="chevron-left" iconSize={16} handleClick={() => openMenu(contextMenu.menu)} />
          )}
          <Box className={classes.titleContainer}>
            <Text className={classes.titleText}>
              <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
            </Text>
          </Box>
          <HeaderButton icon="xmark" canClose={contextMenu.canClose} iconSize={18} handleClick={closeContext} />
        </Flex>
        <Box className={classes.buttonsContainer}>
          <Stack className={classes.buttonsFlexWrapper}>
            {Object.entries(contextMenu.options).map((option, index) => (
              <ContextButton option={option} key={`context-item-${index}`} />
            ))}
          </Stack>
        </Box>
      </ScaleFade>
    </Box>
  );
};

export default ContextMenu;
