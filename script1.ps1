#choix du dossier contenant les fichiers à archiver
$dossier1 = Get-ChildItem C:\Dossier1
#dossier d'archivage
$dossier2 = Get-ChildItem C:\Dossier2
#boucle parcourant le dossier 1
foreach ($file in $dossier1)
{
    #on copie les fichiers du dossier dans un dossier ou ils seront archivés
    Copy-Item $file.PSPath $dossier2
}
#boucle parcourant le dossier 2
foreach ($file in $dossier2)
{
    #on récupère les éléments nécessaires
    $nom = $file.BaseName
    $ext = $file.Extension
    #on recup la date de derniere modif
    $datemodif = (Get-Item $file.PSPath).LastWriteTime
    #nouveau nom
    $nouveau_nom = $nom + $datemodif + $ext
    #on renomme le fichier
    Rename-Item $file.PSPath $nouveau_nom
}