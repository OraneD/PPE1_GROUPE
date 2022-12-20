#!/usr/bin/env bash
#script fait pour être lancé à la racine du projet, cela lui permet de récupérer les fichiers dans les bons dossiers.
# Il va se lancer comme suit :./programmes/correction_itrameur.sh

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
	
	echo "$content">> "./itrameur/$folder-$basename.txt"
	
	echo "</text>" >> "./itrameur/$folder-$basename.txt"
	echo "</page> §" >> "./itrameur/$folder-$basename.txt"
done
echo "</lang>" >> "./itrameur/$folder-$basename.txt" 	