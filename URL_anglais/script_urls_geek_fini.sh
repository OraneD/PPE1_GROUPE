#!/usr/bin/env bash

#==================================================================================
# Ce script va traiter la liste des URL (format texte) et etre redirigé en tableau (format HTML)
# Le tableau contiendra :
# -le numéro de la ligne pour chaque URL, 
# -le code
#-l'encodage de la page (on va convertir les pages qui ne sont pas encodées en UTF-8)
# -l'URL
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
mot="[Gg]eek(dom|s|[Mm]om|[Dd]ad)?"

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
echo "<tr><th>ligne</th><th>code</th><th>encodage</th><th>URL</th><th>dump html</th><th>dump text</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	encodage=$(curl -Ls $URL -D - -o "./aspirations/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2 | tail -n 1)

echo -e "\tcode : $code";

	if [[ ! $encodage ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		encodage="UTF-8";
	else
		echo -e "\tencodage : $encodage";
	fi

	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $URL)
		echo $encodage
		if [[ $encodage -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $encodage -t "UTF-8//IGNORE")
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		encodage=""
	fi
echo "$dump" > "./dumps-text/$basename-$lineno.txt"

#on va maintenant compter le nombre d'occurrences
NB_OCC=$(grep -E -o $mot ./dumps-text/$basename-$lineno.txt | wc -l)

#extraction des contextes A=after, B=before (droite + gauche)
grep -E -B2 -A2 $mot ././dumps-text/$basename-$lineno.txt > ././contextes/$basename-$lineno.txt

#construction des concordanciers avec des cooccurrences via un appel d'un autre script
bash ./concordance.sh ././dumps-text/$basename-$lineno.txt $mot > ././concordances/$basename-$lineno.html

#fin du tableau
echo "<tr><td>$lineno</td><td>$code</td><td>$encodage</td><td><a href=\"$URL\">$URL</a></td><td><a href="././aspirations/fich-$lineno.html">html</a></td><td><a href="././dumps-text/$basename-$lineno.txt">txt</a></td><td>$NB_OCC</td><td><a href="././contextes/$basename-$lineno.txt">contextes</a></td><td><a href="././concordances/$basename-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau 
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau