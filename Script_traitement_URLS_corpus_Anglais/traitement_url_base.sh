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
#===============================================================================
if [ $# -ne 2 ]
then
	echo "ce programme demande 2 arguments"
	exit
fi

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie



# modifier la ligne suivante pour créer effectivement du HTML
#echo "Je dois devenir du code HTML à partir de la question 3" > $fichier_tableau

lineno=1;

#while read -r line;
#do
#	echo "ligne $lineno: $line";
#	lineno=$((lineno+1));
#	header=$(curl -I -s $line |head -n1)
#	echo "l'entête est $header ";
#done < $fichier_urls 

# il faut maintenant rediriger les résultats dans le fichier tableau qui doit être un tableau HTML.
echo "<html>
	<header>
<meta charset=\"UTF-8\" />
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@0.9.4/css/bulma.min.css">
<title>tableau</title>
</header>
<body>
<table class=\"table is-bordered is-hoverable is-striped\">
<tbody>
<tr><th>ligne</th><th>code</th><th>URL</th></tr>" >> $fichier_tableau
while read -r line;
do
	lineno=$((lineno+1));
	#header=$(curl -I -s $line |head -n1|awk '{print $2}')
	header=$(curl -I -s $line |head -n1|cut -f 2 -d ' ')
	echo "ligne $lineno: $line";
	echo "<tr><td>$lineno </td><td>$header </td><td><a href=\"$line\">$line</a></td></tr>" >> $fichier_tableau
done < $fichier_urls
echo "</tbody>
</table>
</body>
</html>" >> $fichier_tableau

	