#!/usr/bin/env bash

#===============================================================================
# VOUS DEVEZ MODIFIER CE BLOC DE COMMENTAIRES.
# Ici, on décrit le comportement du programme.
# On lance le programme avec la ligne de commande. bash + shell + arguments 
# arguments = mon nom de fichier urls 
# curl -I |head donne juste les informations contenues dans l'entête
# option -s passe curl en mode silencieux
# head -n1 me garde juste la ligne où se trouve le code html
# ici, à l'inverse de mon code sur les classements, on utilise cut en plaçant l'option -f 2 avant de placer le délimiteur (l'inverse affiche une erreur)
# cut -f 2 -d ' ' permet de récupérer uniquement le code html
# pour le content type => faire curl -I -s $line |egrep "charset" => puis cut -f2 -d'=' 
# => il faut ensuite le stocker dans une variable encodage=$(curl -I -s $line |egrep "charset"|cut -f2 -d'=')
# traitement en cas de non UTF-8 avec une boucle en if en disant que si non utf-8 iconv en UTF8
# comptage occurrences avec egrep "[G|g]eeks?" / egrep "[N|n]erds?" => 2 scripts pour chaque mot à chercher
#===============================================================================

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [ $# -ne 2 ]
then
	echo "ce programme demande 2 arguments"
	exit
fi

mot="[Gg]eeks?"

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)

echo "<html><head>
	<meta charset=\"UTF-8\" />
	<title> tableau URL </title>
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">
	<body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table class=\"table is-bordered is-hoverable is-striped\">" >> $fichier_tableau
echo "<tr><th>ligne</th><th>code</th><th>encodage</th><th>URL</th></tr><th>dump html</th><th>dump text</th><th>occurrences</th><th>concordances</th></tr>" >> $fichier_tableau 


lineno=1;
while read -r URL; do
echo -e "\tURL : $URL";
	
	#marche aussi : code=$(curl -I -s $line |head -n1|awk '{print $2}')
	code=$(curl -I -s $line |head -n1|cut -f 2 -d ' ')
	encodage=$(curl -I -s $line |egrep "charset"|cut -f2 -d'=')
	
	echo -e "\tcode : $code";
	
	if [[ ! $encodage ]]
	then
		echo -e "\tencodage non détécté, on prendra UTF-8 par défaut.";
		encodage="UTF-8";
	else
		echo -e "\tencodage : $encodage";
	fi
	
	if [[$code -eq 200]]
	then 
		dump=$ (lunx -dump -nolist -assume_charset=$encodage -display_charset=$encodage $URL)
		if [[$encodage -ne "UTF-8" && -n "$dump"]] #récupération du dump texte du site avec lynx
		then
			dump=$(echo $dump | iconv -f $encodage -t UTF-8//IGNORE) #Si l'encodage n'est pas de l'UTF-8 il faut faire une conversion La variable $encodage sera l'encodage de départ du fichier comme ça on est sûrs de partir d'où il faut.
		fi
else
	echo -e "\tcode différent de 200 utilisation d'un dump vide"
	dump=""
	encodage=""
fi					
	
echo "$dump" > "./dumps-text/fich-$lineno.txt" # le text brut de chaque URL est copié dans des fichiers situés dans le dossier dumps-text
	
NB_OCC=$(grep -E -o $mot ./dumps-text/fich-$lineno.txt | wc -l)
	
grep -E -A2 -B2 $mot ./dumps-text/fich-$lineno.txt > ./contextes/fich-$lineno.txt
bash programmes/concordance.sh ./dumps-text/fich-$lineno.txt $mot >concordances/fich-$lineno.html
	
	echo "<tr><td>$lineno </td><td>$code</td><td>$encodage</td><td><a href=\"$URL\">$URL</a></td><td><a href = "../ aspirations/fich-$lineno.html">html<a/></td><td><a href="../dumps-text/fich-$lineno.txt">text</a></td><td>$NB_OCC</td><td><a href="../contextes/fich-$lineno.txt">contextes</a></td><td><a href="../concordances/fich-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau	
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls

echo "</tbable>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau

