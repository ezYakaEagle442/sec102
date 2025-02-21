#!/bin/bash

#########################################################################

### Functions ###

log() {
    # echo "`date +"%b %e %H:%M:%S"` S01[$$]:" $* | tee -a $LOG_FILE
    #echo "$(date +"%Y-%m-%dT%H:%M:%S.%N%:z") S01[$$]:" $* | tee -a "$LOG_FILE"
    # RSX112 S03: utiliser de préférence la RFC 3339
    echo "$(date --rfc-3339=ns) S01[$$]:" "$*" | tee -a "$LOG_FILE"
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
  echo "    bash ./rot13.sh get-hive to get the UserAssist registry Keys decrypted with ROT13"
  
  exit 0
}

# Fonction de parsing des arguments
main() {
    log main START
    echo ""

    # local POSITIONAL_ARGS=()

    while [[ $# -gt 0 ]]; do
        
        [[ -z "$1" ]] && break  # ⬅️ Évite d'entrer dans la boucle avec un argument vide pour le cas de get-hive

        case "$1" in
            -h|--help)
                help
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            encode|decode)
                ACTION="$1"
                shift
                ;;
            get-hive)
                ACTION="get-hive"
                shift
                ;;
            -m|--message)
                if [[ -n "$2" ]]; then
                    MESSAGE="$2"
                    shift 2
                else
                    echo "Erreur: L'option --message nécessite un argument."
                    exit 1
                fi
                ;;                
            *)
                echo "Erreur: Option inconnue '$1'"
                help
                exit 1
                ;;
        esac
    done

    if [[ "$ACTION" == "get-hive" ]]; then
        get_ua_psh
        echo ""
    # Vérification des arguments obligatoires
    elif  [[ -n "$ACTION" && -n "$MESSAGE" ]]; then

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
    else 
        echo "Erreur: Veuillez fournir une action valide encode|decode avec les arguments requis. ou bien l'action get-hive"
        help
        exit 1    
    fi

    log main END
}

#########################################################################
# Fonction d'encodage d'un mot avec ROT13
#########################################################################
encode() {
    # in 1 line bash: % echo 'Hello WORLD 2025 !' | tr 'A-Za-z' 'N-ZA-Mn-za-m'
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

#########################################################################
# Fonction de décodage d'un mot chiffré avec ROT13
#########################################################################
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

#########################################################################
# Call CMD to get the UserAssist registry keys
#########################################################################
get_ua_cmd() {

    log get_ua START

    REG_PATH="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"

    # Query the registry
    KEYS=$(cmd.exe /c "reg query \"$REG_PATH\ /s" 2>/dev/null | tr -d '\r')
    echo "$KEYS"

    log get_ua END
}

#########################################################################
# Call PowerShell to get the UserAssist registry keys
#########################################################################
get_ua_psh() {
#   C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#	C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit 
#		==> then run ISE
#		==> run Get-ExecutionPolicy to check the "Bypass" is enabled
#
#       $REG_PATH="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
#       Get-ChildItem -Path "$REG_PATH" | ForEach-Object { $_.Name } | ForEach-Object { Add-Content -Path 'userassist.txt' -Value $_ }

    log get_ua_psh START

    OUTPUT_FILE="userassist.txt"

    # Si le fichier n'existe pas, il faut le créer pour éviter toute erreur
    if [ ! -f "$OUTPUT_FILE" ]; then
        touch "$OUTPUT_FILE"
        log "Fichier '$OUTPUT_FILE' créé."
    fi

    # in bash: REG_PATH="Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
    REG_PATH="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
    # Utilisation de PowerShell pour récupérer les valeurs 'Count' des sous-clés
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "get_user_assist.ps1" -OutputFile "$OUTPUT_FILE" -RegPath "$REG_PATH"

    # Vérification si le fichier a été créé
    if [ -s "$OUTPUT_FILE" ]; then
        log "Fichier créé/ajouté avec succès!"
        decode_ua_file "$OUTPUT_FILE"
    else
        log "Échec de la création/écriture du fichier ou le fichier est vide."
        exit 1
    fi

    log get_ua_psh END
}

#########################################################################
# Decode the UserAssist registry keys
#########################################################################
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
# Main
#########################################################################

echo "Have you read carefully the README file ?[Yes/No]: "
read READ_CHECK
echo ""

# bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log TP02 START

    #help
	    
    main "$1" "$2" "$3"

    log TP02 END
	
else
	echo "You should read carefully the README file ... "
fi

exit $?