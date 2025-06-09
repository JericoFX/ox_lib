import { Button, createStyles, Group, HoverCard, Image, Progress, Stack, Text } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { ContextMenuProps, Option } from '../../../../typings';
import { fetchNui } from '../../../../utils/fetchNui';
import { isIconUrl } from '../../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import MarkdownComponents from '../../../../config/MarkdownComponents';
import LibIcon from '../../../../components/LibIcon';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const useStyles = createStyles((theme, params: { disabled?: boolean; readOnly?: boolean }) => ({
  inner: {
    justifyContent: 'flex-start',
  },
  label: {
    width: '100%',
    color: params.disabled ? '#525252' : '#e2e8f0',
    whiteSpace: 'pre-wrap',
  },
  button: {
    height: 'fit-content',
    width: '100%',
    padding: 12,
    backgroundColor: 'transparent',
    border: '1px solid rgba(59, 130, 246, 0.05)',
    borderRadius: 0,
    transition: 'all 0.15s ease',
    '&:hover': {
      backgroundColor: params.readOnly ? 'transparent' : 'rgba(59, 130, 246, 0.05)',
      borderColor: params.readOnly ? 'rgba(59, 130, 246, 0.05)' : 'rgba(59, 130, 246, 0.15)',
      cursor: params.readOnly ? 'default' : 'pointer',
    },
    '&:active': {
      transform: params.readOnly ? 'none' : 'translateY(1px)',
    },
  },
  iconImage: {
    maxWidth: '20px',
  },
  description: {
    color: params.disabled ? '#525252' : '#64748b',
    fontSize: 11,
    letterSpacing: '0.02em',
  },
  dropdown: {
    padding: 12,
    color: '#e2e8f0',
    fontSize: 12,
    maxWidth: 256,
    width: 'fit-content',
    backgroundColor: 'rgba(18, 18, 18, 0.95)',
    border: '1px solid rgba(59, 130, 246, 0.1)',
    borderRadius: 0,
  },
  buttonStack: {
    gap: 6,
    flex: '1',
  },
  buttonGroup: {
    gap: 8,
    flexWrap: 'nowrap',
  },
  buttonIconContainer: {
    width: 20,
    height: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonTitleText: {
    overflowWrap: 'break-word',
    fontSize: 13,
    fontWeight: 500,
    letterSpacing: '0.02em',
  },
  buttonArrowContainer: {
    justifyContent: 'center',
    alignItems: 'center',
    width: 20,
    height: 20,
    opacity: 0.6,
  },
}));

const ContextButton: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];
  const { classes } = useStyles({ disabled: button.disabled, readOnly: button.readOnly });

  return (
    <>
      <HoverCard
        position="right-start"
        disabled={button.disabled || !(button.metadata || button.image)}
        openDelay={200}
      >
        <HoverCard.Target>
          <Button
            classNames={{ inner: classes.inner, label: classes.label, root: classes.button }}
            onClick={() =>
              !button.disabled && !button.readOnly
                ? button.menu
                  ? openMenu(button.menu)
                  : clickContext(buttonKey)
                : null
            }
            variant="default"
            disabled={button.disabled}
          >
            <Group position="apart" w="100%" noWrap>
              <Stack className={classes.buttonStack}>
                {(button.title || Number.isNaN(+buttonKey)) && (
                  <Group className={classes.buttonGroup}>
                    {button?.icon && (
                      <Stack className={classes.buttonIconContainer}>
                        {typeof button.icon === 'string' && isIconUrl(button.icon) ? (
                          <img src={button.icon} className={classes.iconImage} alt="Missing img" />
                        ) : (
                          <LibIcon
                            icon={button.icon as IconProp}
                            fixedWidth
                            size="lg"
                            style={{ color: button.iconColor }}
                            animation={button.iconAnimation}
                          />
                        )}
                      </Stack>
                    )}
                    <Text className={classes.buttonTitleText}>
                      <ReactMarkdown components={MarkdownComponents}>{button.title || buttonKey}</ReactMarkdown>
                    </Text>
                  </Group>
                )}
                {button.description && (
                  <Text className={classes.description}>
                    <ReactMarkdown components={MarkdownComponents}>{button.description}</ReactMarkdown>
                  </Text>
                )}
                {button.progress !== undefined && (
                  <Progress value={button.progress} size="sm" color={button.colorScheme || 'dark.3'} />
                )}
              </Stack>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <Stack className={classes.buttonArrowContainer}>
                  <LibIcon icon="chevron-right" fixedWidth />
                </Stack>
              )}
            </Group>
          </Button>
        </HoverCard.Target>
        <HoverCard.Dropdown className={classes.dropdown}>
          {button.image && <Image src={button.image} />}
          {Array.isArray(button.metadata) ? (
            button.metadata.map(
              (
                metadata: string | { label: string; value?: any; progress?: number; colorScheme?: string },
                index: number
              ) => (
                <>
                  <Text key={`context-metadata-${index}`}>
                    {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata?.value ?? ''}`}
                  </Text>

                  {typeof metadata === 'object' && metadata.progress !== undefined && (
                    <Progress
                      value={metadata.progress}
                      size="sm"
                      color={metadata.colorScheme || button.colorScheme || 'dark.3'}
                    />
                  )}
                </>
              )
            )
          ) : (
            <>
              {typeof button.metadata === 'object' &&
                Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                  <Text key={`context-metadata-${index}`}>
                    {metadata[0]}: {metadata[1]}
                  </Text>
                ))}
            </>
          )}
        </HoverCard.Dropdown>
      </HoverCard>
    </>
  );
};

export default ContextButton;
