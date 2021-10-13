param ($Add,$folder)

IF ($folder -eq $null) { $folder=get-item "." }
IF ($Add -eq $null) { $add=$False }

if (($Add)-and($Add.ToUpper() -match "/LIST")) { $Add=$False; $Verify=$False}
if (($Add)-and($Add.ToUpper() -match "/ADD")) { $Add=$True; $Verify=$False}
if (($Add)-and($Add.ToUpper() -match "/VERIFY")) { $Add=$False; $Verify=$True}

Elseif  ($Add) {
  Write-host "Les paramètres autorisés sont /LIST, /ADD ou /VERIFY suivi du dossier facultatif"
  Break
}

#$domsid=(Get-ADdomain).domainsid.tostring()
#$domName=(Get-ADdomain).Name.tostring()
# Indidate the source DOMAIN
$DomName="NETBIOSSourceDomain"
# Indicate the target DMOMAIN
$domNameAdd="NetbiosTargetDomain"

$TargetDomainController="NameDC.Domain.Extension"

#if ($Verify){ $cred=get-credential }

# Liste des fonctions

function AddPerms($fold) {
$f=get-item $fold
write-output "*** TRAITEMENT DOSSIER $f ***"
$x=[System.Security.AccessControl.DirectorySecurity](get-ACL $f)
$mod=$false
  foreach ($i in $x.access) {
#  echo $i.identityReference
    if ($i.isinherited -eq $false){
  
      if ($i.identityReference.value.tostring() -like "$domName\*"){
        $ch=$i.identityReference.value.tostring()
  	    $tb=$ch.split("\")
        $Name=$tb[1] 
	    $sid="$domNameAdd\$Name"
		if ($Verify) {
		  $condition="samaccountname -eq "+"'" + "$name" +"'"
          $acc=get-adobject -filter "$condition" -properties ObjectSid -server "$TargetDomainController"
# -credential $cred
		  if (!$acc) {write-output "ERREUR sur $SID"}
         }
  #   echo "$d trouvé, ajout de $e"
        elseif ($Add) {
          $Write = $i.FileSystemRights
          $Inheri = $i.InheritanceFlags
          $Propag =  $i.PropagationFlags
          $Access = $i.AccessControlType
          $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Sid, $Write, $Inheri, $Propag, $Access) 
		
	      $Err=$False 
		  try {$x.AddAccessRule($rule)}
          catch { write-output "ERREUR sur $SID"; $Err=$True }
		  If (!$Err) {
    		$Mod=$True
		    write-output "COPIE DE DROITS POUR $sid DEPUIS $ch EFFECTUEE"
		    }
		  }
		  else { write-output "COPIE DE DROITS POUR $sid DEPUIS $ch (Aucune modification)"}   
		}
    }
#  echo $x.access
  } # ForEach
  if ($mod){ Set-ACL -aclobject $x -path $f }
} # function

Function RecurseFolder($fold)
{
  $f=$fold
  $ListFold=get-childitem $f -force |where {$_.mode -like "*d*" }
  if ($listFold) {
    foreach ($e in $ListFold){
       $FD=$e.fullname
       AddPerms $FD     
    }
    foreach ($e in $ListFold){ RecurseFolder($e.fullname) }
  }
}

# Début du programme

AddPerms($Folder)
RecurseFolder($Folder)
