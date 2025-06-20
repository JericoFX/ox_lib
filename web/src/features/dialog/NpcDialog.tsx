import { Button, Group, Modal, Stack, Divider, createStyles } from '@mantine/core';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import remarkGfm from 'remark-gfm';
import MarkdownComponents from '../../config/MarkdownComponents';
import type { NpcDialogProps } from '../../typings';

const useStyles = createStyles((theme) => ({
  contentStack: {
    color: theme.colors.dark[2],
  },
  header: {
    borderBottom: `1px solid ${theme.colors.gray[4]}`,
    marginBottom: theme.spacing.md,
    paddingBottom: theme.spacing.md,
  },
}));

const NpcDialog: React.FC = () => {
  const { classes } = useStyles();
  const [opened, setOpened] = useState(false);
  const [dialogData, setDialogData] = useState<NpcDialogProps>({
    header: '',
    content: '',
    options: [],
  });

  const closeDialog = () => {
    setOpened(false);
    fetchNui('npcDialogSelect', null);
  };

  const selectOption = (index: number) => {
    setOpened(false);
    fetchNui('npcDialogSelect', index);
  };

  useNuiEvent<NpcDialogProps>('openNpcDialog', (data) => {
    setDialogData(data);
    setOpened(true);
  });

  useNuiEvent('closeNpcDialog', () => {
    setOpened(false);
  });

  return (
    <Modal
      opened={opened}
      centered={false}
      onClose={closeDialog}
      withCloseButton={false}
      overlayOpacity={0.1}
      exitTransitionDuration={150}
      transition="fade"
      title={<ReactMarkdown components={MarkdownComponents}>{dialogData.header}</ReactMarkdown>}
      styles={{
        inner: {
          alignItems: 'flex-end',
          justifyContent: 'center',
        },
        modal: {
          marginBottom: 0,
          borderRadius: 0,
        },
      }}
      radius={0}
      classNames={{ header: classes.header }}
    >
      <Stack className={classes.contentStack} spacing="md">
        <ReactMarkdown remarkPlugins={[remarkGfm]} components={MarkdownComponents}>
          {dialogData.content}
        </ReactMarkdown>
        <Divider />
        <Group position="right" spacing={8} mt="sm" grow style={{ flexWrap: 'wrap' }}>
          {dialogData.options.map((opt, idx) => (
            <Button
              key={idx}
              onClick={() => selectOption(idx)}
              uppercase
              variant="filled"
              color="dark"
              radius={0}
              styles={{
                root: { flex: 1 },
                label: {
                  whiteSpace: 'normal',
                  lineHeight: 1.2,
                  textOverflow: 'unset',
                },
              }}
            >
              {opt.label}
            </Button>
          ))}
        </Group>
      </Stack>
    </Modal>
  );
};

export default NpcDialog;
