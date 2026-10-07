# Expandir o armazenamento (LVM)

O SSD tem 256 GB, mas o instalador do Ubuntu Server com LVM costuma criar o `/` com só ~100 GB e deixar o resto livre no grupo de volumes. Dá para expandir a qualquer momento, com o servidor ligado e sem perder dados.

## Conferir se há espaço livre

```bash
sudo vgs    # coluna VFree = espaço ainda não usado
df -h /     # tamanho atual do /
```

## Expandir

Use o nome real do volume mostrado por `sudo lvs` (no Ubuntu costuma ser `/dev/ubuntu-vg/ubuntu-lv`):

```bash
sudo lvextend -r -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
df -h /
```

O `-r` já aumenta o sistema de arquivos junto.

## Observações

- Se quiser, em vez de usar tudo, deixe uma parte livre para criar outros volumes depois (use `-L +100G` em vez de `-l +100%FREE`).
- Smartmontools e Netdata ocupam muito pouco espaço; o espaço só importa quando começarem os arquivos pessoais.
- Aumentar o `/` não é backup: continua sendo um disco só (ver [backup.md](backup.md)).
