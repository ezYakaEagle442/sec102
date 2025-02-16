#!/bin/bash

#########################################################################

### Functions ###

log() {
    echo "`date +"%b %e %H:%M:%S"` S01[$$]:" $* | tee -a $LOG_FILE
}

help() {
  echo "Help usage: bash ./rot13.sh encode options"
  echo ""
  echo "OPTIONS: "
  echo "    -h --help to displays HELP usage"
  echo "    -m --message the message to encode or to decode"
  echo "    -v --verbose to debug logs"

  echo ""  
  echo "Examples "
  echo ""  
  echo "Run:"
  echo ""  
  echo "    bash ./rot13.sh encode --message abcd to encrypt the message with Rot13"
  echo "    bash ./rot13.sh decode --message nopq to decrypt the message with Rot13"

  #exit 0
}

# Fonction de parsing des arguments
main() {
    log main START

    local POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                help
                ;;
            -m|--message)
                MESSAGE="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            encode|decode)
                ACTION="$1"
                shift
                ;;
            *)
                echo "Erreur: Option inconnue '$1'"
                help
                exit 1
                ;;
        esac
    done

    # Vérification des arguments obligatoires
    if [[ -z "$ACTION" || -z "$MESSAGE" ]]; then
        echo "Erreur: Action (encode/decode) et message sont obligatoires."
        help
        exit 1
    fi

    if [[ "$ACTION" == "encode" ]]; then

        local encoded_word=""
        encoded_word=$(encode "$MESSAGE")  # Stocker la valeur retournée
        echo "Mot chiffré: $encoded_word"
        echo ""

        if [[ -z "$encoded_word" ]]; then
            echo "Erreur d'encodage pour le mot '$MESSAGE'"
            exit 1
        fi

    else
        if [[ "$ACTION" == "decode" ]]; then
            local decoded_word=""
            decoded_word=$(decode "$MESSAGE")  # Stocker la valeur retournée
            echo "Mot déchiffré: $decoded_word"
            echo ""

            if [[ -z "$decoded_word" ]]; then
                echo "Erreur de décodage pour le mot '$MESSAGE'"
                exit 1
            fi
        fi
    fi

    log main END
}

encode() {
    # log encode START
    local input_word=$1

    # Déclaration du tableau contenant les 26 lettres de l'alphabet
    alphabet=( {a..z} )

    # abcdefghijklm nopqrstuvwxyz
    # nopqrstuvwxyz abcdefghijklm
    # donc a ==> n et n==> a
    rot13_alphabet=( {n..z} {a..m} )

    # Parcours de chaque lettre du mot en entrée
    for (( i=0; i<${#input_word}; i++ )); do
        letter="${input_word:i:1}"  # Extraire une lettre du mot

        # Si le caractère est un espace, on le conserve
        if [[ "$letter" == " " ]]; then
            encoded_word+=" "  # Ajouter un espace à la phrase encodée
            continue
        fi

        # Sauvegarder la casse d'origine de la lettre
        is_uppercase=false
        if [[ "$letter" =~ [A-Z] ]]; then
            letter="${letter,,}"  # Convertir en minuscule
            is_uppercase=true
        fi

        # Si la lettre est dans l'alphabet
        if [[ "$letter" =~ [a-z] ]]; then
            # Recherche de l'index de la lettre dans l'alphabet
            for j in "${!alphabet[@]}"; do
                if [[ "${alphabet[j]}" == "$letter" ]]; then
                    local encoded_letter="${rot13_alphabet[j]}"
                    # Restaurer la casse majuscule si nécessaire
                    if $is_uppercase; then
                        encoded_letter="${encoded_letter^^}"
                    fi
                    encoded_word+="$encoded_letter"
                    break  # Sortir de la boucle dès que la lettre est trouvée
                fi
            done
        else
            encoded_word+="$letter"
        fi
    done
    # log encode END
    echo $encoded_word
}

decode() {
    # log decode START

    local input_word=$1
    # log paramètres en entrée: "$input_word"

    # Déclaration du tableau contenant les 26 lettres de l'alphabet
    alphabet=( {a..z} )

    # nopqrstuvwxyz abcdefghijklm
    # abcdefghijklm nopqrstuvwxyz
    # donc n ==> a et a==> n
    rot13_alphabet=( {n..z} {a..m} )

    # Initialisation de la variable pour stocker le mot déchiffré
    local decoded_word=""

    # Parcourir chaque lettre du mot en entrée
    for (( i=0; i<${#input_word}; i++ )); do
        local letter="${input_word:$i:1}"

        # Si le caractère est un espace ou un symbole, on le conserve tel quel dans la phrase déchiffrée
        if [[ "$letter" == " " || "$letter" =~ [^a-zA-Z] ]]; then
            decoded_word+="$letter"
            continue
        fi

        # Sauvegarder la casse d'origine de la lettre
        local is_uppercase=false
        if [[ "$letter" =~ [A-Z] ]]; then
            letter="${letter,,}"  # Convertir en minuscule pour le traitement
            is_uppercase=true
        fi

        # Recherche de l'index de la lettre dans l'alphabet
        for j in "${!rot13_alphabet[@]}"; do
            if [[ "${rot13_alphabet[j]}" == "$letter" ]]; then
                local decoded_letter="${alphabet[j]}"
                
                # Restaurer la casse majuscule si nécessaire
                if $is_uppercase; then
                    decoded_letter="${decoded_letter^^}"
                fi
                
                decoded_word+="$decoded_letter"
                break
            fi
        done
    done

    # Afficher le mot déchiffré
    # log decode END
    echo "$decoded_word"

}

get_ua_cmd() {

    log get_ua START

    REG_PATH="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"

    # Query the registry
    KEYS=$(cmd.exe /c "reg query \"$REG_PATH\ /s" 2>/dev/null | tr -d '\r')
    echo "$KEYS"

    log get_ua END
}

get_ua_psh() {
#   C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#	C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#		==> then run ISE
#		==> run Get-ExecutionPolicy to check the "Bypass" is enabled
#
#       $REG_PATH="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
#       Get-ChildItem -Path "$REG_PATH" | ForEach-Object { $_.Name } | ForEach-Object { Add-Content -Path 'userassist.txt' -Value $_ }

    log get_ua_psh START

    # REG_PATH="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
    REG_PATH="Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
    powershell.exe -Command "Get-ChildItem -Path '$REG_PATH' -Recurse | ForEach-Object { \$_.Name } | ForEach-Object { Add-Content -Path 'userassist.txt' -Value \$_ }"

    # Vérification si le fichier a été créé
    if [ -f "userassist.txt" ]; then
        log "Fichier créé avec succès!"
    else
        log "Échec de la création du fichier."
    fi

    decode_ua_file userassist.txt

    log get_ua_psh END
}

decode_ua_file() {

    log decode_ua_file START
    # REG_PATH="Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"

    while IFS= read -r line; do
        #echo "Ligne lue : $line"
        decoded_key_val=$(decode "$line")
        #echo "key $decoded_key_val"
        echo $decoded_key_val >> decode_userassist.txt
    done < "$1"

    log decode_ua_file END
}


#########################################################################

echo "Have you read carefully the README file ?[Yes/No]: "
read READ_CHECK
echo ""

# bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log TP02 START
    #help
	
    # TP2
    #main "$1" "$2" "$3"
    
    # TP3
    get_ua_psh
	
    log TP02 END
	
else
	echo "You should read carefully the README file ... "
fi

exit $?