#!/usr/bin/env bash

# attention : ce script doit être lancé depuis la racine du projet.
# Cela lui permet de récupérer les fichiers dans les bons dossiers.
# 
# Pour lancer le script:
# bash itrameur.sh nom_du_dossier nom_du_fichier
# Pour le nom du dossier on prendra le dossier dumps-text ou contextes
# Pour le nom du fichier on prendra le nom du fichier contenant les URLs (sans l'extension)

if [[ $# -ne 2 ]]
then
	echo "Deux arguments attendus : <dossier> <langue>"
	exit
fi

folder=$1 #dossier dumps text ou contextes
basename=$2 #les urls
echo "<lang=\"$basename\">" > "./itrameur/$folder-$basename.txt" 

for filepath in $(ls $folder/$basename-*.txt)
#filepath == dumps texts / fr-1.txt
#pagename = fr-1
# on itère sur un dossier, on cherche dans le dossier en paramètre, des fichiers qui correspondent au basename avec extension .txt
do 
	pagename=$(basename -s .txt $filepath)
	echo "<page=\$pagename\">" >> "./itrameur/$folder-$basename.txt" #on redirige vers le dossier créé auparavant itrameur
	echo "<text>" >> "./itrameur/$folder-$basename.txt" #on redirige vers le dossier créé auparavant itrameur
	
	#on récupère les dumps/contextes
	#on écrit à l'intérieur de la balise text
	
	content=$(cat $filepath)
	content=$(echo "$content"|sed 's/&/&amp;/g') # manière globale dans le fichier, l'ordre ici est important & en premier sinon < => &lt; =>amp;lt;
	content=$(echo "$content"|sed 's/</&lt;/g')
	content=$(echo "$content"|sed 's/>/&gt;/g')
	content=$(echo "$content"|sed 's/[ŠšSs]TREBERA/ŠTREBER/g') # lemmatisation des différentes formes pour regrouper la recherche sur iTrameur
	content=$(echo "$content"|sed 's/[ŠšSs]trebere/ŠTREBER/g')
	content=$(echo "$content"|sed 's/[ŠšSs]treberu/ŠTREBER/g')
	content=$(echo "$content"|sed 's/[ŠšSs]trebera/ŠTREBER/g')
	content=$(echo "$content"|sed 's/[ŠšSs]treberi/ŠTREBER/g')
	content=$(echo "$content"|sed 's/[Gg]iku?/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ikovima/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]eekova/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ika/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]eeka/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]eekove/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ikove/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ikova/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ikovi/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]ik/GIK/g')
	content=$(echo "$content"|sed 's/[Gg]eek/GIK/g')
	content=$(echo "$content"|sed 's/[ŠšSs]treber/ŠTREBER/g')
	content=$(echo "$content"|sed 's/[ŠšSs]treberima/ŠTREBER/g')




	echo "$content">> "./itrameur/$folder-$basename.txt"
	
	echo "</text>" >> "./itrameur/$folder-$basename.txt"
	echo "</page> §" >> "./itrameur/$folder-$basename.txt"
done
echo "</lang>" >> "./itrameur/$folder-$basename.txt" 	
