# smartmontools (saúde do SSD)

Monitora a saúde do SSD NVMe do `gladosserver` e envia alertas pelo Telegram.

## O que ele faz

- O `smartd` (parte do pacote `smartmontools`) roda em segundo plano e lê os dados internos do SSD: desgaste, erros, temperatura e horas de uso.
- Faz testes automáticos: um teste curto todo dia às 02h e um longo todo sábado às 03h.
- Se algo sair do normal (SMART falhando, temperatura alta, erros), roda o script `smartd-telegram.sh`, que manda a mensagem para o Telegram.

## Arquivos desta pasta

| Arquivo | Vai para | Para que serve |
|---|---|---|
| `smartd.conf` | `/etc/smartd.conf` | Configuração do smartd (o que vigiar, testes, alerta) |
| `smartd-telegram.sh` | `/usr/local/bin/smartd-telegram.sh` | Envia o alerta para o Telegram |
| `telegram.env.example` | `/etc/smartd-telegram.env` | Token do bot e chat ID (o arquivo real **nunca** vai para o git) |

## Pré-requisito: bot do Telegram

1. No Telegram, procure por **@BotFather** e envie `/newbot`. Escolha um nome e um usuário (terminando em `bot`).
2. Ele devolve um **token** (algo como `123456:ABC...`). Guarde, é uma senha.
3. Abra uma conversa com o seu bot novo e envie qualquer mensagem (ex.: "oi").
4. Descubra seu **chat ID** abrindo no navegador `https://api.telegram.org/bot<SEU_TOKEN>/getUpdates` e procurando `"chat":{"id":NUMERO`.

## Instalação (no servidor, via SSH/Tailscale)

```bash
sudo apt update
sudo apt install -y smartmontools curl

# Confirme que o SSD é lido e o nome do dispositivo (esperado: /dev/nvme0)
sudo smartctl -a /dev/nvme0
```

Copie os arquivos desta pasta para o servidor e instale:

```bash
sudo cp smartd.conf /etc/smartd.conf
sudo install -m 755 smartd-telegram.sh /usr/local/bin/smartd-telegram.sh

# Credenciais (preencha com o token e o chat ID reais)
sudo cp telegram.env.example /etc/smartd-telegram.env
sudo nano /etc/smartd-telegram.env
sudo chmod 600 /etc/smartd-telegram.env
```

Ative e inicie o serviço:

```bash
sudo systemctl enable --now smartmontools
sudo systemctl restart smartmontools
sudo systemctl status smartmontools
```

## Testando

O `smartd` manda uma mensagem de teste **sempre que o serviço inicia ou reinicia**, por causa do `-M test` no `smartd.conf`. Para disparar o teste:

```bash
sudo systemctl restart smartmontools
```

Você deve receber no Telegram a mensagem de teste. O `journalctl` **só mostra o log** (ele não envia nada pro Telegram); use-o apenas se algo der errado:

```bash
sudo journalctl -u smartmontools -n 30 --no-pager
```

O `--no-pager` imprime direto no terminal. Sem ele, o log abre no `less`: use as setas pra navegar e `q` pra sair.

Depois que a mensagem chegar, edite `/etc/smartd.conf`, apague o ` -M test` do fim da linha e rode `sudo systemctl restart smartmontools` (agora sem mensagem de teste).

Para ver a saúde quando quiser:

```bash
sudo smartctl -H /dev/nvme0      # resumo (PASSED = ok)
sudo smartctl -a /dev/nvme0      # tudo: desgaste (Percentage Used), temperatura, erros
```

## Como ler o resultado

- `SMART overall-health: PASSED`: tudo bem.
- `Percentage Used`: quanto da vida útil do SSD já foi gasta (0% = novo; perto de 100% = trocar).
- `Available Spare`: reserva de blocos; se cair muito, o SSD está falhando.
- `Media and Data Integrity Errors` diferente de 0: sinal de problema, faça backup já.

## Limitações

- Avisa que o disco está dando sinais de problema, mas **não evita a perda de dados**. Quem protege os arquivos é o backup (ver [`anotacoes/backup.md`](../../anotacoes/backup.md)).
- Alguns SSDs falham sem aviso prévio.

