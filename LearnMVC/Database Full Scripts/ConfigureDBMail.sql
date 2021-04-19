Declare @profilename nvarchar(100) = 'AVSSB-AutoGenerate'
-- Create a Database Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'AVSSB-AutoGenerate',  
    @description = 'Profile used for test outgoing notifications using Gmail.' ;  
GO

-- Grant access to the profile to the DBMailUsers role  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'AVSSB-AutoGenerate',  
    @principal_name = 'public',  
    @is_default = 1 ;
GO

EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'AVSSB-AutoGenerate',  
    @description = 'Mail account for sending outgoing test notifications.',  
    @email_address = 'abburusaibhargav@gmail.com',  
    @display_name = 'noreply',  
    @mailserver_name = 'smtp.gmail.com',
    @port = 587,
    @enable_ssl = 1,
    @username = 'abburusaibhargav@gmail.com',
    @password = 'Vista@8073' ;  
GO

EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'AVSSB-AutoGenerate',  
    @account_name = 'AVSSB-AutoGenerate',  
    @sequence_number =1 ;  
GO

/* USE ONLY ABOVE CODE THROWS ERROR => ROLLBACK CHANGES
EXECUTE msdb.dbo.sysmail_delete_profileaccount_sp @profile_name = 'Notifications'
EXECUTE msdb.dbo.sysmail_delete_principalprofile_sp @profile_name = 'Notifications'
EXECUTE msdb.dbo.sysmail_delete_account_sp @account_name = 'Gmail'
EXECUTE msdb.dbo.sysmail_delete_profile_sp @profile_name = 'Notifications'
*/