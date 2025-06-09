import { Checkbox, createStyles } from '@mantine/core';

const useStyles = createStyles((theme) => ({
  root: {
    display: 'flex',
    alignItems: 'center',
  },
  input: {
    backgroundColor: 'transparent',
    border: '1px solid rgba(59, 130, 246, 0.2)',
    borderRadius: 0,
    width: 16,
    height: 16,
    transition: 'all 0.15s ease',
    '&:checked': { 
      backgroundColor: 'rgba(59, 130, 246, 0.8)', 
      borderColor: '#3b82f6',
      boxShadow: '0 0 4px rgba(59, 130, 246, 0.3)',
    },
    '&:hover': {
      borderColor: 'rgba(59, 130, 246, 0.4)',
    },
  },
  inner: {
    '> svg': {
      width: 10,
      height: 10,
    },
    '> svg > path': {
      fill: '#ffffff',
      strokeWidth: 2,
    },
  },
}));

const CustomCheckbox: React.FC<{ checked: boolean }> = ({ checked }) => {
  const { classes } = useStyles();
  return (
    <Checkbox
      checked={checked}
      size="md"
      classNames={{ root: classes.root, input: classes.input, inner: classes.inner }}
    />
  );
};

export default CustomCheckbox;
