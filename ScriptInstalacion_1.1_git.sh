#!/usr/bin/env bash
set -o errexit # Script exits when a command fails.
set -o nounset # Script exits when use undeclared var.
set -o pipefail # Pipe exits 0 when all commands inside have been successful
#set -o xtrace  # Script traces what gets execute

#Script de configuración inicial mediante menú para Xubuntu 18.04.X. No probado en 20.04.
#Versión 0.0.1 // 2018-10
#Versión 0.9.8 // 2019-05
#Versión 0.9.9 // 2020-08 // Se añade menú Fusion Inventor(en pruebas) gnome-disk-utility y seahorse (gestor de usuario/passwd)
#Versión 1.0 // 2020-09 // Se sustituye docky por plank.Se añaden fn para Wifi BrosTrend y netExtender. Se elimina el repo de grub al dar un error con Xubuntu 20.04 y se añade al fnUpdateAndInstall como app. Shutter pasa a Snap
#Versión 1.1 // 2021-02 // Añadido keepassxc en fnUpdateAndInstall

function fnPresentacion(){
	clear;
	fnDeco1;
	echo -e "\t\t\t\033[93mScript de configuración inicial";
	fnDeco1;
	echo -e "\t\t\t\t\033[93mVersión 1.1\033[0m";
	fnDeco2;
}
function fnDeco1(){
	echo -e "\t\033[32m###########################################################\033[0m";
};
function fnDeco2(){
	echo -e "\t\033[32m-----------------------------------------------------------\033[0m";
};
function fnError(){
	echo;
	fnDeco1;
	echo -e "\t\033[31m\t LLamada a función fnError()";
	echo -e "\t\t ${1-'Error indeterminado'}";
	echo -e "\t\t Observaciones:${2-'-----'}";
	fnDeco1;
	exit 1;
};
function fnInfo(){
	echo && fnDeco2 && echo -e "\t\t\033[94m ${1-Orden ejecutada con exito}\033[0m" && fnDeco2 && echo;
};
function fnPedirDato(){
	local vResult="";
	read -p "		Introduzca ${1}: " vResult;
	echo "${vResult}";
};
function fnPedirTecla(){
	#-s silent(not print on screen) -p prompt(message) -n(characters) -r()
	echo -e "\t" && read -n 1 -s -r -p '	Pulse una tecla para continuar ';
	sleep 0.3s;
};
function fnBye(){
	local -i i;
	sleep 0.3s;
	for i in {2..0}
	do
		clear;
		fnDeco1;
		echo -e "\t \t \t\033[93mCerrando en ${i}s";
		fnDeco1;
		sleep 1s;
	done;
	clear;
	exit 0;
};
function fnCTRL+C(){
trap "fnError 'Has pulsado CTRL+C'" SIGINT;
};
function fnAddRepos(){
#Revisar repo oficial de ultima versión estable de libreoffice
	sudo add-apt-repository -y ppa:libreoffice/ppa || fnError "Error en fnAddRepos()";
};
function fnAddRepoGrubCustomizer(){
#Para Xubuntu 18.04
	sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer && sudo apt update -y && sudo apt upgrade -y || fnError "Error en fnAddRepoGrubCustomizer()";
};
function fnInstallSnapApps(){
sudo snap install shutter;
}
function fnInstallDocky(){
	sudo apt update -y && sudo apt upgrade -y && sudo apt install -y docky || fnError "Error en fnInstallDocky()";
    }
function fnUpdateAndInstall(){
	sudo apt update -y && sudo apt upgrade -y && sudo apt install -y aptitude samba smbclient cifs-utils plank thunderbird xul-ext-lightning thunderbird-locale-es vlc  chromium-browser ssh firefox-locale-es gdebi libreoffice-help-es libreoffice-impress libreoffice-pdfimport nautilus nautilus-share xfce4-goodies soundconverter grub-customizer gnome-disk-utility seahorse grub-customizer keepassxc ttf-mscorefonts-installer &&  fnInstallSnapApps && fnInfo && echo -e "\tSe recomienda salir del script y reiniciar el equipo"  && fnPedirTecla || fnError "Error en fnUpdateAndInstall()";
};
function fnDownAndInstallTeamViewer(){
#-P no funciona, probar si es por incompatibilidad con otras opc
	local vDownloadFolder="/tmp";
	local vRemoteSource="http://download.teamviewer.com/download/version_12x/teamviewer_i386.deb";
	local vNameDebLocal="Teamviewer12.deb";
	local vNameDebLocalTmp="teamviewer_i386.deb";
	local vFileDebRemote="${vDownloadFolder}/${vNameDebLocal}";
	local vFileDebRemoteTmp="${vDownloadFolder}/${vNameDebLocalTmp}";

	#[[ $(wget -P ${vDownloadFolder} -O ${vNameDebLocal} ${vRemoteSource} ) ]] && dpkg -i ${vFileDebRemote} || sudo apt install -f -y && fnInfo && sudo rm ${vFileDebRemote} || fnError "Error dentro de fnDownAndInstallTeamViewer()" && fnPedirTecla;
	#[[ $(wget -O ${vNameDebLocal} ${vRemoteSource} -P ${vDownloadFolder}) ]] && dpkg -i ${vFileDebRemote} && fnInfo && sudo rm ${vFileDebRemote} || sudo apt install -f -y && fnInfo && sudo rm ${vFileDebRemote} || fnError "Error dentro de fnDownAndInstallTeamViewer()";
	#[[ $(wget -O ${vNameDebLocal} ${vRemoteSource} ) ]] && dpkg -i ./${vNameDebLocal} || sudo apt install -f -y && fnInfo && sudo rm ./${vNameDebLocal} || fnError "Error dentro de fnDownAndInstallTeamViewer()" && fnPedirTecla;
	[[ $(wget -P ${vDownloadFolder} ${vRemoteSource}) ]] && dpkg -i ${vFileDebRemoteTmp} && fnInfo && sudo rm ./${vFileDebRemoteTmp} || sudo apt install -f -y && fnInfo && sudo rm ./${vFileDebRemoteTmp};
fnPedirTecla;
};
function fnTeamViewerByGdebi(){
#gdebi resuelve dependencias auto~.
wget -O Teamviewer12.deb http://download.teamviewer.com/download/version_12x/teamviewer_i386.deb && sudo gdebi -n ./Teamviewer12.deb && fnInfo && sudo rm ./Teamviewer12.deb || fnError "Error dentro de fnTeamViewerByGdebi()";
};
function fnCrearCredentials(){
	local vCredentialsPath="";
	[[ "${1-0}" -eq "0" ]] && vCredentialsPath="/home/ituser/.smbcredentials" || vCredentialsPath="/home/ituser/.smbcredentials02";
	local vUsername=$(fnPedirDato "Username");
	local vPassword=$(fnPedirDato "Password");
	local vDomain=$(fnPedirDato "Domain");
	local vSentry="";
	cat /etc/passwd | grep "ituser" > /dev/null && vSentry=0 || vSentry=1;
	if [[ "$vSentry" -eq 0 ]]
	then
	[[ -w "$vCredentialsPath" ]] && fnInfo "El fichero ya existe, se sobreescribirán los datos";
	sudo touch "${vCredentialsPath}" && echo -e "username=${vUsername}\npassword=${vPassword}\ndomain=${vDomain}" > "${vCredentialsPath}" && sudo chmod 600 "${vCredentialsPath}" && sudo chown ituser "${vCredentialsPath}" && sudo chgrp ituser "${vCredentialsPath}" &&  fnInfo && fnPedirTecla || fnError "Error en fnCrearCredentials()";
	else
	fnInfo "Usuario ituser no encontrado, es necesario crearlo para proseguir" && fnPedirTecla || fnError "Error en fnCrearCredentials()";
	fi;
};
function fnBorrarVariosCredentials(){
	local vPath="/home/ituser/.smbcredentials*";
	local -i i=0;
	ls -p $vPath &>/dev/null
	if [[ $? -eq 0 ]]
	then
		for vItem in $(ls -p $vPath)
 		do
			((i+=1));
 			sudo rm $vItem && echo -e "\tCoincidencia $i borrada de /home/ituser";

		done;
	else
		echo -e "\tNo hay coincidecias";
	fi;
	fnPedirTecla;
};
function fnCrearCarpetasPuntoMontajeBB(){
	local vPathShare="/media/shares/Shared";
	local vPathBrach="/media/shares/${1-Branch}";
	if [[ ! -d "$vPathShare" ]]
	then
		sudo mkdir -p "$vPathShare"
	fi;
	if [[ ! -d "$vPathBrach" ]]
	then
		sudo mkdir -p "$vPathBrach"
	fi;
};
function fnBorrarCarpetasPuntoMontajeBB(){
	local vPath="/media/shares";
	if [[ -d "${vPath}" ]]
	then
		sudo rm -R "${vPath}" && fnInfo || fnError "Error borrando /media/shares";
	else
		fnInfo "Carpetas dentro de /media/share no encontradas";
	fi;
	fnPedirTecla;
};
function fnBackUpFstab(){
	local vRandom=$(($RANDOM%100));
	local vNombreFstabBak="/etc/fstab.$vRandom.bak";
	sudo cp /etc/fstab "$vNombreFstabBak";
	fnDeco2 && echo -e "\tBackup de fstab guardado en /etc/fstab.$vRandom.bak" && fnDeco2;
};
function fnBackUpHostname(){
	local vRandom=$(($RANDOM%100));
	local vNombreHostname="/etc/hostname.$vRandom.bak";
	sudo cp /etc/hostname "$vNombreHostname";
	fnDeco2 && echo -e "\tBackup de hostname guardado en /etc/hostname.$vRandom.bak" && fnDeco2;
};
function fnElegirSucursal(){
	fnDeco2;
	echo -e "\t Elije la sucursal del usuario";
	fnDeco2;
	echo -e "\t 1) Area Central";
	echo -e "\t 2) Centro";
	echo -e "\t 3) Finisterra";
	echo -e "\t 4) Norte";
	echo -e "\t 5) Este";
	echo -e "\t 6) Mediterraneo";
	echo -e "\t 7) Sur";
	echo -e "\t 8) Volver";
	fnDeco2;
};
function fnAddToFstab(){
	local vPath="/etc/fstab";
	echo "${1}" | sudo tee -a "${vPath}" > /dev/null || fnError "Error en fnAddToFstab()";
};
function fnEditFstab(){
#pendiente  ==> registros dupplicados fstab // puedo preguntar por carpeta usuario una vez según vSucursal
	local vPath="/etc/fstab";
	local vRutaShare="//x.x.x.x/Shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaAb="//x.x.x.x/ab /media/shares/Branch cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaMad="//x.x.x.x/mad /media/shares/Branch cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaGal="//x.x.x.x/shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaBil="//x.x.x.x/shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaBcn="//x.x.x.x/shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaVal="//x.x.x.x/shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vRutaSev="//x.x.x.x/shared /media/shares/Shared cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	local vSucursal="";
	local vNombreCarpetaPersonalUsuario="";
	local vRutaBb="";
	fnPresentacion && fnBackUpFstab && fnElegirSucursal && vSucursal=$(fnPedirDato "Numero de Sucursal") && fnAddToFstab "#Carpetas departamentales y/o personales" || fnError "Error en fnEditFstab()";

	case "$vSucursal" in
	1)vRutaBb="$vRutaAb";
	fnCrearCarpetasPuntoMontajeBB && fnAddToFstab "${vRutaShare}" && fnAddToFstab "${vRutaBb}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	#echo "${vRutaShare}" | sudo tee -a "${vPath}" > /dev/null || fnError "Error en fnEditFstab(vRutaShare)";
	#echo "${vRutaBb}" | sudo tee -a "${vPath}" > /dev/null || fnError "Error en fnEditFstab(vRutaBb)";
	;;
	2)vRutaBb="$vRutaMad";
	fnCrearCarpetasPuntoMontajeBB && fnAddToFstab "${vRutaShare}" && fnAddToFstab "${vRutaBb}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	;;
	3)vNombreCarpetaPersonalUsuario=$(fnPedirDato "Nombre de la carpeta del usuario");
	local vRutaCarpetaUsuario="//x.x.x.x/$vNombreCarpetaPersonalUsuario /media/shares/$vNombreCarpetaPersonalUsuario cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	fnCrearCarpetasPuntoMontajeBB "$vNombreCarpetaPersonalUsuario" && fnAddToFstab "${vRutaGal}" && fnAddToFstab "${vRutaCarpetaUsuario}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
		#echo "${vRutaShare}" | sudo tee -a "${vPath}" > /dev/null || fnError "Error en fnEditFstab(vRutaShare)";
		#echo "${vRutaCarpetaUsuario}" | sudo tee -a "${vPath}" > /dev/null || fnError "Error en fnEditFstab(vRutaShare)";
	;;
	4)vNombreCarpetaPersonalUsuario=$(fnPedirDato "Nombre de la carpeta del usuario");
	local vRutaCarpetaUsuario="//x.x.x.x/$vNombreCarpetaPersonalUsuario /media/shares/$vNombreCarpetaPersonalUsuario cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	fnCrearCarpetasPuntoMontajeBB "$vNombreCarpetaPersonalUsuario" && fnAddToFstab "${vRutaBil}" && fnAddToFstab "${vRutaCarpetaUsuario}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	;;
	5)vNombreCarpetaPersonalUsuario=$(fnPedirDato "Nombre de la carpeta del usuario");
	local vRutaCarpetaUsuario="//x.x.x.x/$vNombreCarpetaPersonalUsuario /media/shares/$vNombreCarpetaPersonalUsuario cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	fnCrearCarpetasPuntoMontajeBB "$vNombreCarpetaPersonalUsuario" && fnAddToFstab "${vRutaBcn}" && fnAddToFstab "${vRutaCarpetaUsuario}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	;;
	6)vNombreCarpetaPersonalUsuario=$(fnPedirDato "Nombre de la carpeta del usuario");
	local vRutaCarpetaUsuario="//x.x.x.x/$vNombreCarpetaPersonalUsuario /media/shares/$vNombreCarpetaPersonalUsuario cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	fnCrearCarpetasPuntoMontajeBB "$vNombreCarpetaPersonalUsuario" && fnAddToFstab "${vRutaVal}" && fnAddToFstab "${vRutaCarpetaUsuario}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	;;
	7)vNombreCarpetaPersonalUsuario=$(fnPedirDato "Nombre de la carpeta del usuario");
	local vRutaCarpetaUsuario="//x.x.x.x/$vNombreCarpetaPersonalUsuario /media/shares/$vNombreCarpetaPersonalUsuario cifs credentials=/home/ituser/.smbcredentials,noperm,iocharset=utf8,nolock,file_mode=0777,dir_mode=0777	0	0";
	fnCrearCarpetasPuntoMontajeBB "$vNombreCarpetaPersonalUsuario" && fnAddToFstab "${vRutaSev}" && fnAddToFstab "${vRutaCarpetaUsuario}" && fnInfo || fnError "Error en fnEditFstab(fnAddToFstab)";
	;;
	8)echo -e "\n\t Opción volver";
	;;
	*)fnError "Error en fnEditFstab(case)" "Elección erronea";
	;;
	esac;
	fnPedirTecla;
};
function fnEditFstabEspecialRoutes(){
#PENDIENTE=> Revisar mkdir.
	local vRutaMarketing="//x.x.x.x/Shared/Marketing2Branches /media/shares/Sharedmad cifs credentials=/home/ituser/.smbcredentials02,noperm,nolock,iocharset=utf8,file_mode=0777,dir_mode=0777       0       0";
	local vRutaGdpr="//x.x.x.x/Shared/oficina.central/Administracion/GDPR /media/shares/SharedmadGDPR cifs credentials=/home/ituser/.smbcredentials02,noperm,nolock,iocharset=utf8,file_mode=0777,dir_mode=0777       0       0";
	fnBackUpFstab && fnCrearCredentials 1 && fnAddToFstab "#Rutas ubicadas en la central, usan un credentials diferente" && fnAddToFstab "$vRutaGdpr" && fnAddToFstab "$vRutaMarketing" && fnInfo || fnError "Error en fnEditFstabEspecialRoutes()";
	sudo mkdir -p "/media/shares/Sharedmad" && sudo mkdir -p "/media/shares/SharedmadGDPR";
};
function fnAddUser(){
#pendiente => Leer datos del .smbcredentials //useradd crea bloq la cuenta
 	local vUsername=$(fnPedirDato "Username");
	local vName=$(fnPedirDato "Nombre a mostrar");
	#local vPassword=$(fnPedirDato "Password");
#useradd crea bloq la cuenta, se necesita passwd despues
#-m crea la home, -c comentario o nombre completo
	#useradd -m -s "/bin/bash" -p "${vPassword}" -c "${vName}" "${vUsername}";
	useradd -m -s "/bin/bash" -c "${vName}" "${vUsername}";
	sudo passwd ${vUsername}

	fnPedirTecla;
};
function fnAddUser2(){
 	local vUsername=$(fnPedirDato "Username");
	sudo adduser "${vUsername}" --force-badname;
	fnPedirTecla;
};
function fnConfigurarImpresorasSucursal(){
	local vSucursal="";
	while [[ "$vSucursal" != "8" ]]
	do
		fnPresentacion && fnElegirSucursal && vSucursal=$(fnPedirDato "Numero de Sucursal") || fnError "Error en fnConfigurarImpresorasSucursal()";
		case "$vSucursal" in
			[1-7]) fnConsultaImpresorasSucursal "$vSucursal" && vSucursal="8";
			# 1 | 2| 3 | 4 | 5 | 6 | 7) fnConsultaImpresorasSucursal "$vSucursal";
			;;
			8) echo -e "\n\t\tEstás volviendo al menú principal" && sleep 1.3s;
			;;
			*) fnInfo "Error al seleccionar sucursal" && fnPedirTecla;
			;;
		esac;
	done;
};
function fnConsultaImpresorasSucursal(){
	local pSucursal=$((${1} - 1))
	local pSucursalC=$((${1} + 6))
	local aPrtSpoolName;
	local aPrtCommandOptions;

	aPrtSpoolName[0]="ImpresoraAreaByN";
	aPrtSpoolName[1]="ImpresoraCentrodByN";
	aPrtSpoolName[2]="PrtFinisterra01-ByN";
	aPrtSpoolName[3]="PrtNorte01-ByN";
	aPrtSpoolName[4]="PrtEste01-ByN";
	aPrtSpoolName[5]="PrtMed01-ByN";
	aPrtSpoolName[6]="PrtSur01-ByN";
	aPrtSpoolName[7]="ImpresoraAreaColor";
	aPrtSpoolName[8]="ImpresoraCentralColor";
	aPrtSpoolName[9]="PrtFinisterra01-Color";
	aPrtSpoolName[10]="PrtNorte01-Color";
	aPrtSpoolName[11]="PrtEste01-Color";
	aPrtSpoolName[12]="PrtMed01-Color";
	aPrtSpoolName[13]="PrtSur01-Color";
#Buscar driver con lpinfo - m | grep modelo_prt
#cups localhost:631 lpadmin -p "nombre de la cola de impresión" -v ruta/puerto/ordenador donde se comparte  -m driver.ppd
	aPrtCommandOptions[0]="-p ${aPrtSpoolName[0]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_3054_PS.ppd";
	aPrtCommandOptions[1]="-p ${aPrtSpoolName[1]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_3054_PS.ppd";
	aPrtCommandOptions[2]="-p ${aPrtSpoolName[2]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C306Z_PS.ppd";
	aPrtCommandOptions[3]="-p ${aPrtSpoolName[3]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";
	aPrtCommandOptions[4]="-p ${aPrtSpoolName[4]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";
	aPrtCommandOptions[5]="-p ${aPrtSpoolName[5]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-Aficio_3045_PS.ppd";
	aPrtCommandOptions[6]="-p ${aPrtSpoolName[6]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";
	aPrtCommandOptions[7]="-p ${aPrtSpoolName[7]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_3054_PS.ppd";
	aPrtCommandOptions[8]="-p ${aPrtSpoolName[8]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_3054_PS.ppd";
	aPrtCommandOptions[9]="-p ${aPrtSpoolName[9]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C306Z_PS.ppd";
	aPrtCommandOptions[10]="-p ${aPrtSpoolName[10]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";
	aPrtCommandOptions[11]="-p ${aPrtSpoolName[11]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";
	aPrtCommandOptions[12]="-p ${aPrtSpoolName[12]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-Aficio_3045_PS.ppd";
	aPrtCommandOptions[13]="-p ${aPrtSpoolName[13]} -v socket://x.x.x.x:9100 -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C307_PS.ppd";

local vNombreImpresoraByN=${aPrtSpoolName[$pSucursal]};
local vNombreImpresoraC=${aPrtSpoolName[$pSucursalC]};
local vComandoByN=${aPrtCommandOptions[$pSucursal]};
local vComandoC=${aPrtCommandOptions[$pSucursalC]};

	echo -e "\n\t==>> Añadiendo las impresoras, espere por favor.....<<== " && fnAddPrinters $vNombreImpresoraByN "$vComandoByN" && fnSetDefaultPrinter $vNombreImpresoraByN && fnAddPrinters $vNombreImpresoraC "$vComandoC" && fnInfo && fnPedirTecla || fnError "Error en fnConsultaImpresorasSucursal()";
};
function fnAddPrinters(){
	sudo lpadmin ${2} && sudo cupsenable "${1}" && sudo cupsaccept "${1}" || fnError "Error en fnAddPrinters()";
};
function fnSetDefaultPrinter(){
#ColorModel/Color Mode: *CMYK Gray #ColorModel=Gray ColorModel[Gray]=true
# ¿sudo? lpoptions -p ${1} -o ColorModel=Gray Parece cambiado con lpoptions -p impresora -l, pero bloquea el cambio x frontend
sudo lpadmin -d ${1} || fnError "Error en fnSetDefaultPrinter()";
};
function fnCambiarHostname(){
	local vHostName=$(hostname);
	local vAnsw="";
	local vNuevoHostName="";
	local vPath="/etc/hostname";
	echo -e "\tEl nombre actual del equipo es ==> ${vHostName}";
	echo -e "";
	read -p "	¿Quiere cambiar el nombre al equipo?(y/n)" vAnsw;
	if [[ "$vAnsw" == ["y-Y-s-S"] ]]
	then
		fnBackUpHostname;
		read -p "	Escriba el nuevo nombre de maquina y pulse INTRO	" vNuevoHostName;
		echo "${vNuevoHostName}" | sudo tee "${vPath}" > /dev/null && echo -e "\n\tRecuerde reiniciar para que se aplique el cambio" || fnError "Error en fnCambiarHostname(tee)";
	fi;
	fnPedirTecla;
};
function fnInstalarFusionInventory(){
#Revisar si se puede añadir la linea a /etc/fusion al final del archivo o hay que buscar el punto exacto. Editar la linea de la conf default?
	local vOption="";
	local vServerPathLine="server = http://x.x.x.x/glpi/plugins/fusioninventory/";
	local vServerPath="http://x.x.x.x/glpi/plugins/fusioninventory/";
	local vConfigFile="/etc/fusioninventory/agent.cfg";
	fnPresentacion && fnDeco2;
	echo -e "\t\tInstalación de Fusión Inventory";
	fnDeco2;
	echo -e "\n\tOpción en pruebas!!!!" && echo;
	read -p "	¿Quiere instalar Fusión Inventory en el equipo?(y/n) " vOption && echo -e "\n";
	if [[ "$vOption" == ["y-Y-s-S"] ]]
	then
		fnInfo "INStalando aplicación......" && sudo apt update && sudo apt install -y fusioninventory-agent && echo "${vServerPathLine}" | sudo tee -a "${vConfigFile}" > /dev/null && fnInfo && read -p "	¿Lanzar inventariado de equipo?(y/n) " vOption && echo -e "\n" && if [[ "$vOption" == ["y-Y-s-S"] ]]
		then
			fnInfo "Inventariando equipo......" && sudo fusioninventory-agent /runnow && fnInfo || fnError "Error dentro de fnInstalarFusionInventory(Mientras se realizaba el inventario)";
			#fnInfo "Inventariando equipo......" && sudo fusioninventory-agent --server=http://x.x.x.x/glpi/plugins/fusioninventory/ /runnow && fnInfo || fnError "Error dentro de				 fnInstalarFusionInventory(Mientras se realizaba el inventario)";
		fi || fnError "Error dentro de fnInstalarFusionInventory(Instalando)";
	fi;
	fnPedirTecla;
};
function fnInstalarNetExtender(){
    local vOption="";
    fnPresentacion;
    fnDeco2;
	echo -e "\t\tInstalación de NetExtender";
	fnDeco2;
	read -p "	¿Quiere instalar NetExtender en el equipo?(y/n) " vOption && echo -e "\n";
	if [[ "$vOption" == ["y-Y-s-S"] ]]
	then
        sudo apt install default-jre && wget -O /tmp/NetExtender.x86_64.tgz https://sslvpn.demo.sonicwall.com/NetExtender.x86_64.tgz && tar xzvf /tmp/NetExtender.x86_64.tgz -C /tmp && cd /tmp/netExtenderClient && echo "y" | sudo ./install;
    fi;
    fnDeco2;
    echo -e "\t\tInstrucciones extra";
    fnDeco2;
    echo -e "\t\tEjecutar en un terminal sudo visudo
Añadir al final del todo:
Cmnd_Alias CARPETAS=/bin/mount -a
ALL ALL=NOPASSWD:CARPETAS

al darle a guardar borramos la extensión tmp y reemplazamos

Añadir lanzador en el escritorio con el comando sudo /bin/mount -a"

fnPedirTecla;
}
function fnInstalarWifiBrosTrend(){
    local vOption="";
    fnPresentacion;
    fnDeco2;
	echo -e "\t\tInstalación WifiBrosTrend";
	fnDeco2;
	read -p "	¿Quiere instalar WifiBrosTrend en el equipo?(y/n) " vOption && echo -e "\n";
	if [[ "$vOption" == ["y-Y-s-S"] ]]
	then
       sudo wget deb.trendtechcn.com/install -O /tmp/install && sudo chmod +x /tmp/install && sudo /tmp/install;
    fi;
	fnPedirTecla
}
function fnMenuTools(){
	fnDeco2;
	echo -e "\t\tMenú Herramientas";
	fnDeco2;
	echo -e "\t 1) Crear Backup fstab to fstab.bak";
	echo -e "\t 2) Borrar todos .smbcredentials* de /home/ituser";
	echo -e "\t 3) Desmontar /media/shares";
	echo -e "\t 4) Añadir impresora de recepción";
	echo -e "\t 5) Instalar LibreOffice last RC";
	echo -e "\t 6) Desinstalar LibreOffice y borrar su Repo";
	echo -e "\t 7) Instalar Adobe Reader";
	echo -e "\t 8) Instalar Repo de Grub-customizer y Docky (Xubuntu 18.04)";
	echo -e "\t 9) Reiniciando!!";
	echo -e "\t 10) Volver";
	fnDeco2;
};
function fnInstalarLibreOfficeLast(){
#myspell-es ??
	#echo -e "\n\tOpción en pruebas." && fnPedirTecla && fnInfo "Instalando aplicación......";
	fnInfo "INStalando aplicación......" && sudo apt update && sudo add-apt-repository -y ppa:libreoffice/ppa && sudo apt install -y libreoffice libreoffice-l10n-es libreoffice-help-es libreoffice-impress libreoffice-pdfimport && fnInfo || fnError "Error en fnInstalarLibreOfficeLast()";
};
function fnDesinstalarLibreOfficeTest(){
#La desintalación funcionó, no se ha revisado los repos.
	echo -e "\n\tOpción en pruebas" && fnPedirTecla;
	sudo apt-get remove --purge libreoffice* && sudo apt-get clean && sudo apt-get autoremove || fnError "Error Desinstalar LibreOffice";
#ppa-purge desinstala las app que se hubieran instalado desde esa fuente
	#sudo apt-get update && apt-get install ppa-purge && sudo ppa-purge ppa:libreoffice/libreoffice-6-1 && sudo ppa-purge ppa:libreoffice/libreoffice || fnError "Borrar repo LibreOffice";
	sudo apt update && sudo add-apt-repository -r ppa:libreoffice/ppa && fnPedirTecla || fnError "Borrar repo LibreOffice";
fnPedirTecla;
};
function fnDesinstalarLibreOffice(){
	fnInfo "DESinstalando aplicación......" && sudo apt update && sudo apt-get remove --purge libreoffice* && sudo apt-get clean && sudo apt-get autoremove && sudo add-apt-repository -r ppa:libreoffice/ppa && fnInfo && fnPedirTecla || fnError "Borrar repo LibreOffice";
};
function fnInstalarAdobeReader(){
	echo -e "\n\tOpción en pruebas" && fnPedirTecla;
#Pre-requisitos
	sudo apt install -y gtk2-engines-murrine:i386 libcanberra-gtk-module:i386 libatk-adaptor:i386 libgail-common:i386 && fnInfo "Pre-requisitos Instalados" || fnError "Error en fnInstalarAdobeReader(Pre-requisitos)";
#Instalación
	sudo add-apt-repository -y "deb http://archive.canonical.com/ precise partner" && sudo apt update && sudo apt install -y adobereader-enu && fnInfo "Instalado el software" || fnError "Error en fnInstalarAdobeReader(Instalación)";
#Post-instalación // Limpiamos
	sudo add-apt-repository -r "deb http://archive.canonical.com/ precise partner" && sudo apt update && fnInfo "Post-instalación Hecha" || fnError "Error en fnInstalarAdobeReader(Post-instalación)";

fnPedirTecla;
};
function fnAddPrtRecepcion(){
	local vNombreImpresora="ImpresoraRecepcionColor";
	local vComando="-p ${vNombreImpresora} -v socket://x.x.x.x:9100  -m openprinting-ppds:0/ppd/openprinting/Ricoh/PS/Ricoh-MP_C401_PS.ppd";
	echo -e "\n\t==>> Añadiendo la impresora, espere por favor.....<<== " && fnAddPrinters $vNombreImpresora "$vComando" && fnInfo && fnPedirTecla || fnError "Error en fnAddPrtRecepcion()";
};
function fnTools(){
	local vOption="";
	while [[ "$vOption" != "10" ]]
	do
		fnPresentacion && fnMenuTools || fnError "Error en fnMenuTools()";
		read -p "	Introduzca una opción y pulse ENTER " vOption;
		echo -e "\n";
		case "$vOption" in
		1)	fnBackUpFstab && fnPedirTecla || fnError "Error en fnBackUpFstab()";
		;;
		2)	fnBorrarVariosCredentials || fnError "Error borrando .smbcredentials*";
		;;
		3)	fnBorrarCarpetasPuntoMontajeBB || fnError "Error borrando /media/shares";
		;;
		4)	fnAddPrtRecepcion || fnError "Error lanzando fnAddPrtRecepcion";
		;;
		5)	fnInstalarLibreOfficeLast || fnError "Error Instalando Libre Office";
		;;
		6)	fnDesinstalarLibreOffice || fnError "Error al Desinstalar LibreOffice";
		;;
		7)	fnInstalarAdobeReader || fnError "Error lanzando fnInstalarAdobeReader";
		;;
		8)	fnAddRepoGrubCustomizer && fnInstallDocky || fnError "Error lanzando fnAddRepoGrubCustomizer y fnInstallDocky";
		;;
		9)	sudo reboot || fnError "Error reiniciando";
		;;
		10)	sleep 0.3s;
		;;
		*)	echo -e "\n\tOpción incorrecta, pruebe otra vez" && sleep 1.3s;
		;;
		esac;
	done;
};
function fnMenuMain(){
	fnDeco2;
	echo -e "\t 1) Actualizar Soft e instalar nuevos paquetes";
	echo -e "\t 2) Crear .smbcredentials con permisos chmod 600";
	echo -e "\t 3) Añadir rutas a fstab y crear puntos de montaje en /media";
	echo -e "\t 4) Crear Usuario y establecer contraseña";
	echo -e "\t 5) Editar el nombre del PC";
	echo -e "\t 6) Añadir impresoras de red ByN y Color";
	echo -e "\t 7) Añadir ruta GDPR y Marketing2Branches a fstab";
	echo -e "\t 8) Descargar e Instalar TeamViewer12";
	echo -e "\t 9) Instalar Fusion Inventory";
    echo -e "\t 10) Instalar NetExtender";
	echo -e "\t 11) Instalar Wifi BrosTrend";
	echo -e "\t 12) Herramientas";
	echo -e "\t 13) Salir";
	fnDeco2;
};
function fnMain(){
	local vOption="";
	while [[ "$vOption" != "13" ]]
	do
		fnPresentacion && fnMenuMain && fnCTRL+C || fnError "Error en fnMenuMain()";
		read -p "	Introduzca una opción y pulse ENTER " vOption;
		echo -e "\n";
		case "$vOption" in
		1)	fnAddRepos && fnUpdateAndInstall || fnError "Error en fnAddRepos or fnUpdateAndInstall()";
		;;
		2)	fnCrearCredentials || fnError "Error en fnCrearCredentials()";
		;;
		3)	sleep 0.3s && fnEditFstab || fnError "Error en fnEditFstab()";
		;;
		4)	fnAddUser2 || fnError "Error en fnAddUser2()";
		;;
		5)	fnCambiarHostname || fnError "Error en fnCambiarHostname()";
		;;
		6)	fnConfigurarImpresorasSucursal || fnError "Error en fnConfigurarImpresorasSucursal()";
		;;
		7)	fnEditFstabEspecialRoutes || fnError "Error en fnEditFstabEspecialRoutes()";
		;;
		8)	#fnDownInstallTeamViewer || fnError "Error en fnDownInstallTeamViewer()";
			#fnDownAndInstallTeamViewer || fnError "Error en fnDownAndInstallTeamViewer()";
			fnTeamViewerByGdebi || fnError "Error en fnTeamViewerByGdebi()";
		;;
		9)	fnInstalarFusionInventory || fnError "Error al llamar a fnInstalarFusionInventory()";
		;;
		10)	fnInstalarNetExtender || fnError "Error en fnInstalarNetExtender()";
		;;
		11)	fnInstalarWifiBrosTrend || fnError "Error en fnInstalarWifiBrosTrend()";
		;;
		12)	fnTools || fnError "Error en fnTools()";
		;;
		13)	fnBye || fnError "Error en fnBye()";
		;;
		*)	echo -e "\n\tOpción incorrecta, pruebe otra vez" && sleep 1.3s;
		;;
		esac;
	done;
};
fnMain "${@}";
