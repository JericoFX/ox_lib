import { Button, Group, Modal, Stack } from '@mantine/core';
import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import { fetchNui } from '../../utils/fetchNui';
import type { InputProps } from '../../typings';
import { OptionValue } from '../../typings';
import InputField from './components/fields/input';
import CheckboxField from './components/fields/checkbox';
import SelectField from './components/fields/select';
import NumberField from './components/fields/number';
import SliderField from './components/fields/slider';
import { useFieldArray, useForm } from 'react-hook-form';
import ColorField from './components/fields/color';
import DateField from './components/fields/date';
import TextareaField from './components/fields/textarea';
import TimeField from './components/fields/time';
import dayjs from 'dayjs';

export type FormValues = {
  test: {
    value: any;
  }[];
};

const InputDialog: React.FC = () => {
  const [fields, setFields] = React.useState<InputProps>({
    heading: '',
    rows: [{ type: 'input', label: '' }],
  });
  const [visible, setVisible] = React.useState(false);
  const { locale } = useLocales();

  const form = useForm<{ test: { value: any }[] }>({});
  const fieldForm = useFieldArray({
    control: form.control,
    name: 'test',
  });

  useNuiEvent<InputProps>('openDialog', (data) => {
    setFields(data);
    setVisible(true);
    data.rows.forEach((row, index) => {
      fieldForm.insert(
        index,
        {
          value:
            row.type !== 'checkbox'
              ? row.type === 'date' || row.type === 'date-range' || row.type === 'time'
                ? // Set date to current one if default is set to true
                  row.default === true
                  ? new Date().getTime()
                  : Array.isArray(row.default)
                  ? row.default.map((date) => new Date(date).getTime())
                  : row.default && new Date(row.default).getTime()
                : row.default
              : row.checked,
        }
      );
      // Backwards compat with new Select data type
      if (row.type === 'select' || row.type === 'multi-select') {
        row.options = row.options.map((option) =>
          !option.label ? { ...option, label: option.value } : option
        ) as Array<OptionValue>;
      }
    });
  });

  useNuiEvent('closeInputDialog', async () => await handleClose(true));

  const handleClose = async (dontPost?: boolean) => {
    setVisible(false);
    await new Promise((resolve) => setTimeout(resolve, 200));
    form.reset();
    fieldForm.remove();
    if (dontPost) return;
    fetchNui('inputData');
  };

  const onSubmit = form.handleSubmit(async (data) => {
    setVisible(false);
    const values: any[] = [];
    for (let i = 0; i < fields.rows.length; i++) {
      const row = fields.rows[i];

      if ((row.type === 'date' || row.type === 'date-range') && row.returnString) {
        if (!data.test[i]) continue;
        data.test[i].value = dayjs(data.test[i].value).format(row.format || 'DD/MM/YYYY');
      }
    }
    Object.values(data.test).forEach((obj: { value: any }) => values.push(obj.value));
    await new Promise((resolve) => setTimeout(resolve, 200));
    form.reset();
    fieldForm.remove();
    fetchNui('inputData', values);
  });

  return (
    <>
      <Modal
        opened={visible}
        onClose={handleClose}
        centered
        closeOnEscape={fields.options?.allowCancel !== false}
        closeOnClickOutside={false}
        size="xs"
        styles={{ 
          title: { textAlign: 'center', width: '100%', fontSize: 14, color: '#e2e8f0', fontWeight: 500, letterSpacing: '0.025em' },
          modal: {
            borderRadius: 0,
            border: '1px solid rgba(59, 130, 246, 0.1)',
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.3)',
            backgroundColor: 'rgba(10, 10, 10, 0.95)'
          },
          header: {
            borderBottom: '1px solid rgba(59, 130, 246, 0.1)',
            padding: 10,
            backgroundColor: 'rgba(18, 18, 18, 0.95)',
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
            padding: 10,
            backgroundColor: 'rgba(10, 10, 10, 0.95)'
          }
        }}
        title={fields.heading}
        withCloseButton={false}
        overlayOpacity={0.3}
        transition="fade"
        exitTransitionDuration={100}
        transitionDuration={100}
      >
        <form onSubmit={onSubmit}>
          <Stack>
            {fieldForm.fields.map((item, index) => {
              const row = fields.rows[index];
              return (
                <React.Fragment key={item.id}>
                  {row.type === 'input' && (
                    <InputField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                  {row.type === 'checkbox' && (
                    <CheckboxField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                  {(row.type === 'select' || row.type === 'multi-select') && (
                    <SelectField row={row} index={index} control={form.control} />
                  )}
                  {row.type === 'number' && <NumberField control={form.control} row={row} index={index} />}
                  {row.type === 'slider' && <SliderField control={form.control} row={row} index={index} />}
                  {row.type === 'color' && <ColorField control={form.control} row={row} index={index} />}
                  {row.type === 'time' && <TimeField control={form.control} row={row} index={index} />}
                  {row.type === 'date' || row.type === 'date-range' ? (
                    <DateField control={form.control} row={row} index={index} />
                  ) : null}
                  {row.type === 'textarea' && (
                    <TextareaField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                </React.Fragment>
              );
            })}
            <Group position="right" spacing={8}>
              <Button
                variant="outline"
                onClick={() => handleClose()}
                disabled={fields.options?.allowCancel === false}
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
                    }
                  }
                }}
              >
                {locale.ui.cancel}
              </Button>
              <Button 
                variant="filled" 
                type="submit"
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
                    }
                  }
                }}
              >
                {locale.ui.confirm}
              </Button>
            </Group>
          </Stack>
        </form>
      </Modal>
    </>
  );
};

export default InputDialog;
