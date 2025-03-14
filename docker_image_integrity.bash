#!/bin/bash

# Fichier contenant la liste des images
image_list_file="images_list.txt"

curl -k https://registry.community.greenbone.net/v2/_catalog | jq -r '.repositories[]' > $image_list_file


# Vérifier si le fichier existe
if [[ ! -f "$image_list_file" ]]; then
    echo "Le fichier $image_list_file n'existe pas."
    exit 1
fi

# Lire chaque ligne du fichier
while IFS= read -r image; do
    # Construire l'URL du manifeste
    manifest_url="https://registry.community.greenbone.net/v2/$image/manifests/stable"

    echo "Récupération du manifeste pour l'image : $image"
    # Exécuter la commande curl pour obtenir les en-têtes du manifeste
    curl -k -I -s "$manifest_url" | grep "docker-content-digest: sha256:"

    # Vérifier le code de retour de curl
    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de la récupération du manifeste pour l'image : $image"
    fi

    echo "----------------------------------------"
done < "$image_list_file"