#!/bin/bash


#########################################################################

### Log Function ###
#
log() {
    echo "`date +"%b %e %H:%M:%S"` S01[$$]:" $* | tee -a $LOG_FILE
}


help(){
  echo "Help usage: rot13.sh encode options"
  echo ""
  echo "OPTIONS: "
  echo "    -h --help to displays HELP usage"
  echo "    -m --message the message to encode or to decode"
  echo "    -v --verbose to debug logs"

  echo "Examples "
  echo "Run:"
  echo "    bash ./rot13.sh encode --message abcd to encrypt the message with Rot13"
  echo "    bash ./rot13.sh decode --message nopq to decrypt the message with Rot13"

  #exit()
}



# Fonction de parsing des arguments
parse_args() {
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
                ;;
        esac
    done

    # Vérification des arguments obligatoires
    if [[ -z "$ACTION" || -z "$MESSAGE" ]]; then
        echo "Erreur: Action (encode/decode) et message sont obligatoires."
        help
    fi
}


encode() {
    local input_letter=$1

    # Déclaration du tableau contenant les 26 lettres de l'alphabet
    alphabet=( {a..z} )

    # Recherche de l'index de la lettre entrée
    for i in "${!alphabet[@]}"; do
        if [[ "${alphabet[i]}" == "$input_letter" ]]; then
            # Vérification si on est à la dernière lettre
            if [[ $i -eq 25 ]]; then
                echo "${alphabet[0]}"  # Boucle vers 'a' si l'entrée est 'z'
            else
                echo "${alphabet[i+1]}"
            fi
            return
        fi
    done

    # Si la lettre n'est pas trouvée, afficher un message d'erreur
    echo "Erreur : Veuillez entrer une lettre minuscule de a à z."
	exit(1)
}

#########################################################################

echo "Have you read carefully the README file ?[Y/N]: "
read READ_CHECK
echo ""

# bash setEnv.sh

if [ "${READ_CHECK}" = 'y' ] || [ "${READ_CHECK}" = 'Yes' ]; then

	log TP02 START

	read args
	main(args)
	
	log TP02 END
	
else
	echo "You should read carefully the README file ... "
fi


# exit $?
