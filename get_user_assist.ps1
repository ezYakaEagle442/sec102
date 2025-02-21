# Paramètres
$OutputFile = "userassist.txt"
$RegPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"

# Assurer que le fichier est vide ou créé s'il n'existe pas
if (Test-Path $OutputFile) {
    Clear-Content $OutputFile  # Efface le contenu du fichier s'il existe déjà
} else {
    New-Item -Path $OutputFile -ItemType File
}

# Récupérer les GUID et traiter les sous-clés 'Count'
Get-ChildItem -Path $RegPath | ForEach-Object {
    $guidKey = $_.PSChildName
    $countPath = "$RegPath\$guidKey\Count"  # Chemin complet de la sous-clé 'Count'

    # Write-Host "countPath : $countPath"

    if (Test-Path $countPath) {
        $countValues = Get-ItemProperty -Path $countPath -ErrorAction SilentlyContinue
        if ($countValues -ne $null) {
            foreach ($property in $countValues.PSObject.Properties) {
                # Write-Host "Nom de la propriété : $($property.Name)"
                # Write-Host "Valeur de la propriété : $($property.Value)"
                Add-Content -Path $OutputFile -Value $($property.Name)

                if ($property.Name -ne 'PSPath' -and $property.Name -ne 'PSParentPath' -and
                    $property.Name -ne 'PSChildName' -and $property.Name -ne 'PSDrive' -and
                    $property.Name -ne 'PSProvider') {
                    
                    $value = $property.Value
                    
                    if ($value -is [byte[]]) {
                        # Si la valeur est binaire, la convertir en base64
                        $base64Value = [Convert]::ToBase64String($value)
                        # Write-Host "Valeur binaire convertie en base64 ajoutée au fichier."
                        #Add-Content -Path $OutputFile -Value $base64Value  # Ajoute la valeur en base64 au fichier
                    } elseif ($value -is [string] -and ![string]::IsNullOrEmpty($value)) {
                        # Write-Host "Valeur chaîne ajoutée au fichier : $value"
                        # Add-Content -Path $OutputFile -Value $value  # Ajoute la valeur au fichier
                    } else {
                        Write-Host "La valeur récupérée est vide ou n'est pas une chaîne ou binaire."
                    }
                }
            }
        } else {
            # Write-Host "Aucune valeur trouvée dans la sous-clé 'Count' pour la clé GUID : $guidKey"
        }
    } else {
        Write-Host "La sous-clé 'Count' n'existe pas pour la clé GUID : $guidKey"
    }
}

# Vérification de la réussite
if (Test-Path $OutputFile) {
    $fileContent = Get-Content $OutputFile
    if ($fileContent.Length -gt 0) {
        Write-Host "Fichier '$OutputFile' créé/ajouté avec succès!"
        # Write-Host "Contenu du fichier :"
        #Write-Host $fileContent
    } else {
        Write-Host "Le fichier '$OutputFile' est vide."
    }
} else {
    Write-Host "Le fichier '$OutputFile' n'existe pas."
    exit 1
}