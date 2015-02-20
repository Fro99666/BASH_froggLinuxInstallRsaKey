#!/bin/bash
#            _ __ _
#        ((-)).--.((-))
#        /     ''     \
#       (   \______/   )
#        \    (  )    /
#        / /~~~~~~~~\ \
#   /~~\/ /          \ \/~~\
#  (   ( (            ) )   )
#   \ \ \ \          / / / /
#   _\ \/  \.______./  \/ /_
#   ___/ /\__________/\ \___
#  *****************************
SCN="IRK"   					# script name
SCD="Install Rsa Key"			# script description
SCT="Debian"					# script OS Test
SCC="bash ${0##*/}"				# script call
SCV="1.000"						# script version
SCO="2015/02/18"				# script date creation
SCU="2015/02/18"				# script last modification
SCA="Marsiglietti Remy (Frogg)"	# script author
SCM="admin@frogg.fr"			# script author Mail
SCS="cv.frogg.fr"				# script author Website
SCF="Arnaud Marsiglietti"		# script made for
SCP=$PWD						# script path
SCY="2015"						# script copyrigth year

#requiered:
##client
# ~/.ssh/authorized_keys		700 for {user}
# ~/.ssh/know_hosts				700 for {user}
##server
# /home/{use}/.ssh/				700 for {user}
# root/.ssh/authorized_keys		700 for root:root
# root/.ssh/know_hosts			700 for root:root
# /etc/ssh/ssh_config 			PubkeyAuthentication yes
#								RSAAuthentication yes
#
# client ssh rsa too much connect:
# ssh-add -D
# ssh -p 2222 -o PubkeyAuthentication=no username@server

# === func used to ask user to answer yes or no, return 1 or 0
makeachoice()
{
userChoice=0
while true; do
	read -p " [ Q ] Do you wish to $1 ?" yn
	case $yn in
		y|Y|yes|YES|Yes|O|o)userChoice=1;break;;
		n|N|no|NO|No)userChoice=0;break;;
		* )echo " [ ERROR ] '$yn' isn't a correct value, Please choose yes or no";;
	esac
done
return $userChoice
}	

#echo with "good" result color
good()
{
echo -e "${GOOD}$1${NORM}"
}
#echo with "err" result color
err()
{
echo -e "${ERR}$1${NORM}"
}
#colors
NORM="\e[0m"
GOOD="\e[1m\e[97m\e[42m"	
ERR="\e[1m\e[97m\e[41m"
	
# Script begin
echo -e "\n*******************************"
echo -e "# ${SCN}"
echo -e "# ${SCD}"
echo -e "# Tested on   : ${SCT}"
echo -e "# v${SCV} ${SCU}, Powered By ${SCA} - ${SCM} - ${SCS} - Copyright ${SCY}"
echo -e "# For         : ${SCF}"
echo -e "# script call : ${SCC}\n"
echo -e "Optional Parameters"
echo -e " ${SCC} {user}@{server} {port}"
echo -e "*******************************\n"
nbAct=4
defaultSSH=22

scriptParam=$1
# SET VAR or get from param {user}@{serverip}
if [ -z $scriptParam ];then
	echo " [ Q ] Please choose the server address :" 
	read -p " " hserv
	echo " [ Q ] Please choose your user :"
	read -p " " huser
	echo " [ Q ] Please choose server port :"
	read -p " " hport
	if [ $hport = "" ];then
		hport=$defaultSSH
	fi	
else
	huser=${scriptParam%%@*}
	hserv=${scriptParam##*@}
	if [ $2 = "" ];then
		hport=$defaultSSH
	else
		hport=$2
	fi
fi


#Test if ssh server is UP
check "...Checking if ssh server '${huser}@${hserv}:$hport' is available, please wait..."
if nc -w5 -z ${srvOriginGit} ${gPort} &> /dev/null;then
	good " [ A ] Server Git Origin [${huser}@${hserv}:${hport}] port is opened !"	
else
	err " [ A ] Can't access to Server Git Origin Port [${huser}@${hserv}:${hport}], End of the script"
	exit
fi

# Ask if info are correct
makeachoice "create RSA connexion to '${huser}@${hserv}:$hport'"
if [ $? = 0 ]; then
	echo " [ A ] End of the script, aborted by user"
	exit
fi

# CREATE RSA KEY
good "create your public and private RSA keys ( step 1/$nbAct )"
# RSA Key (public & private) generation + increase security
ssh-keygen -t rsa

# SEND RSA KEY
good "send your RSA key to $hserv  ( step 2/$nbAct )"
# copy the public key to server account .ssh path (same as ssh-copy-id but work anywhere)
ssh-copy-id -i ~/.ssh/id_rsa.pub "-p $hport ${huser}@${hserv}"
#cat ~/.ssh/id_rsa.pub | ssh -p $hport ${huser}@${hserv} 'cat >> /root/.ssh/authorized_keys'

# SET CLIENT RSA PASSPHRASE AUTH
good "add RSA key to local bash ( step 3/$nbAct )"
# add to bash rsa paraphrase
ssh-add

# TEST SSH CONNEXION
good "test the ssh connexion, it should not ask password and auto connect you to server, then type 'exit' to leave ( step 4/$nbAct )"
ssh -p $hport ${huser}@${hserv}

good "End of the script, all steps are done, to prevent paraphrase ask you can type 'ssh-add' in bash each time you start a session"