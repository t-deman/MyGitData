param ($Remove,$folder)

IF ($folder -eq $null) { $folder=get-item "." }
if (($Remove)-and($Remove.ToUpper() -match "/LIST")) { $Remove=$False }
if (($Remove)-and($Remove.ToUpper() -match "/REMOVE")) { $Remove=$True }
Elseif  ($Remove) {
  Write-host "Les paramètres autorisés sont /LIST ou /REMOVE suivi du dossier facultatif"
  Break
}

$domsid=(Get-ADdomain).domainsid.tostring()

# Liste des fonctions

function RemovePerms($fold) {
$f=get-item $fold
write-output $f.fullname
$x=[System.Security.AccessControl.DirectorySecurity](get-ACL $f)
$mod=$false
foreach ($i in $x.access) {
  if ($i.identityReference.value.tostring() -like "$domsid*"){
    $d=$i.identityReference.value.tostring()
    echo "Suppression de $d"
    if ($Remove) { $x.RemoveAccessRuleSpecific($i) ; $Mod=$True}
    }
  }
#  echo $x.access
if ($mod){ Set-ACL -aclobject $x -path $f }
}

Function RecurseFolder($fold)
{
  $f=$fold
  $ListFold=get-childitem $f -force |where {$_.mode -like "*d*" }
  foreach ($e in $ListFold){
     $FD=$e.fullname
     RemovePerms $FD     
  }
 
  foreach ($e in $ListFold){ RecurseFolder($e.fullname) }
}

# Début du programme

RemovePerms($Folder)
RecurseFolder($Folder)

