# Netdata (painel do servidor)

Painel em tempo real do `gladosserver`: CPU, RAM, disco, temperatura, rede e processos. Também envia alertas (disco cheio, RAM acabando, temperatura alta etc.) para o Telegram.

Complementa o [smartmontools](../smartmontools/README.md): ele cuida da saúde do SSD, o Netdata cuida do servidor inteiro.

## Decisões

- **Roda em Docker** (imagem oficial `netdata/netdata:stable`), no mesmo padrão dos próximos serviços. O smartmontools continua instalado direto no sistema, porque precisa de acesso direto ao SSD.
- **Configuração versionada aqui**: os arquivos de `config/` são montados dentro do container. Para mudar algo, edite aqui e reinicie o container.
- **Segredos fora do git**: token e chat ID do Telegram ficam em `envs/telegram.env` (na raiz do repo, ignorado pelo git), passado ao container pelo `env_file`.
- **Acesso só pelo Tailscale**: o painel não fica aberto na internet nem na rede local.
- **Sem Netdata Cloud e sem telemetria** (`DO_NOT_TRACK=1`).

## Arquivos desta pasta

| Arquivo | Para que serve |
|---|---|
| `docker-compose.yml` | Define o container: imagem, permissões, volumes e variáveis |
| `config/netdata.conf` | Configuração principal (IP e porta 1025 em que o painel escuta) |
| `config/health_alarm_notify.conf` | Liga os alertas no Telegram, lendo token e chat ID das variáveis de ambiente |

## Pré-requisitos

1. **Docker instalado no servidor.** No Ubuntu:

   ```bash
   sudo apt update
   sudo apt install -y docker.io docker-compose-v2
   sudo systemctl enable --now docker
   docker compose version      # confere se o compose está disponível
   ```

   Se algum pacote não for encontrado, siga a instalação oficial em docs.docker.com (Install Docker Engine on Ubuntu).

2. **Arquivo `envs/telegram.env`** na raiz do repo, com as variáveis abaixo (modelo em [`../smartmontools/telegram.env.example`](../smartmontools/telegram.env.example)):

   ```bash
   TELEGRAM_TOKEN=...
   TELEGRAM_CHAT_ID=...
   ```

## Migração da instalação nativa para Docker (feita uma vez)

A primeira instalação foi nativa (kickstart). Ela precisa ser removida antes, senão as duas brigam pela mesma porta. O histórico de métricas da instalação antiga é perdido.

```bash
# 1. Remove o Netdata nativo
wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh
sh /tmp/netdata-kickstart.sh --uninstall --non-interactive

# 2. Confere que nada mais escuta na porta 1025 (não deve aparecer nada)
sudo ss -tlnp | grep 1025
```

## Subir o Netdata

Na pasta deste serviço, no clone do repo no servidor:

```bash
cd services/netdata
sudo docker compose pull
sudo docker compose up -d
sudo docker compose ps          # deve aparecer "netdata" com status "running"/"healthy"
```

Abra no navegador (com o Tailscale ligado): `http://gladosserver:1025` ou `http://100.117.213.66:1025`.

Na tela "Welcome to Netdata" **não é preciso criar conta**: clique em **"Skip and use the dashboard anonymously"** (texto pequeno no canto inferior direito).

## Testar os alertas no Telegram

```bash
sudo docker exec -u netdata netdata /usr/libexec/netdata/plugins.d/alarm-notify.sh test
```

Devem chegar no Telegram mensagens de teste (WARNING, CRITICAL, CLEAR). Se não chegarem:

```bash
sudo docker exec netdata printenv | grep -c TELEGRAM   # deve ser 2 (as variáveis chegaram no container)
sudo docker logs netdata --tail 50                     # erros do Netdata
```

## Mudar uma configuração

1. Edite o arquivo em `config/` (ou o `docker-compose.yml`).
2. Aplique: `sudo docker compose up -d` (recria o container se o compose mudou) e `sudo docker compose restart` (se só mudou algo em `config/`).

Se o IP do Tailscale mudar, ajuste `bind to` em `config/netdata.conf`.

## Manutenção

```bash
sudo docker compose ps                     # está rodando?
sudo docker compose logs --tail 50         # log
sudo docker compose restart                # reiniciar
sudo docker compose pull && sudo docker compose up -d   # atualizar para a versão estável mais nova
sudo docker compose down                   # parar e remover o container (os dados nos volumes ficam)
```

## O que olhar no painel

- **Alertas** (sino, canto superior): o que está em aviso agora.
- **System Overview**: CPU, RAM, disco, rede de relance.
- **Disks**: espaço usado e velocidade de leitura/escrita.
- **Sensors**: temperatura.
- **Applications**: quais programas mais consomem recursos.

Alertas já vindos de fábrica: disco quase cheio, pouca RAM, swap alto, CPU alta por muito tempo, temperatura.

## Histórico

- 2026-10-07: instalado nativo pelo kickstart (versão nightly por engano, depois trocada pela estável). No mesmo dia decidido migrar para Docker, para seguir o padrão dos próximos serviços.

## Observações

- O `docker-compose.yml` segue o exemplo da documentação oficial do Netdata para Docker. Se algo mudar numa versão futura, a documentação oficial (learn.netdata.cloud) vale mais que este guia. Anote aqui o que mudar.
- Este guia ainda não foi testado no servidor; ajuste o que for diferente na prática.
