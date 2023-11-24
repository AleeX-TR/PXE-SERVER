#!/bin/bash
TFTP="/var/lib/tftpboot"
PXE="/usr/lib/PXELINUX"
SYSLINUX="/usr/lib/syslinux"
# Link de download do Puppy Linux (Link atualizado no dia 12/06/2021)
PUPPY="http://distro.ibiblio.org/puppylinux/puppy-fossa/fossapup64-9.5.iso"
#
# Exportando o recurso de Noninteractive do Debconf para não solicitar telas de configuração
export DEBIAN_FRONTEND="noninteractive"
echo
echo -e "Instalação do Tftpd-Hpa Server e PXE/Syslinux no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Aguarde, esse processo demora um pouco dependendo do seu Link de Internet...\n"
sleep 5
echo -e "Instalando o Tftpd-Hpa Server/Client e PXE/Syslinux, aguarde...\n"
sleep 5
echo -e "Instalando o Serviço do Tftpd-Hpa Server e Client, aguarde..."
	apt -y install tftpd-hpa tftp-hpa
echo -e "Tftpd-Hpa Server e Client instalado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Instalando o Serviço do Syslinux e Pxelinux, aguarde..."
	apt -y install syslinux syslinux-utils syslinux-efi pxelinux
echo -e "Syslinux e Pxelinux instalado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Atualizando o arquivo de configuração do Tftpd-Hpa Server, aguarde..."
	mv -v /etc/default/tftpd-hpa /etc/default/tftpd-hpa.old
	cp -v conf/tftpd-hpa /etc/default/tftpd-hpa
echo -e "Arquivo atualizado com sucesso!!!, continuando com o script...\n"
sleep 5
echo -e "Copiando a estrutura de arquivos e diretórios do Syslinux e Pxelinux, aguarde..."
	mkdir -v $TFTP/pxelinux.cfg
	mkdir -v $TFTP/puppy
	cp -v $PXE/pxelinux.0 $TFTP
	cp -v $SYSLINUX/memdisk $TFTP
	cp -v $SYSLINUX/modules/bios/{ldlinux.c32,libcom32.c32,libutil.c32,vesamenu.c32} $TFTP
	cp -v conf/default-pxe $TFTP/pxelinux.cfg/default
echo -e "Estrutura de arquivos e diretórios copiados com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Tftpd-Hpa Server, pressione <Enter> para continuar."
	read
	vim /etc/default/tftpd-hpa
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do ISC-DHCP Server, pressione <Enter> para continuar."
	read
	vim /etc/dhcp/dhcpd.conf
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do TCPWrappers, pressione <Enter> para continuar."
	read
	vim /etc/hosts.allow
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Editando o arquivo de configuração do Pxelinux, pressione <Enter> para continuar."
	read
	vim $TFTP/pxelinux.cfg/default
echo -e "Arquivo editado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Baixando a distribuição Puppy Linux e criando o Boot PXE, aguarde esse processo demora um pouco..."
	rm -v puppy.iso
	wget $PUPPY -O puppy.iso
	mount -v puppy.iso /mnt
	cp -av /mnt/vmlinuz $TFTP/puppy
	mkdir -v /tmp/puppy
	cd /tmp/puppy
		zcat /mnt/initrd.gz | cpio -i -v
		cp -av /mnt/*.sfs .
		find . | cpio -o -H newc | gzip -9 -v > $TFTP/puppy/initrd.gz
		umount -v /mnt
	cd - &>>
echo -e "Criação do Boot PXE do Puppy Linux feito com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do Tftpd-Hpa Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart tftpd-hpa
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Reinicializando o serviço do ISC-DHCP Server, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	systemctl restart isc-dhcp-server
echo -e "Serviço reinicializado com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Verificando as portas do ISC-DHCP Server e do Tftpd-Hpa Server, aguarde..."
	# opção do comando netstat: -a (all), -n (numeric)
	netstat -an | grep ':67\|:69'
echo -e "Portas de conexões verificadas com sucesso!!!, continuando com o script...\n"
sleep 5
#
echo -e "Pressione <Enter> para concluir o processo."
read
exit 1
