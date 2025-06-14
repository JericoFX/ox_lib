import { Box, createStyles, Group, Progress, Stack, Text } from '@mantine/core';
import React, { forwardRef } from 'react';
import CustomCheckbox from './CustomCheckbox';
import type { MenuItem } from '../../../typings';
import { isIconUrl } from '../../../utils/isIconUrl';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../components/LibIcon';

interface Props {
  item: MenuItem;
  index: number;
  scrollIndex: number;
  checked: boolean;
}

const useStyles = createStyles((theme, params: { iconColor?: string }) => ({
  buttonContainer: {
    backgroundColor: 'transparent',
    border: '1px solid rgba(59, 130, 246, 0.05)',
    borderRadius: 0,
    padding: 8,
    height: 50,
    scrollMargin: 4,
    transition: 'all 0.15s ease',
    '&:focus': {
      backgroundColor: 'rgba(59, 130, 246, 0.05)',
      borderColor: 'rgba(59, 130, 246, 0.15)',
      outline: 'none',
    },
  },
  iconImage: {
    maxWidth: 20,
  },
  buttonWrapper: {
    paddingLeft: 4,
    paddingRight: 8,
    height: '100%',
  },
  iconContainer: {
    display: 'flex',
    alignItems: 'center',
    width: 20,
    height: 20,
  },
  icon: {
    fontSize: 16,
    color: params.iconColor || '#64748b',
  },
  label: {
    color: '#e2e8f0',
    textTransform: 'none',
    fontSize: 13,
    fontWeight: 500,
    letterSpacing: '0.02em',
    verticalAlign: 'middle',
  },
  chevronIcon: {
    fontSize: 10,
    color: '#64748b',
    opacity: 0.7,
  },
  scrollIndexValue: {
    color: '#64748b',
    textTransform: 'none',
    fontSize: 11,
    fontWeight: 400,
  },
  progressStack: {
    width: '100%',
    marginRight: 4,
  },
  progressLabel: {
    verticalAlign: 'middle',
    marginBottom: 4,
    color: '#e2e8f0',
    fontSize: 13,
    fontWeight: 500,
  },
}));

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex, checked }, ref) => {
  const { classes } = useStyles({ iconColor: item.iconColor });

  return (
    <Box
      tabIndex={index}
      className={classes.buttonContainer}
      key={`item-${index}`}
      ref={(element: HTMLDivElement) => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element]);
      }}
    >
      <Group spacing={15} noWrap className={classes.buttonWrapper}>
        {item.icon && (
          <Box className={classes.iconContainer}>
            {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
              <img src={item.icon} alt="Missing image" className={classes.iconImage} />
            ) : (
              <LibIcon
                icon={item.icon as IconProp}
                className={classes.icon}
                fixedWidth
                animation={item.iconAnimation}
              />
            )}
          </Box>
        )}
        {Array.isArray(item.values) ? (
          <Group position="apart" w="100%">
            <Stack spacing={0} justify="space-between">
              <Text className={classes.label}>{item.label}</Text>
              <Text>
                {typeof item.values[scrollIndex] === 'object'
                  ? // @ts-ignore for some reason even checking the type TS still thinks it's a string
                    item.values[scrollIndex].label
                  : item.values[scrollIndex]}
              </Text>
            </Stack>
            <Group spacing={1} position="center">
              <LibIcon icon="chevron-left" className={classes.chevronIcon} />
              <Text className={classes.scrollIndexValue}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <LibIcon icon="chevron-right" className={classes.chevronIcon} />
            </Group>
          </Group>
        ) : item.checked !== undefined ? (
          <Group position="apart" w="100%">
            <Text>{item.label}</Text>
            <CustomCheckbox checked={checked}></CustomCheckbox>
          </Group>
        ) : item.progress !== undefined ? (
          <Stack className={classes.progressStack} spacing={0}>
            <Text className={classes.progressLabel}>{item.label}</Text>
            <Progress
              value={item.progress}
              color={item.colorScheme || 'dark.0'}
              styles={(theme) => ({ root: { backgroundColor: theme.colors.dark[3] } })}
            />
          </Stack>
        ) : (
          <Text>{item.label}</Text>
        )}
      </Group>
    </Box>
  );
});

export default React.memo(ListItem);
