#!/usr/bin/env bash

#==================================================================================
# Ce script va transformer ma liste des URL (format texte) en tableau (format HTML)
# Le tableau contiendra :
# -le numéro de la ligne pour chaque URL, 
# -le code
# -l'URL
# -le nom de l'encodage utilisé
# -le fichier dump en html
# -le fichier dump en txt
# -le nombre d'occurrences du mot choisi pour chaque URL
# -le contexte gauche et droit du mot
# -le concordancier avec les cooccurrences du mot
# Pour lancer le script:
# bash nom_du_script.sh fichier_url.txt fichier_tableau.html
#==================================================================================

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments."
	exit
fi

mot="[Nn]erds?" # penser à rajouter d'autres formes pour améliorer !! (genre/nombre/les cas! + guillemets ? + écriture emprunté ?)


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
echo "<tr><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>dump html</th><th>dump text</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr>" >> $fichier_tableau


#------------------------------Condition pour remplir le tableau--------------------------#

lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	charset=$(curl -Ls $URL -D - -o "./aspirations/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	# autre façon, avec l'option -w de cURL
	# code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
	# charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	echo -e "\tcode : $code";

	if [[ ! $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi
echo "$dump" > "./dumps-text/$basename-$lineno.txt"



#pour compter le nombre d'occurrences
NB_OCC=$(grep -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)

	
#pour extraire des contextes A=after, B=before (droite et gauche)	
grep -E -A2 -B2 $mot ././dumps-text/$basename-$lineno.txt > ././contextes/$basename-$lineno.txt

#pour construire des concordanciers avec cooccurrences depuis une commande externe
bash ./concordance.sh ././dumps-text/$basename-$lineno.txt $mot > ././concordances/$basename-$lineno.html

#--------------------------------------Ajout dans le tableau ------------------------------------#


	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="././aspirations/$basename-$lineno.html">html</a></td><td><a href="././dumps-text/$basename-$lineno.txt">txt</a></td><td>$NB_OCC</td><td><a href="././contextes/$basename-$lineno.txt">contextes</a></td><td><a href="././concordances/$basename-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau 
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls

#---------------------------------------Fermeture du tableau-------------------------------------#
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau

