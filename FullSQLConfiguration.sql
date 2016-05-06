--Enable Database Mail
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

--Add Operators
USE msdb ;
GO
EXEC dbo.sp_add_operator
    @name = N'Backups',
    @enabled = 1,
    @email_address = N'backups@company.com';
GO
USE msdb ;
GO
EXEC dbo.sp_add_operator
    @name = N'SQL Server Alerts Distribution List',
    @enabled = 1,
    @email_address = N'serveralertssql@company.com';
GO

-------------------------------------------------------------
--  Database Mail Simple Configuration Template.
--
--  This template creates a Database Mail profile, an SMTP account and
--  associates the account to the profile.
--  The template does not grant access to the new profile for
--  any database principals.  Use msdb.dbo.sysmail_add_principalprofile
--  to grant access to the new profile for users who are not
--  members of sysadmin.
-------------------------------------------------------------
DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
        @display_name NVARCHAR(128);
-- Profile name. Replace with the name for your profile
        SET @profile_name = 'Alerts';
-- Account information. Replace with the information for your account.
        SET @account_name = 'SQLAlerts';
        SET @SMTP_servername = 'mail.company.com';
        SET @email_address = 'Alerts@company.com';
        SET @display_name = 'SQL Alerts';
 
-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  RAISERROR('The specified Database Mail profile (Alerts) already exists.', 16, 1);
  GOTO done;
END;
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
 RAISERROR('The specified Database Mail account (SQLAlerts) already exists.', 16, 1) ;
 GOTO done;
END;
-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;
DECLARE @rv INT;
-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @email_address = @email_address,
    @display_name = @display_name,
    @mailserver_name = @SMTP_servername;
IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail account (SQLAlerts).', 16, 1) ;
    GOTO done;
END
-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name ;
IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile (Alerts).', 16, 1);
    ROLLBACK TRANSACTION;
    GOTO done;
END;
-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;
IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the speficied profile with the specified account (SQLAlerts).', 16, 1) ;
    ROLLBACK TRANSACTION;
    GOTO done;
END;
COMMIT TRANSACTION;
done:
GO

--Enable SQL Agent to use Database mail and new profile
USE msdb
GO
EXEC master.dbo.xp_instance_regwrite
N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'UseDatabaseMail',
N'REG_DWORD', 1
EXEC master.dbo.xp_instance_regwrite
N'HKEY_LOCAL_MACHINE',
N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent',
N'DatabaseMailProfile',
N'REG_SZ',
N'Alerts'

--Create Alerts and assign Operator
USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 016',
@message_id=0,
@severity=16,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 016', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 017',
@message_id=0,
@severity=17,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 017', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 018',
@message_id=0,
@severity=18,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 018', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 019',
@message_id=0,
@severity=19,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 019', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 020',
@message_id=0,
@severity=20,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 020', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 021',
@message_id=0,
@severity=21,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 021', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 022',
@message_id=0,
@severity=22,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 022', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 023',
@message_id=0,
@severity=23,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 023', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 024',
@message_id=0,
@severity=24,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 024', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Severity 025',
@message_id=0,
@severity=25,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000';
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Severity 025', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 823',
@message_id=823,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 823', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 824',
@message_id=824,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 824', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO
EXEC msdb.dbo.sp_add_alert @name=N'Error Number 825',
@message_id=825,
@severity=0,
@enabled=1,
@delay_between_responses=60,
@include_event_description_in=1,
@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Error Number 825', @operator_name=N'SQL Server Alerts Distribution List', @notification_method = 7;
GO