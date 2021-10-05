param ($Add,$folder)

IF ($folder -eq $null) { $folder=get-item "." }

if (($Add)-and($Add.ToUpper() -match "/LIST")) { $Add=$False; $Verify=$False}
Elseif  ($Add) {
  Write-host "Les paramètres autorisés sont /LIST suivi du dossier facultatif"
  Break
}

#$domsid=(Get-ADdomain).domainsid.tostring()
$domName=(Get-ADdomain).Name.tostring()

# Liste des fonctions

function showPerms($fold) {
$f=get-item $fold
#write-output "*** TRAITEMENT DOSSIER $f ***"
$x=[System.Security.AccessControl.DirectorySecurity](get-ACL $f)
$mod=$false
  foreach ($i in $x.access) {
#  echo $i.identityReference
    if ($i.isinherited -eq $false){
        $ch=$i.identityReference.value.tostring()
        $Write = $i.FileSystemRights
        $Inheri = $i.InheritanceFlags
        $Propag =  $i.PropagationFlags
        $Access = $i.AccessControlType
        write-output "$ch;$write;$Inheri;$Propag;$access;$f"   
    } # if
  } # foreach
} # funct

Function RecurseFolder($fold)
{
  $f=$fold
#($_.name -notlike ".*")-and
  $ListFold=get-childitem $f -force |where {($_.mode -like "*d*")-and($_.name -notlike ".*")-and ($_.name -notlike "~*") }
  if ($listFold) {
    foreach ($e in $ListFold){
#	  ECHO $e.name
	  if (( $e.name -notlike "Network Trash Folder") -and ($e.name -notlike "TheFindByContentFolder") -and ($e.name -notlike "TheVolumeSettingsFolder")){
	    $FD=$e.fullname
        ShowPerms $FD     
	  }
    }
    foreach ($e in $ListFold){ RecurseFolder($e.fullname) }
  }
}

# Début du programme
write-output "Compte;Ecriture;Héritage;Propagation;Accès;Dossier"   

ShowPerms($Folder)
RecurseFolder($Folder)
