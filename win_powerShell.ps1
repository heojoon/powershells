#
#  Disk Usage Report v0.1
#
# 
#  *** Usage Decription
#  This is Windows PowerShell Script.
#  Windows Drive  Usage Report, INPUT drive name (ex. C , D).
#
#  powershell -noprofile -ExecutionPolicy bypass -file .\diskCheck.ps1 ${DRIVE}
#


function diskReport($x) {
    $var = $x
    $Disk = Get-PSDrive $var
    $Disk_root = $Disk.Root

    $Total = ( $Disk.Used + $Disk.Free )
    $Usage = ( $Disk.Used / $Total ) * 100

    $Usage = [Math]::Round($Usage,2)
    $Total = $Total / 1GB 
    $Total = [Math]::Round($Total,2)
    $Used = $Disk.Used / 1GB 
    $Used = [Math]::Round($Used,2)
    $Free = $Disk.Free / 1GB 
    $Free = [Math]::Round($Free,2)

    $RptList_disk = @{ Used = "$Used"; Free = "$Free"  ; Total = "$Total" ; usage = "$Usage" }
    $a = ($RptList_disk.Used)
    $b = ($RptList_disk.Free)
    $c = ($RptList_disk.Total)
    $d = ($RptList_disk.usage)

    # Display Report result
    write-host "------------------------------"
    write-host "   DISK : $Disk_root   "
    write-host "------------------------------"
    write-host " - Used  : $a GB"
    write-host " - Free  : $b GB"
    write-host " - Total : $c GB"
    write-host " - Usage : $d %"
}


diskReport $Args[0]
