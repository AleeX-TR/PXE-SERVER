#!/bin/bash

USERUPDATE="pxeserver"
DOMAIN="pxe.server"
DOMAINREV="1.16.172.in-pxe.serv"
NETWORK="172.16.1."
export DEBIAN_FRONTEND="noninteractive"
clear
echo
echo -e "Instalação do Bind9 DNS Server integrado com o ICS DHCP Server no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Porta padrão utilizada pelo Bind9 DNS Server: 53"
echo -e "Porta padrão utilizada pelo ISC DHCP Server.: 67\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
#
echo -e "Adicionando o Repositório Universal do Apt, aguarde..."
	add-apt-repository universe 
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Adicionando o Repositório Multiversão do Apt, aguarde..."
	add-apt-repository multiverse 
echo -e "Repositório adicionado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Atualizando as listas do Apt, aguarde..."
	apt update 
echo -e "Listas atualizadas com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Atualizando o sistema, aguarde..."
	apt -y upgrade 
echo -e "Sistema atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Instalando o Bind9 DNS Server e ISC DHCP Server, aguarde...\n"
sleep 5
echo -e "Instalando o Bind9 DNS Server e o ISC DHCP Server, aguarde..."
	apt -y install bind9 bind9utils bind9-doc dnsutils net-tools isc-dhcp-server 
echo -e "Bind9 DNS Server e o ISC DHCP Server instalado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Editando o arquivo hostname, pressione <Enter> para continuar."
	read
	vim /etc/hostname
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Editando o arquivo hosts, pressione <Enter> para continuar."
	read
	vim /etc/hosts
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo $(ls -lh /etc/netplan/ | cut -d' ' -f10 | sed '/^$/d'), pressione <Enter> para continuar."
echo -e "CUIDADO!!!: o nome do arquivo de configuração da placa de rede pode mudar"
	read
	vim /etc/netplan/$(ls -lh /etc/netplan/ | cut -d' ' -f10 | sed '/^$/d')
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Atualizando o arquivo de configuração do ISC DHCP Server, aguarde..."
	mv -v /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bkp 
	cp -v conf/dhcpd.conf /etc/dhcp/dhcpd.conf 
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Atualizando os arquivos de configuração do Bind9 DNS Server, aguarde..."
	mkdir -v /var/log/named/
	chown -Rv bind:bind /var/log/named/
	mv -v /etc/bind/named.conf /etc/bind/named.conf.bkp
	mv -v /etc/bind/named.conf.local /etc/bind/named.conf.local.bkp
	mv -v /etc/bind/named.conf.options /etc/bind/named.conf.options.bkp
	cp -v conf/named.conf /etc/bind/named.conf
	cp -v conf/named.conf.local /etc/bind/named.conf.local
	cp -v conf/named.conf.options /etc/bind/named.conf.options
	cp -v conf/pti.intra.hosts /var/lib/bind/pti.intra.hosts
	cp -v conf/172.16.1.rev /var/lib/bind/172.16.1.rev
	cp -v conf/dnsupdate-cron /etc/cron.d/dnsupdate-cron
echo -e "Arquivos atualizados com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Gerando a Chave de atualização do Bind9 DNS Server utilizada no ISC DHCP Server, aguarde..."
	rm -v K$USERUPDATE*
	dnssec-keygen -r /dev/urandom -a HMAC-MD5 -b 128 -n USER $USERUPDATE
	KEYGEN=$(cat K$USERUPDATE*.private | grep Key | cut -d' ' -f2)
	sed "s@secret vaamonde;@secret $KEYGEN;@" /etc/dhcp/dhcpd.conf > /tmp/dhcpd.conf.old
	sed 's@secret "vaamonde";@secret "'$KEYGEN'";@' /etc/bind/named.conf.local > /tmp/named.conf.local.old
	cp -v /tmp/dhcpd.conf.old /etc/dhcp/dhcpd.conf
	cp -v /tmp/named.conf.local.old /etc/bind/named.conf.local
echo -e "Atualização da chave feita com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Editando o arquivo named.conf, pressione <Enter> para continuar."
	read
	vim /etc/bind/named.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Editando o arquivo named.conf.local, pressione <Enter> para continuar."
	read
	vim /etc/bind/named.conf.local
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo named.conf.options, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saida padrão)
	read
	vim /etc/bind/named.conf.options
	named-checkconf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo pti.intra.hosts, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando chown: -v (verbose), -root (user), bind (group)
	read
	vim /var/lib/bind/pti.intra.hosts
	chown -v root:bind /var/lib/bind/pti.intra.hosts
	named-checkzone $DOMAIN /var/lib/bind/pti.intra.hosts
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo 172.16.1.rev, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando chown: -v (verbose), -root (user), bind (group)
	read
	vim /var/lib/bind/172.16.1.rev
	chown -v root:bind /var/lib/bind/172.16.1.rev
	named-checkzone $DOMAINREV /var/lib/bind/172.16.1.rev
	named-checkzone $NETWORK /var/lib/bind/172.16.1.rev
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo dnsupdate-cron, pressione <Enter> para continuar."
	read
	vim /etc/cron.d/dnsupdate-cron
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo dhcpd.conf, pressione <Enter> para continuar."
	# opção do comando: &>> (redirecionar a saida padrão)
	# opção do comando dhcpd: -T (test the configuration file)
	read
	vim /etc/dhcp/dhcpd.conf
	dhcpd -t
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Inicializando os serviços do Bind9 DNS Server, ISC DHCP Server e do Netplan, aguarde..."
	# opção do comando: &>> (redirecionar a saida padrão)
	netplan --debug apply 
	systemctl start isc-dhcp-server
	systemctl restart bind9
	systemctl reload bind9
	rndc sync -clean
	rndc stats
echo -e "Serviços inicializados com com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas de Conexões do Bind9 DNS Server e do ISC DHCP Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep '53\|67'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Instalação do Bind9 DNS Server integrado com o ICS DHCP Server feita com Sucesso!!!."
echo -e "Pressione <Enter> para concluir o processo."
read
exit 1
