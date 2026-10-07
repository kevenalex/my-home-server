# Netdata (painel do servidor)

Painel em tempo real do `gladosserver`: CPU, RAM, disco, temperatura, rede e processos. Também envia alertas (disco cheio, RAM acabando, temperatura alta etc.) para o Telegram.

Complementa o [smartmontools](../smartmontools/README.md): ele cuida da saúde do SSD, o Netdata cuida do servidor inteiro.

## Decisões

- **Instalação nativa** (sem Docker), pelo script oficial `kickstart.sh`. É o jeito mais simples e o Netdata enxerga o hardware direto.
- **Acesso só pelo Tailscale**: o painel não fica aberto na internet nem na rede local.
- **Sem Netdata Cloud**: tudo fica local, sem criar conta.

## Instalação (no servidor)

```bash
# 1. Baixa e roda o instalador oficial (sem conta na nuvem, sem telemetria)
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh && sh /tmp/netdata-kickstart.sh

# 2. Confere se está rodando
sudo systemctl status netdata --no-pager
```

Opcional, mas recomendado, para o Netdata ler a temperatura da CPU:

```bash
sudo apt install -y lm-sensors
sudo sensors-detect --auto
sudo systemctl restart netdata
```

## Primeiro acesso

Na tela "Welcome to Netdata" **não é preciso criar conta**: clique em **"Skip and use the dashboard anonymously"** (texto pequeno no canto inferior direito). O "Sign-in" é do Netdata Cloud, que não usamos.

Endereço (com `http` e dois-pontos antes da porta): `http://IP-do-tailscale:19999`

## Trocar de nightly para estável

Fonte: documentação oficial do Netdata (Switch Install Types and Release Channels). Configuração e banco de métricas são mantidos.

```bash
sudo cp -r /etc/netdata /etc/netdata.bak          # cópia de segurança da configuração
sudo systemctl stop netdata
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sh /tmp/netdata-kickstart.sh --reinstall --stable-channel --disable-telemetry
sudo systemctl status netdata --no-pager
```

Depois confira a versão (rodapé do painel ou `netdata -v`): a estável não tem `nightly` no nome. Se instalou por pacote nativo (apt), o caminho é outro: trocar o pacote de repositório (`netdata-repo-edge` por `netdata-repo`) e reinstalar com o apt.

## Acesso só pelo Tailscale

Descubra o IP do servidor no Tailscale:

```bash
tailscale ip -4      # algo como 100.x.y.z
```

Edite a configuração:

```bash
sudo /etc/netdata/edit-config netdata.conf
```

e deixe a seção `[web]` assim (troque `100.x.y.z` pelo IP acima):

```ini
[web]
    bind to = 127.0.0.1 100.x.y.z
```

Reinicie e acesse de qualquer aparelho com Tailscale ligado:

```bash
sudo systemctl restart netdata
```

Abra no navegador: `http://100.x.y.z:19999`

Se não abrir, confira se o serviço escuta no lugar certo: `sudo ss -tlnp | grep 19999`.

## Alertas no Telegram

Usa o mesmo bot do smartmontools (mesmo token e chat ID).

```bash
sudo /etc/netdata/edit-config health_alarm_notify.conf
```

Procure e preencha estas linhas (o token e o chat ID ficam só no servidor, **nunca** neste repositório):

```bash
SEND_TELEGRAM="YES"
TELEGRAM_BOT_TOKEN="COLE_O_TOKEN_AQUI"
DEFAULT_RECIPIENT_TELEGRAM="COLE_O_CHAT_ID_AQUI"
```

Reinicie e mande um alerta de teste:

```bash
sudo systemctl restart netdata
sudo su -s /bin/bash netdata -c '/usr/libexec/netdata/plugins.d/alarm-notify.sh test'
```

Devem chegar no Telegram mensagens de teste (WARNING, CRITICAL, CLEAR). Se o caminho do `alarm-notify.sh` não existir, ache com `sudo find / -name alarm-notify.sh 2>/dev/null`.

## O que olhar no painel

- **Alertas** (sino, canto superior): o que está em aviso agora.
- **System Overview**: CPU, RAM, disco, rede de relance.
- **Disks**: espaço usado e velocidade de leitura/escrita.
- **Sensors**: temperatura (aparece se o `lm-sensors` estiver instalado).
- **Applications**: quais programas mais consomem recursos.

Alertas já vindos de fábrica: disco quase cheio, pouca RAM, swap alto, CPU alta por muito tempo, temperatura.

## Manutenção

```bash
sudo systemctl status netdata --no-pager     # está rodando?
sudo journalctl -u netdata -n 50 --no-pager  # log
sudo systemctl restart netdata               # reiniciar
```

O Netdata se atualiza sozinho pelo instalador oficial. Para remover: `sh /tmp/netdata-kickstart.sh --uninstall` (baixe o script de novo se o arquivo não existir mais).

## Observações

- Os comandos são do instalador oficial atual; se algum flag ou caminho mudar numa versão futura, a documentação oficial (learn.netdata.cloud) vale mais que este guia. Anote aqui o que mudar.
- O painel não substitui backup: ver [`anotacoes/backup.md`](../../anotacoes/backup.md).
