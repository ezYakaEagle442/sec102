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
        for (( i=0; i<${#MESSAGE}; i++ )); do
            letter="${MESSAGE:i:1}"
            # log "Lettre $((i+1)) : $letter"
            result=$(encode "$letter")  # Stocker la valeur retournée
            echo "Lettre encodée: $result"

            if [[ -z "$result" ]]; then
                echo "Erreur d'encodage pour la lettre '$letter'"
                exit 1
            fi

            encoded_word+="$result"
        done

        echo "Mot chiffré: $encoded_word"

    else
        if [[ "$ACTION" == "decode" ]]; then
            local decoded_word=""
            for (( i=0; i<${#MESSAGE}; i++ )); do
                letter="${MESSAGE:i:1}"
                # log "Lettre $((i+1)) : $letter"
                result=$(decode "$letter")  # Stocker la valeur retournée
                echo "Lettre décodée: $result"

                if [[ -z "$result" ]]; then
                    echo "Erreur de décodage pour la lettre '$letter'"
                    exit 1
                fi

                decoded_word+="$result"
            done

            echo "Mot déchiffré: $decoded_word"
        fi
    fi

    log main END
}

encode() {
    #log encode START

    local input_letter=$1
    #log paramètres en entrée: "$input_letter"

    # Déclaration du tableau contenant les 26 lettres de l'alphabet
    alphabet=( {a..z} )

    # abcdefghijklm nopqrstuvwxyz
    # nopqrstuvwxyz abcdefghijklm
    # donc a ==> n et n==> a
    rot13_alphabet=( {n..z} {a..m} )

    # Recherche de l'index de la lettre entrée
    for i in "${!alphabet[@]}"; do
        if [[ "${alphabet[i]}" == "$input_letter" ]]; then
            local encoded_letter="${rot13_alphabet[i]}"
            #log encode END
            echo "$encoded_letter"
            return 0
        fi
    done

    # Si la lettre n'est pas trouvée, afficher un message d'erreur
    echo "Erreur : Veuillez entrer une lettre minuscule de a à z."
    log encode END
	exit 1
}

decode() {
    #log decode START

    local input_letter=$1
    #log paramètres en entrée: "$input_letter"

    # Déclaration du tableau contenant les 26 lettres de l'alphabet
    alphabet=( {a..z} )

    # nopqrstuvwxyz abcdefghijklm
    # abcdefghijklm nopqrstuvwxyz
    # donc n ==> a et a==> n
    rot13_alphabet=( {n..z} {a..m} )

    # Recherche de l'index de la lettre entrée
    for i in "${!rot13_alphabet[@]}"; do
        if [[ "${rot13_alphabet[i]}" == "$input_letter" ]]; then
            local decoded_letter="${alphabet[i]}"
            #log decode END
            echo "$decoded_letter"
            return 0
        fi
    done

    # Si la lettre n'est pas trouvée, afficher un message d'erreur
    echo "Erreur : Veuillez entrer une lettre minuscule de a à z."
    log decode END
	exit 1
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
    powershell.exe -Command "Get-ChildItem -Path '$REG_PATH' | ForEach-Object { \$_.Name } | ForEach-Object { Add-Content -Path 'userassist.txt' -Value \$_ }"

    # Vérification si le fichier a été créé
    if [ -f "userassist.txt" ]; then
        log "Fichier créé avec succès!"
    else
        log "Échec de la création du fichier."
    fi

    log get_ua_psh END
}


#########################################################################

echo "Have you read carefully the README file ?[Yes/No]: "
read READ_CHECK
echo ""

# bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log TP02 START
    #help
	main "$1" "$2" "$3"
	
    get_ua_psh

	log TP02 END
	
else
	echo "You should read carefully the README file ... "
fi


exit $?