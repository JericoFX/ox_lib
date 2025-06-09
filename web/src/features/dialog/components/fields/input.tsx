import { createStyles, PasswordInput, TextInput } from '@mantine/core';
import React from 'react';
import { IInput } from '../../../../typings/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  register: UseFormRegisterReturn;
  row: IInput;
  index: number;
}

const useStyles = createStyles((theme) => ({
  eyeIcon: {
    color: '#64748b',
  },
}));

const InputField: React.FC<Props> = (props) => {
  const { classes } = useStyles();

  const inputStyles = {
    label: {
      color: '#e2e8f0',
      fontSize: 12,
      fontWeight: 500,
      letterSpacing: '0.02em',
      marginBottom: 6,
    },
    description: {
      color: '#64748b',
      fontSize: 11,
      marginBottom: 8,
    },
    input: {
      backgroundColor: 'transparent',
      border: '1px solid rgba(59, 130, 246, 0.1)',
      borderRadius: 0,
      color: '#e2e8f0',
      fontSize: 12,
      '&:focus': {
        borderColor: 'rgba(59, 130, 246, 0.3)',
        boxShadow: '0 0 4px rgba(59, 130, 246, 0.2)',
      },
      '&::placeholder': {
        color: '#64748b',
      },
    },
    icon: {
      color: '#64748b',
    },
  };

  return (
    <>
      {!props.row.password ? (
        <TextInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          description={props.row.description}
          icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          minLength={props.row.min}
          maxLength={props.row.max}
          disabled={props.row.disabled}
          withAsterisk={props.row.required}
          styles={inputStyles}
        />
      ) : (
        <PasswordInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          description={props.row.description}
          icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          minLength={props.row.min}
          maxLength={props.row.max}
          disabled={props.row.disabled}
          withAsterisk={props.row.required}
          styles={inputStyles}
          visibilityToggleIcon={({ reveal, size }) => (
            <LibIcon
              icon={reveal ? 'eye-slash' : 'eye'}
              fontSize={size}
              cursor="pointer"
              className={classes.eyeIcon}
              fixedWidth
            />
          )}
        />
      )}
    </>
  );
};

export default InputField;
