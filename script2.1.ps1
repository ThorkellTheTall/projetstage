﻿#Pensez à permettre à Windows d'exécuter le script ps1
#Utilisez : Set-ExecutionPolicy RemoteSigned (en mode Administrateur)
#Attention : l'arborescence complète doit exister (s'il manque un dossier les fichiers ne se copieront pas)

#déclaration des tableaux qui permettront de stocker tous les chemins des fichiers
#pour la boucle/dossier 1
$tab1 = @()
#pour la boucle/dossier 2
$tab2 = @()

#déclaration des tableaux qui permettront de stocker tous les noms des fichiers
#pour la boucle/dossier 1
$tab11 = @()
#pour la boucle/dossier 2
$tab22 = @()

#chemin des dossiers destination
$path_dir1 = Get-Item "D:\Test1"
$path_dir2 = Get-Item "D:\Test2"

#chemin des dossiers d'archive (dans le dossier destination)
$path_archive_dir1 = Get-Item "D:\Test1\Archive"
$path_archive_dir2 = Get-Item "D:\Test2\Archive"

#contenu des dossiers destination (fichiers uniquement, pas d'archivage de dossiers)
$dir1 = Get-ChildItem "D:\Test1" -File
$dir2 = Get-ChildItem "D:\Test2" -File

#chemin des fichiers à archiver (ajouter une ligne pour chaque fichier, sous le format indiqué en commentaire si-dessous
#$ficx = Get-Item ":\nomdufichier"
$fic1 = Get-Item "C:\Users\migu8056\Desktop\Documentation Keepass.docx"
$fic2 = Get-Item "C:\Users\migu8056\Desktop\Documentation Keepass.pdf"
$fic3 = Get-Item "C:\Users\migu8056\Desktop\guide_achats_informatiques_juin_2019.pdf"
$fic4 = Get-Item "C:\Users\migu8056\Desktop\Mémo_recherche_messages.pdf"

#format pour rajouter un dossier d'archivage en plus
<#
Placer les différentes déclaration ci-dessous au début du code à leurs emplacements respectifs
$tabx = @()
$tabxx = @()
$path_dirx = Get-Item ":\dossier"
$path_archive_dirx = Get-Item ":\dossier\Archive"
$dirx = Get-ChildItem ":\dossier -File"
$tabx = @($ficx, ...)
Puis ajouter une boucle similaire à celles en dessous en modifiant respectivement les differents nom de variables
#>

#ajout des fichiers au tableau, ajouter chaque fichier en plus dans la liste
$tab1 = @($fic1, $fic2, $fic3, $fic4<#,ficx#>)
$tab2 = @($fic1, $fic4<#,ficx#>)

#boucle pour le dossier 1
#pour chaque item dans le tableau, soit chaque fichier
foreach($item in $tab1)
{
    #saisit le nom du fichier et la date de derniere modif
    $nom1 = $item.BaseName
    $datemodif1 = (Get-Item $item.PSPath).LastWriteTime
    #pour chaque fichier dans le dossier (boucle qui parcours les fichiers copiés dans le 
    #dossier d'archivage (à ne pas confondre avec le dossier "Archive" qui contient les dossiers datés)
    foreach ($file in $dir1)
    {
        #saisit le nom du fichier et la date de derniere modif
        $nom2 = $file.BaseName
        $datemodif2 = (Get-Item $file.PSPath).LastWriteTime
        #ajoute le nom du fichier au tableau des noms afin de pouvoir vérifier plus tards si
        #le fichier est ajouté pour la première fois ou non
        $tab11 += @($nom2)
        #si le fichiers séléctionné par la boucle principale est le même que celui séléctionné par la boucle secondaire
        if($nom1 -eq $nom2)
        {
            #vérifie si les dates de derniere modification sont les mêmes
            if($datemodif1 -eq $datemodif2)
            {
                #si oui le fichier est à jour
                Write-Host $nom1 "deja à jour (dossier 1)"
            }
            else
            {
                #si non le fichier est mis à jour
                #assemblage du nom archivé
                $ext = $item.Extension
                #on reprend la date de dernière modification, cette fois en string afin de ne pas avoir de probleme de
                #format lorsque le fichier est renommé
                $datemodif = (Get-Item $file.PSPath).LastWriteTime.ToString("-hh-mm-dd-MM-yyyy")
                $datenom = $nom1 + $datemodif
                #nom final
                $newname = $datenom + $ext
                #assemblage du path
                $path = "$path_archive_dir1\$newname"
                #on coupe/colle le fichier dans le dossier "Archive" tout en modifiant le nom
                Move-Item $file.PSPath "$path_archive_dir1\$newname"
                #on copie le fichier  jour dans le dossier d'archivage à la place du précédent
                Copy-Item $item.PSPath $path_dir1
                Write-Host $nom1 "mis à jour (dossier 1)"
            }
        }
    }
    #vérifie cette condition si le fichier est ajouté pour la première fois, car le nom n'est pas présent dans le tableau
    if($tab11 -notcontains $nom1)
    {
        Copy-Item $item.PSPath $path_dir1
        Write-Host $nom1 "copié pour la premiere fois (dossier 1)"
    }
}

#boucle pour le dossier 2, similaire au dossier 1
foreach($item in $tab2)
{
    $nom1 = $item.BaseName
    $datemodif1 = (Get-Item $item.PSPath).LastWriteTime
    foreach ($file in $dir2)
    {
        $nom2 = $file.BaseName
        $datemodif2 = (Get-Item $file.PSPath).LastWriteTime
        $tab22 += @($nom2)
        if($nom1 -eq $nom2)
        {
            if($datemodif1 -eq $datemodif2)
            {
                Write-Host $nom1 "deja à jour (dossier 2)"
            }
            else
            {
                $ext = $item.Extension
                $datemodif = (Get-Item $file.PSPath).LastWriteTime.ToString("hh-mm-dd-MM-yyyy")
                $datenom = $nom1 + $datemodif
                #nom final
                $newname = $datenom + $ext
                #on copie le fichier tout en modifiant le nom
                $path = "$path_archive_dir2\$newname"
                Move-Item $file.PSPath "$path_archive_dir2\$newname"
                Copy-Item $item.PSPath $path_dir2
                Write-Host $nom1 "mis à jour (dossier 2)"
            }
        }
    }
    if($tab22 -notcontains $nom1)
    {
        Copy-Item $item.PSPath $path_dir2
        Write-Host $nom1 "copié pour la premiere fois (dossier 2)"
    }
}
