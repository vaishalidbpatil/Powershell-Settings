function Send-Email {
    <#
    .Synopsis
        Sends an email.        
    .Description
        Sends an email, using exchange web services.        
        
    .Example
        $office365Credential = Get-SecureSetting -Name Office365Cred -Type ([Management.Automation.PSCredential])
        Send-Email -To "someone@somewhere.com" -Subject "Hello World" -Body "<b>Hello World</b>" -BodyAsHtml -IsOffice365Account -Credential $office365Credential 
    .Example
        $office365Credential = Get-SecureSetting -Name Office365Cred -Type ([Management.Automation.PSCredential])
        Send-Email -To "someone@somewhere.com" -Subject "Dinner:Free at Five?" -From "5PM" -To "6pm" -Location "Machiavelli's" -IsOffice365Account -Credential $office365Credential 
    .Link
        New-WebServiceProxy
    #>    
    [OutputType([Nullable],[Management.Automation.Job])]    
    param(            
    # The to address or addresses for the message
    [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $To,
    
    # The replyTo email address
    [Parameter(Position=0,ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $ReplyTo,
    
    # The path to any attachments
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('PsPath')]    
    [string[]]
    $Attachment,

    # Cc Addresses for the message
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $Cc,

    # The Bcc address for the message
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $Bcc,
    
    # The response type.  Used to send cancellations and acceptance.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $ResponseType,

    # The item class.  This parameter is set automatically in most cases, but can be used to send meeting cancellations or meeting accepts.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $ItemClass,

    # The body of the message
    [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
    [System.String]
    $Body,

    # If set, the body will be treated as HTML
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('BAH')]
    [Switch]
    $BodyAsHtml,

    # If set, will set the message encoding
    [Alias('BE')]
    [System.Text.Encoding]
    $Encoding,

    # Delivery Notification Options.  Automatically generates a response mail
    [Alias('DNO')]
    [System.Net.Mail.DeliveryNotificationOptions]
    $DeliveryNotificationOption,

    # The from parameter.  If not set, from will automatically be set by exchange to be the logged-on user.
    # Users can only send mail as a user once they have send permissions
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [System.String]
    $From,

    # The subject line for the message
    [Parameter(Position=1,ValueFromPipelineByPropertyName=$true)]
    [Alias('sub')]
    [System.String]
    $Subject,

    # The message sensitivity
    [string]
    [ValidateSet("Normal","Personal","Private","Confidential")]
    $Sensitivity = "Normal",
        
    # The category.  Any category can be used, but only the built-in categories are guaranteed to be color-coded in a client.
    # Built in categories have are named 'Color' Cateogry, for example, 'Blue Category' or 'Red Category'
    [System.String[]]
    $Category,
    
    # The end time of th meeting
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [DateTime]
    $Start,
    
    # The end time of the meeting.
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [DateTime]
    $End,
    
    # The location of the meeting
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $Location,

    # The Calender Identifier.  This is used to 
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $CalenderId,

    # If set, outputs the response object returned from the exchange web services    
    [switch]
    $PassThru,
    
    # The exchange server
    [string]$ExchangeServer,
    
    # The credential used to connect
    [Management.Automation.PSCredential]
    $Credential,
    
    # If set, will treat the account as an Office365 account
    [Switch]$IsOffice365Account,
    
    # If set, will use the trio of web.config values for the connection:
    # - ExchangeServer, ExchangeUserName, ExchangePassword
    [Switch]
    $UseWebConfiguration,
    
    # If set, will create the email in a background job
    [Switch]
    $AsJob
    )
    
    begin {
function Connect-Exchange
{
    [CmdletBinding(DefaultParameterSetName='ExchangeServer')]
    param(        
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='ExchangeServer')]
    [Parameter(Mandatory=$true,Position=0,ParameterSetName='Office365')]
    [Management.Automation.PSCredential]
    $Account,
    
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='ExchangeServer')]
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='UseDefaultCredential')]    
    [string]
    $ServerName,
        
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='Office365')]
    [Switch]
    $IsOffice365Account,
    
    [Parameter(Mandatory=$true,Position=1,ParameterSetName='UseDefaultCredential')]
    [Switch]
    $UseDefaultCredential,
    
    # If set, will attempt to connect to a remote powershell session as well as exchange web services 
    [Switch]
    $ForAdministration
    )
    
    
    process {
        if (-not $UseDefaultCredential) {
            if ($account.username -match "(.+)@(.+)") 
            {
                $username = $matches[1]
                $script:hostedExchangeEmail = $account.UserName
            }
            else
            {
                $username = $account.username
            }
        }
        
        if ($psCmdlet.ParameterSetName -eq 'Office365') {
            if ($script:ExchangeWebService -and $script:CachedCredential.Username -eq $script:CachedCredential) {
                return
            }    
            $ExchangeServer = "https://ps.outlook.com/"
            Write-Progress "Connecting to Office365" "$exchangeServer"
            $script:CachedCredential = $Account
        
            $newSessionParameters = @{
                ConnectionUri='https://ps.outlook.com/powershell'
                ConfigurationName='Microsoft.Exchange'
                Authentication='Basic'           
                Credential=$Account
                AllowRedirection=$true
                WarningAction = "silentlycontinue"
                SessionOption=(New-Object Management.Automation.Remoting.PSSessionOption -Property @{OpenTimeout="00:30:00"})
            }
            
            $Session = New-PSSession @newSessionParameters -WarningVariable warning 
            if (-not $Session) { return } 
            if ($warning  -and $warning.count -gt 0 )
            {
                $message = $warning[$warning.count-1].Message
                if ($message -match "(https?://[a-zA-Z0-9\-\.]+\.(com|org|net|mil|edu|COM|ORG|NET|MIL|EDU))" ) { 
                    $finalserver =  $matches[0] 
                }
            }
            
            $u = $userName.TrimStart("\")
            $samaccountname = Invoke-Command -Session $Session -ScriptBlock {param($u) get-mailbox -Identity $u} -ArgumentList $u |
                Select-Object -ExpandProperty SamAccountName

            $Account = New-Object System.Management.Automation.PSCredential $samaccountname, $Account.Password
            $FinalUri = $finalserver + '/ews/exchange.asmx'
            
            Remove-PSSession -Session $session
            $ExchangeServer = "https://ps.outlook.com/"            
        } else { 
            $ExchangeServer = $ServerName
        }
               
        if ($script:ExchangeWebService) { return } 
        Write-Progress "Connecting to Exchange" "$exchangeServer"
        $uri = "$ExchangeServer".TrimEnd('/') + '/ews/exchange.asmx'
        $wsdl = "$ExchangeServer".TrimEnd('/') + '/ews/services.wsdl'
        $script:ExchangeWebService  = $null
        $script:ExchangeWebServiceNamespace = $null
        if ($finaluri) { 
            $wsdl = "$finalUri".Replace('/ews/exchange.asmx', '/ews/services.wsdl')
        } 
                
        if ($Account) {
            $script:ExchangeWebService = New-WebServiceProxy -Uri $wsdl -Credential $Account 
        } else {
            $script:ExchangeWebService= New-WebServiceProxy -Uri $wsdl -UseDefaultCredential 
        }
        
        if (-not $script:ExchangeWebService) {             
            return 
        }             
        
        Write-Progress "Connected to Exchange!" "$exchangeServer"
        
        $script:ExchangeWebServiceNamespace = $exchangeWebService.GetType().Namespace

        $script:exchangeWebService.RequestServerVersionValue = New-object "$ExchangeWebServiceNamespace.RequestServerVersion"
        if (-not $exchangeVersion) {
            $exchangeVersion = ([int[]][Enum]::GetValues(("$ExchangeWebServiceNamespace.ExchangeVersionType" -as [Type]))) | 
                Sort-Object | 
                Select-Object -Last 1 
        }
        $script:exchangeWebService.RequestServerVersionValue.Version = 
            ("$ExchangeWebServiceNamespace.ExchangeVersionType" -as [Type])::$exchangeVersion
        
        if ($FinalUri) {
            $script:exchangeWebService.Url = $finalUri
        } else {
            $script:exchangeWebService.Url = $uri                   
        }
        
        # If an account was set, make sure the web service has the credential information
        if ($Account) {
            $script:exchangeWebService.Credentials = $Account.GetNetworkCredential()
        }        
        
        
        # Find the correct time zone and set it, otherwise everything comes from UTC
        $tzRequestType = New-Object "$ExchangeWebServiceNamespace.GetServerTimeZonesType" -Property @{
            ReturnFullTimeZoneData=$true;
            ReturnFullTimeZoneDataSpecified=$true
        }
        $tzRequestType.Ids = "$([Timezone]::CurrentTimeZone.StandardName)"        
        $response = $script:exchangeWebService.GetServerTimeZones($tzRequestType)        
        # If the time zone was found, change the web service's time zone context.
              
        if ($response.responsemessages.items[0].ResponseClass -eq 'Success'){
            $tzd =    $response.responsemessages.items[0].timezonedefinitions
            $script:MyTimeZone = $tzd.TimeZoneDefinition
            $tzContext = New-Object "$ExchangeWebServiceNamespace.TimeZoneContextType"
            $tzContext.TimeZoneDefinition = $tzd.TimeZoneDefinition[0]
            $script:exchangeWebService.TimeZoneContext = $tzContext
        }
        
        
        if ($ForAdministration -and -not $script:administrationSession) {        
            $newSessionParameters = @{
                ConnectionUri='https://$exchangeServer/powershell'
                ConfigurationName='Microsoft.Exchange'
                Authentication='Basic'           
                Credential=$Account
                AllowRedirection=$true
                WarningAction = "silentlycontinue"
                SessionOption=(New-Object Management.Automation.Remoting.PSSessionOption -Property @{OpenTimeout="00:30:00"})
            }
            
            $Session = New-PSSession @newSessionParameters -WarningVariable warning         
        }
        
        
        
        if ($PassThru) {
            New-Object PSObject | 
                Add-Member NoteProperty ExchangeWebService $script:exchangeWebService -PassThru |
                Add-Member NoteProperty ExchangeWebService $script:administrationSession -PassThru # |            
        }
    }
} 
        
    }
    
    process {        
        if ($UseWebConfiguration) {
            $exchangeServer = Get-WebConfigurationSetting -Setting ExchangeServer
            $exchangeusername = Get-WebConfigurationSetting -Setting ExchangeUsername
            $exchangepassword = Get-WebConfigurationSetting -Setting ExchangePassword |
                ConvertTo-SecureString -AsPlainText -Force           
            $credential  = New-Object Management.Automation.PSCredential $exchangeusername, $exchangepassword
            
            $psboundparameters.credential = $credential  
            if ($exchangeServer -like "*ps.outlook.com*") {
                $isOffice365Account = $true
                $psboundparameters.isOffice365Account = $true                
            } else {
                $psboundparameters.exchangeserver = $exchangeServer
            }
            
        }
        
        if ($AsJob) {
            $myDefinition = [ScriptBLock]::Create("function Send-Email {
$(Get-Command Send-Email | Select-Object -ExpandProperty Definition)
}
")
            $null = $psBoundParameters.Remove('AsJob')            
            $myJob= [ScriptBLock]::Create("" + {
                param([Hashtable]$parameter) 
                
            } + $myDefinition + {
                
                Send-Email @parameter
            }) 
            
            Start-Job -ScriptBlock $myJob -ArgumentList $psBoundParameters 
            return
        }

        
    
        if ($Credential -and ($ExchangeServer -or $IsOffice365Account)) {
            $connectParams = @{Account=$credential}
            if (-not $IsOffice365Account) {
                $connectParams += @{ServerName=$ExchangeServer}
            } else {
                $connectParams += @{IsOffice365Account=$IsOffice365Account}
            }
            Connect-Exchange @connectParams
        }
        if (-not $script:ExchangeWebService) {
            throw "Must be connected to exchange to Send-Email"
            return                                                
        }
        
        
        # This begs for documentation.
        # A small piece of information on the web service request is the message disposition.  
        # You can SendOnly (makes some sense), SendAndSaveCopy (a good default), and SaveOnly.
        # SaveOnly made no sense to me when I first saw it, and I had to discover the horrible quirks 
        # of exchange in the process.  When you attach things, you actually "send" things, and then attach things 
        # to them, and then send again.  This is one of the times you use SaveOnly, and where there is a short
        # paragraph around this deceptively simple line.  We'll come back here later.
        $messageDisposition = "SendAndSaveCopy"
        if ($attachment) {
            $messageDisposition = "SaveOnly"
        }
        
        # Ok, the next note is on syntax.  Since each connection to the web service has a slightly different type name,
        # the New-Object has to always create an item related to that ever-changing namespace.  Many things
        # within Exchange Web Service also require you to set a lot of propertys, and so the 
        # New-OBJECT "preface.Typename" -Property @{Stuff} style is very common in this code base
        $createItemType = New-Object "$script:ExchangeWebServiceNamespace.CreateItemType" -Property @{
            MessageDisposition = $messageDisposition
            MessageDispositionSpecified  = $true
            Items = New-Object "$script:ExchangeWebServiceNamespace.NonEmptyArrayOfAllItemsType"
        }
        
        # Ok, next bit of complication.  Send-Email actually sends appointment requests.  It knows to do so by
        # the presence or absence of a Start or End parameter.        
        if ($Start -and $End -and 
            (-not $responseType -or $responseType -eq "Organizer")) {
            if ($ItemClass -notlike "*Meeting*") {
                $ItemClass = "IPM.Schedule.Meeting.Request"
            }
        }
        # Next along the line if the default item class.  Strangely, the item class for a mail message is "IPM.NOTE"        
        if (-not $ItemClass) { $ItemClass = "IPM.Note" } 

        # We create a slightly different base object, depending on the type of meeting.
        # Most times it's MessageType, but it it's a meeting request it's a CalendarItemType
        $messageType = switch ($ItemClass) {
            "IPM.Schedule.Meeting.Request" { "CalendarItemType" }
            "IPM.Schedule.Meeting.Resp.Pos" { "MessageType" }
            "IPM.Schedule.Meeting.Cancelled" { "MessageType" }
            "IPM.Note" { "MessageType"}
        }
                

        # Message body is the same either way, so create the message and the body in a nice 
        # byzantine nested New-Object ... -Property @{}
        $message =New-Object "$script:ExchangeWebServiceNamespace.${messageType}" -Property @{
            Body = New-Object "$script:ExchangeWebServiceNamespace.BodyType" -Property @{
                BodyType1 = if ($BodyAsHtml) { "Html" } else { "Text" } 
                Value =  $Body
            }
        }
        
        # Because, if you've failed to get a message at this point, it should give up
        if (-not $message) { 
            return   
        }
        
        if ("AcceptItemType","DeclineItemType" -contains $message.GetType().Name) {            
            $message.ReferenceItemId = New-Object "$ExchangeWebServiceNamespace.ItemIDType" -Property @{
                Id = $calenderId
            }
        } else {
            $message.Subject = $subject
        }
        
        if ($message.GetType().Name -eq "MessageItemType") {
            $message.Sender= New-Object "$script:ExchangeWebServiceNamespace.SingleRecipientType" -Property @{
                Item = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{
                    EmailAddress = "$From"            
                }
            }                    
        }
        
        if ($Sensitivity) {
            $message.Sensitivity=  $Sensitivity
            $message.SensitivitySpecified = $true
        }
        
        if ($start -and $message.psobject.members["Start"]) {
            $message.Start = $start
            $message.StartSpecified = $true
        }
        if ($end -and $message.psobject.members["End"]) {
            $message.End= $end
            $message.EndSpecified = $true
        }
        if ($location) {
            $message.Location = $Location            
        }
        
        if ($to) {
            if ($message.GetType().Name -eq "CalendarItemType") {
                $message.RequiredAttendees = New-Object "$script:ExchangeWebServiceNamespace.AttendeeType[]" $to.Count
                for ($i = 0; $i -lt $to.Count; $i++) {
                    $t = $to[$i]
                    $attendee = New-Object "$script:ExchangeWebServiceNamespace.AttendeeType" -Property @{
                        MailBox = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{
                            EmailAddress = "$t"
                        }
                    }
                    $message.RequiredAttendees[$i] = $attendee
                }
            } else {
                $message.ToRecipients = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType[]" $to.Count
                for($i =0;$i -lt $to.Count;$i++){
                    $t= $to[$i]
                    $message.ToRecipients[$i] = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{ EmailAddress = "$t" }
                }
            } 
            
        } 
        
        if ($replyTo) {
            $message.ReplyTo = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType[]" $replyTo.Count
            for($i =0;$i -lt $replyTo.Count;$i++){
                $t= $replyTo[$i]
                $message.ReplyTo[$i] = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{ EmailAddress = "$t" }
            }
        }
        
        if ($cc) {
            if ($message.GetType().Name -eq "CalendarItemType") {
                $message.OptionalAttendees = New-Object "$script:ExchangeWebServiceNamespace.AttendeeType[]" $to.Count
                for ($i = 0; $i -lt $to.Count; $i++) {
                    $t = $cc[$i]
                    $attendee = New-Object "$script:ExchangeWebServiceNamespace.AttendeeType" -Property @{
                        MailBox = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{
                            EmailAddress = "$t"
                        }
                    }
                    $message.OptionalAttendees[$i] = $attendee
                }
            } else {
                $message.CcRecipients = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType[]" $cc.Count
                for($i =0;$i -lt $cc.Count;$i++){
                    $t= $cc[$i]
                    $message.CCRecipients[$i] = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{ EmailAddress = "$t" }
                }
            }
        }
                
        if ($bcc) {
            $message.BccRecipients = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType[]" $bcc.Count
            for($i =0;$i -lt $bcc.Count;$i++){
                $t= $bcc[$i]
                $message.BccRecipients[$i] = New-Object "$script:ExchangeWebServiceNamespace.EmailAddressType" -Property @{ EmailAddress = "$t" }
            }
        }
        
        if ($psBoundParameters.Category) {
            $message.Categories = $category
        }        
        
        if ($message.GetType().Name -eq "CalendarItemType") {
            $createItemType.SendMeetingInvitations = "SendToAllAndSaveCopy"
            $createItemType.SendMeetingInvitationsSpecified = $true
        } else {
            $createItemType.SavedItemFolderId = New-Object "$script:ExchangeWebServiceNamespace.TargetFolderIdType" -Property @{
                Item = New-Object "$script:ExchangeWebServiceNamespace.DistinguishedFolderIdType" -Property @{
                    Id  = "SentItems"
                }
            }
        
        }

        $createItemType.Items.Items = New-Object "$script:ExchangeWebServiceNamespace.ItemType[]" 1
        $createItemType.Items.Items[0] = $message

        
        $result = $exchangeWebService.CreateItem($createItemType) 
        
        
        
        $result.ResponseMessages.Items | 
            Where-Object {
                $_.ResponseClass -eq "Error"
            } |
            ForEach-Object {
                Write-Error -Message $_.MessageText -ErrorId "ExchangeWebServiceError.$($_.ResponseCode)"
            }   
            
        #If there are attachments, we need to create attachments.   
        if ($attachment) {
            $Attachment = @($attachment)

            #Need to get the item id of the item that is just created.
            $itemid = $result.ResponseMessages.Items[0].Items.Items[0].ItemId           
            
            #Need to call CreateAttachement webservice for each attachment and associate it with the above id.           
            $createAttachmentType =  New-Object "$script:ExchangeWebServiceNamespace.CreateAttachmentType"  
           
            $itemidtype = New-Object "$script:ExchangeWebServiceNamespace.ItemIdType"  -Property @{
                Id = $itemid.Id
                ChangeKey = $itemId.ChangeKey
            }
            
           
            $createAttachmentType.ParentItemId = $itemidtype
          
           
            $createAttachmentType.Attachments = New-Object "$script:ExchangeWebServiceNamespace.AttachmentType[]"  @($Attachment).count
           
            for($i=0 ; $i -lt @($Attachment).count; $i++) {           
                $fileattachment = New-Object "$script:ExchangeWebServiceNamespace.FileAttachmentType"   
                $resolvedAttachmentPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath(@($attachment)[$i])
                if (-not $resolvedAttachmentPath) { break }
                $fileattachment.Name = Split-Path -Leaf $resolvedAttachmentPath                
                $fileattachment.Content = [IO.File]::ReadAllBytes($resolvedAttachmentPath )
              
                $createAttachmentType.Attachments[$i] = $fileattachment                     
            }          

            
            $attachmentresult = $exchangeWebService.CreateAttachment($createAttachmentType)
            $attachmentResponseMessage =$attachmentResult.ResponseMessages.Items[0]
        
            $sendItemType = New-Object "$script:ExchangeWebServiceNamespace.SendItemType" -Property @{            
                SavedItemFolderId = New-Object "$script:ExchangeWebServiceNamespace.TargetFolderIdType" -Property @{
                    Item = New-Object "$script:ExchangeWebServiceNamespace.DistinguishedFolderIdType" -Property @{
                        Id  = "SentItems"
                    }
                }
                ItemIds = New-Object "$script:ExchangeWebServiceNamespace.BaseItemIdType[]" $attachmentResponseMessage.Attachments.Count
                SaveItemToFolder = $true
            }
            
            for ($c = 0 ;$c -lt $attachmentResponseMessage.Attachments.Count; $c++) {
                $itemIdType = New-Object "$script:ExchangeWebServiceNamespace.ItemIdType" -Property @{
                    ChangeKey = $attachmentResponseMessage.Attachments[$c].AttachmentId.RootItemChangeKey
                    Id = $attachmentResponseMessage.Attachments[$c].AttachmentId.RootItemId
                }
                $sendItemType.ItemIds[$c] = $itemIdType
            }
            
            $result = $script:ExchangeWebService.SendItem($sendItemType)
            
        }
          
            
        if ($passThru) { $result } 
    }
}
