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
$path_dir1 = Get-Item "F:\Stage\test1"
$path_dir2 = Get-Item "F:\Stage\test2"

#chemin des dossiers d'archive (dans le dossier destination)
$path_archive_dir1 = Get-Item "F:\Stage\test1\Archive"
$path_archive_dir2 = Get-Item "F:\Stage\test2\Archive"

#contenu des dossiers destination (fichiers uniquement, pas d'archivage de dossiers)
$dir1 = Get-ChildItem "F:\Stage\test1" -File
$dir2 = Get-ChildItem "F:\Stage\test2" -File

#chemin des fichiers à archiver (ajouter une ligne pour chaque fichier, sous le format indiqué en commentaire si-dessous
#$ficx = Get-Item ":\nomdufichier"
$fic1 = Get-Item "F:\Stage\test1 w.docx"
$fic2 = Get-Item "F:\Stage\test2w.docx"
$fic3 = Get-Item "F:\Stage\testp.odp"
$fic4 = Get-Item "F:\Stage\testx.xlsx"

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
$tab2 = @($fic1, $fic2<#,ficx#>)

#boucle pour le dossier 1
#pour chaque item dans le tableau, soit chaque fichier
foreach($item in $tab1)
{
    #saisit le nom du fichier et la date de derniere modif
    $base_name1 = $item.BaseName
    $name1 = $item.Name
    $datemodif1 = (Get-Item $item.PSPath).LastWriteTime
    #pour chaque fichier dans le dossier (boucle qui parcours les fichiers copiés dans le 
    #dossier d'archivage (à ne pas confondre avec le dossier "Archive" qui contient les dossiers datés)
    foreach ($file in $dir1)
    {
        #saisit le nom du fichier et la date de derniere modif
        $base_name2 = $file.BaseName
        $name2 = $file.Name
        $datemodif2 = (Get-Item $file.PSPath).LastWriteTime
        #ajoute le nom du fichier au tableau des noms afin de pouvoir vérifier plus tards si
        #le fichier est ajouté pour la première fois ou non
        if($tab11 -notcontains $name2)
        {$tab11 += @($name2)}
        #si le fichiers séléctionné par la boucle principale est le même que celui séléctionné par la boucle secondaire
        if($name1 -eq $name2)
        {
            #vérifie si les dates de derniere modification sont les mêmes
            if($datemodif1 -eq $datemodif2)
            {
                #si oui le fichier est à jour
                Write-Host $name1 "deja à jour (dossier 1)"
            }
            elseif($datemodif1 -ne $datemodif2)
            {
                #si non le fichier est mis à jour
                #assemblage du nom archivé
                $ext = $item.Extension
                #on reprend la date de dernière modification, cette fois en string afin de ne pas avoir de probleme de
                #format lorsque le fichier est renommé
                $datemodif = (Get-Item $file.PSPath).LastWriteTime.ToString("-hh-mm-dd-MM-yyyy")
                $datenom = $base_name1 + $datemodif
                #nom final
                $newname = $datenom + $ext
                #assemblage du path
                $path = "$path_archive_dir1\$newname"
                #on coupe/colle le fichier dans le dossier "Archive" tout en modifiant le nom
                Move-Item $file.PSPath "$path_archive_dir1\$newname"
                #on copie le fichier  jour dans le dossier d'archivage à la place du précédent
                Copy-Item $item.PSPath $path_dir1
                Write-Host $name1 "mis à jour (dossier 1)"
            }
        }
    }
    #vérifie cette condition si le fichier est ajouté pour la première fois, car le nom n'est pas présent dans le tableau
    if($tab11 -notcontains $name1)
    {
        Copy-Item $item.PSPath $path_dir1
        Write-Host $name1 "copié pour la premiere fois (dossier 1)"
    }
}

#boucle pour le dossier 2, similaire au dossier 1
foreach($item in $tab2)
{
    $base_name1 = $item.BaseName
    $name1 = $item.Name
    $datemodif1 = (Get-Item $item.PSPath).LastWriteTime
    foreach ($file in $dir2)
    {
        $base_name2 = $file.BaseName
        $name2 = $file.Name
        $datemodif2 = (Get-Item $file.PSPath).LastWriteTime
        if($tab22 -notcontains $name2)
        {$tab22 += @($name2)}
        if($name1 -eq $name2)
        {
            if($datemodif1 -eq $datemodif2)
            {
                Write-Host $name1 "deja à jour (dossier 2)"
            }
            elseif($datemodif1 -ne $datemodif2)
            {
                $ext = $item.Extension
                $datemodif = (Get-Item $file.PSPath).LastWriteTime.ToString("hh-mm-dd-MM-yyyy")
                $datenom = $base_name1 + $datemodif
                #nom final
                $newname = $datenom + $ext
                #on copie le fichier tout en modifiant le nom
                $path = "$path_archive_dir2\$newname"
                Move-Item $file.PSPath "$path_archive_dir2\$newname"
                Copy-Item $item.PSPath $path_dir2
                Write-Host $name1 "mis à jour (dossier 2)"
            }
        }
    }
    if($tab22 -notcontains $name1)
    {
        Copy-Item $item.PSPath $path_dir2
        Write-Host $name1 "copié pour la premiere fois (dossier 2)"
    }
}