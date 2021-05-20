#!/bin/bash

# Vérification des arguments
ARGS=2
# Codes de sortie (Erreurs)
E_MAUVAISARGS=65
E_REP_EXIST=75
E_CONF_EXIST=76
E_DEV_EXIST=77
E_FILESET_EXIST=78


if [ $# -ne "$ARGS" ]
then
        echo
        echo "Usage: `basename $0` nom_client choix_semaine"
        echo
        echo "nom_client : le nom DNS du serveur à sauvegarder"
        echo "choix_semaine :  1|2|3|4 pour la sauvegarde Full ( à choisir après avoir consulté GLPI    )"
        echo
  exit $E_MAUVAISARGS

fi


# On recupere les arguments
serveur=$1
semaine=$2

case $semaine in
        1 ) schedule="Reg-1";;
        2 ) schedule="Reg-2";;
        3 ) schedule="Reg-3";;
        4 ) schedule="Reg-4";;
        * ) echo "Mauvais paramètre !!! ";exit $E_MAUVAISARGS
esac


# On definit les variables
racine="/backup/bareos"
bareos_dir="/etc/bareos/bareos-dir.d"
bareos_dir_conf="/etc/bareos/bareos-dir.d/director/bareos-dir.conf"
bareos_sd_dir="/etc/bareos/bareos-sd.d"
bareos_fd_dir="/etc/bareos/bareos-fd.d"

#Dossier director
dir_client_conf="$bareos_dir/client/$serveur.conf"
dir_pool_conf="$bareos_dir/pool/$serveur.conf"
dir_pool_full_conf="$bareos_dir/pool/$serveur-full.conf"
dir_pool_incr_conf="$bareos_dir/pool/$serveur-incr.conf"
dir_pool_diff_conf="$bareos_dir/pool/$serveur-diff.conf"
dir_fileset_conf="$bareos_dir/fileset/$serveur.conf"
dir_job_conf="$bareos_dir/job/$serveur.conf"
dir_jobdef_conf="$bareos_dir/jobdefs/$serveur.conf"
dir_storage_conf="$bareos_dir/storage/$serveur.conf"

#Dossier SD
sd_device_conf="$bareos_sd_dir/device/$serveur.conf"


#Modele que le sript utilise
mod_dir_client="$bareos_dir/mod/mod_client.dev"
mod_dir_pool="$bareos_dir/mod/mod_pool.dev"
mod_dir_pool_full="$bareos_dir/mod/mod_pool_full.dev"
mod_dir_pool_incr="$bareos_dir/mod/mod_pool_incr.dev"
mod_dir_pool_diff="$bareos_dir/mod/mod_pool_diff.dev"
mod_dir_fileset="$bareos_dir/mod/mod_fileset.dev"
mod_dir_job="$bareos_dir/mod/mod_job.dev"
mod_dir_jobdef="$bareos_dir/mod/mod_jobdef.dev"
mod_dir_storage="$bareos_dir/mod/mod_storage.dev"
mod_sd_device="$bareos_dir/mod/mod_device.dev"

#Creation du repertoire de sauvegarde
if [ ! -d "$racine"/"$serveur" ]
then
        mkdir "$racine"/"$serveur"
        chown -R bareos:disk "$racine"/"$serveur"
else
        echo "Le répertoire de destination existe déjà !!!!"
  exit $E_REP_EXIST
fi

###########################
# Creation des fichiers de conf
###########################

# Client
######

if [ ! -e "$dir_client_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_client> "$dir_client_conf"
else
        echo "Le fichier de Client existe déjà !!!!!"
  exit $E_DEV_EXIST
fi

# Device
######

if [ ! -e "$sd_device_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_sd_device > "$sd_device_conf"
else
        echo "Le fichier de device existe déjà !!!!!"
  exit $E_DEV_EXIST
fi

# Fileset
######

if [ ! -e "$dir_fileset_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_fileset> "$dir_fileset_conf"
else
        echo "Le fichier de Fileset existe déjà !!!!!"
  exit $E_DEV_EXIST
fi


# Job
######

if [ ! -e "$dir_job_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_job> "$dir_job_conf"
else
        echo "Le fichier de Job existe déjà !!!!!"
  exit $E_DEV_EXIST
fi



# Jobdef
######

if [ ! -e "$dir_jobdef_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_jobdef > "$dir_jobdef_conf.tmp"
        sed -e "s/yyyy/$schedule/g" "$dir_jobdef_conf.tmp" > "$dir_jobdef_conf"
        rm -f "$dir_jobdef_conf.tmp"
else
        echo "Le fichier de Jobdef existe déjà !!!!!"
  exit $E_CONF_EXIST
fi


# Pool
######

if [ ! -e "$dir_pool_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_pool> "$dir_pool_conf"
else
        echo "Le fichier de INCR Pool existe déjà !!!!!"
  exit $E_DEV_EXIST
fi

if [ ! -e "$dir_pool_incr_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_pool_incr> "$dir_pool_incr_conf"
else
        echo "Le fichier de INCR Pool existe déjà !!!!!"
  exit $E_DEV_EXIST
fi

if [ ! -e "$dir_pool_full_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_pool_full> "$dir_pool_full_conf"
else
        echo "Le fichier de FULL Pool existe déjà !!!!!"
  exit $E_DEV_EXIST
fi


if [ ! -e "$dir_pool_diff_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_pool_diff> "$dir_pool_diff_conf"
else
        echo "Le fichier de FULL Pool existe déjà !!!!!"
  exit $E_DEV_EXIST
fi



# Storage
######

if [ ! -e "$dir_storage_conf" ]
then
        sed -e "s/xxxx/$serveur/g" $mod_dir_storage> "$dir_storage_conf"
else
        echo "Le fichier de Storage existe déjà !!!!!"
  exit $E_DEV_EXIST
fi


echo
echo
echo "##########################################################################################"
echo
echo "                                    ATTENTION, bien lire la suite ...."
echo
echo "##########################################################################################"
echo
echo "      TOUS les fichiers ont été générés avec SUCCES !!!!"
echo
echo
echo " Pour que la sauvegarde de \"$serveur\" soit effective, il reste les étapes suivantes à accomplir : "
echo
echo "0) Installer et configurer le client bareos sur \"$serveur\" !!! "
echo
echo "1) Renseigner la liste des fichiers à sauvegarder dans  \"$dir_fileset_conf\" (cf exemple)"
echo
echo "2) Renseigner l'adrresse IP du client daans\"$dir_client_conf\" "
echo
echo "3) Renseigner l'adrresse IP de bareos dans \"$dir_storage_conf\" "
echo
echo "4) Relancer les services dans cet ordre (après avoir vérifié qu'il n'y a pas de Job en cours ...)"
echo
echo "          service bareos-dir restart"
echo "          service bareos-sd restart"
echo
