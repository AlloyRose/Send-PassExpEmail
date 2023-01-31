function Send-PassExpEmail{
[cmdletbinding()]
param()

import-module ActiveDirectory


$users = get-aduser -filter {(ObjectClass -eq 'user') -AND (Enabled -eq $true) -AND (PasswordNeverExpires -eq $false)} -Property passwordlastset, mail | 
         Where-Object {if ($_.passwordlastset){$_.passwordlastset.toshortdatestring() -eq (get-date).adddays(-88).ToShortDateString()}} | select -expand mail 

try{
    if(get-childitem -path "C:\User\$env:USERNAME\Documents\PassLogs" -ErrorAction Stop){break}
}catch [System.Management.Automation.ItemNotFoundException]{
    new-item -ItemType directory -path "C:\Users\$env:USERNAME\Documents" -name 'PassLogs' -ErrorAction SilentlyContinue | out-null
    }

"`n`n------Script started on $((get-date).ToShortDateString())------`n" | out-file -FilePath "C:\users\$env:username\documents\PassLogs\log.txt" -append 

$users | foreach-object {
        
        $MailParam = @{'smtpserver' = "servername"
                       'From'       = 'email@domain.com'
                       'To'         = $_
                       'Subject'    = 'Password Will Expire in 2 Days' 
                       'Body'       = "Please change it. Thanks." 
                       'BodyAsHtml' = $true
                       'Priority'   = 'High'
                       'Cc'        = 'email@domain.com'
                       'ErrorAction'= 'SilentlyContinue'}
      
        
        Send-MailMessage @MailParam
        
        $_ | out-file -FilePath "C:\users\$env:username\documents\PassLogs\log.txt" -append 

    }

}