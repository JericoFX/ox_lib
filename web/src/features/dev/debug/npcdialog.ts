import { debugData } from '../../../utils/debugData';
import type { NpcDialogProps } from '../../../typings';

export const debugNpcDialog = () => {
  debugData<NpcDialogProps>([
    {
      action: 'openNpcDialog',
      data: {
        header: 'Guard',
        content: 'Halt! Who goes there?',
        options: [{ label: 'A friend' }, { label: 'None of your business' }],
      },
    },
  ]);
};
