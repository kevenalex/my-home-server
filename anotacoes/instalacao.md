## Conectando a primeira rede

Após ter o sistema operacional instalado(pulando conexões de rede):

- Descobrir o nome da interface de rede wifi:
```bash
> ip link
```
- Criar o arquivo /etc/netplan/01-wifi.yaml com a rede wifi e sua senha;
- O arquivo em questão terá o seguinte formato:
```yaml
network:
  version: 2
  wifis:
    wlp1s0:
      dhcp4: true
      optional: true
      access-points:
        "NOME_DA_REDE":
          password: "SENHA_DA_REDE"
```
- Caso a interface de rede esteja com o status `DOWN` ou `DORMANT`, ative a mesma com o comando:
```bash
sudo ip link set <nome_da_interface_de_rede> up
```
- Com a interface de rede `ON`, execute os seguintes comandos:
``` bash
sudo netplan try # Para testar a conexão
sudo netplan apply # Para efetivar a conexão
```
- Rode algum comando de ping para testar a conexão, como:
```bash
ping -c 3 1.1.1.1
```
