#!/usr/bin/env bash

#===============================================================================
# Ce script permet de parcourir une liste d'URL afin d'extraire des informations
# qu'on classe dans un tableau HMTL.
# On récupère le code de l'URL, l'URL lui même et l'encodage de la page.
# On peut également compter l'occurrence d
#===============================================================================

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	exit
fi

mot="geek" 

#-------------------------Génération du tableau----------------------------#

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)

echo "<html><head>
            <meta charset = "utf-8"/>
            <title> tableau URL </title>
            <meta name ="viewport" content="width=device-width, initial-scale=1">
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">
             <body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table class=\"table is-bordered is-hoverable is-stripped\">" >> $fichier_tableau
echo "<tr><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>dumps</th><th>aspiration</th><th>occurrences</th></tr>" >> $fichier_tableau


#----------------------- Condition pour remplir le tableau-----------------#


lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1) #on récupère la dernière ligne 
	charset=$(curl -ILs $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	# autre façon, avec l'option -w de cURL
	# code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
	# charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)
	# l'option s permet de pas avoir d'affichage sur le terminal

	echo -e "\tcode : $code";

	if [[ ! $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	if [[ $code -eq 200 ]] #si le code est égal à 200
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]] # on récupère le dump text du site avec lynx
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE) # Si l'encodage n'est pas UTF-8 Il faut faire une conversion. La variable $charset sera l'encodage de départ du fichier comme ça on est sûrs de partir d'où il faut. 
		
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi
        echo "$dump" > "./dumps-text/$basename-s-$lineno.txt" # le text brut de chaque URL est copié dans des fichiers situés dans le dossier dumps-text
        
        # compte du nombre d'occurrences
  NB_OCC=$(grep -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)
  
  
       # extraction des contextes

  grep -E -A2 -B2 $mot ./dumps-text/$basename-s-$lineno.txt > ././contextes/fich-$lineno.txt
  
  
      # construction des concordance avec une commande externe

  bash concordance.sh ./dumps-text/fich-$lineno.txt $mot > ././concordances/fich-$lineno.html
  
  
#----------------------- Ajout dans le tableau-------------------------------#
        
	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="./aspirations/fich-$lineno.html">html</a></td><td><a href="./dumps-text/$basename-s-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="./contextes/fich-$lineno.txt">contextes</a></td><td><a href="./concordances/fich-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));	
done < $fichier_urls

#---------------------------Fermeture du tableau-----------------------------#

echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau
