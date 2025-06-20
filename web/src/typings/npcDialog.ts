export interface NpcDialogOption {
  label: string;
}

export interface NpcDialogProps {
  header: string;
  content: string;
  options: NpcDialogOption[];
}
