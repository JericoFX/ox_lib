import { Textarea } from '@mantine/core';
import React from 'react';
import { ITextarea } from '../../../../typings/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  register: UseFormRegisterReturn;
  row: ITextarea;
  index: number;
}

const TextareaField: React.FC<Props> = (props) => {
  const textareaStyles = {
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
      minHeight: 60,
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
    <Textarea
      {...props.register}
      defaultValue={props.row.default}
      label={props.row.label}
      description={props.row.description}
      icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
      placeholder={props.row.placeholder}
      autosize={props.row.autosize}
      minRows={props.row.min}
      maxRows={props.row.max}
      disabled={props.row.disabled}
      withAsterisk={props.row.required}
      styles={textareaStyles}
    />
  );
};

export default TextareaField;
