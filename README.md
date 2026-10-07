# my-home-server

## Arquitetura do servidor

nome: gladosserver

Notebook **Lenovo IdeaPad 3 15ALC6** (82MF).

| Componente        | Especificação                                           |
| ----------------- | ------------------------------------------------------- |
| **CPU**           | AMD Ryzen 5 5500U (6 núcleos / 12 threads, até 4,0 GHz) |
| **GPU**           | AMD Radeon Vega 7 integrada (2 GB reservados da RAM)    |
| **RAM**           | ~12 GB (9,1 GiB utilizáveis) + 4 GB de swap             |
| **Armazenamento** | SSD NVMe SSSTC 256 GB (LVM, `/` com 98 GB)              |
| **Rede**          | Wi-Fi 5 Realtek RTL8822CE                               |
| **SO**            | Ubuntu Server 26.04.1 LTS, kernel 7.0                   |
| **Acesso remoto** | Tailscale                                               |

## Serviços

Cada serviço fica documentado em [`services/`](services/), em uma pasta própria com README e arquivos de configuração. Ao adicionar um serviço novo, atualize esta tabela.

| Serviço       | O que faz                                    | Status                                                          | Docs                                                       | Porta |
| ------------- | -------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------- | ----- |
| smartmontools | Monitora a saúde do SSD e alerta no Telegram | Instalado e testado (alerta no Telegram)                        | [services/smartmontools](services/smartmontools/README.md) | -     |
| Netdata       | Painel de CPU, RAM, disco e temperatura      | Instalado (painel via Tailscale); alertas no Telegram pendentes | [services/netdata](services/netdata/README.md)             | 1025  |

## Anotações

Contexto e decisões ficam em [`anotacoes/`](anotacoes/): [instalação](anotacoes/instalacao.md), [backup](anotacoes/backup.md).
