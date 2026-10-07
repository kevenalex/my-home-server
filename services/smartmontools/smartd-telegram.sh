#!/bin/bash
# Chamado pelo smartd quando ha um alerta. O smartd fornece as variaveis
# SMARTD_MESSAGE, SMARTD_FAILTYPE, SMARTD_DEVICE etc.
set -eu
source /etc/smartd-telegram.env   # define TELEGRAM_TOKEN e TELEGRAM_CHAT_ID

HOST="$(hostname)"
TEXTO="⚠️ ${HOST}: ${SMARTD_FAILTYPE:-alerta} em ${SMARTD_DEVICE:-disco}
${SMARTD_MESSAGE:-sem detalhes}"

curl -sS --max-time 20 \
  "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${TEXTO}" > /dev/null
