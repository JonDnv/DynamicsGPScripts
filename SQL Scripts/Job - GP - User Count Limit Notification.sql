USE [msdb]
GO

/****** Object:  Job [GP - User Count Limit Notification]    Script Date: 10/8/2021 11:20:42 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [GP Audit]    Script Date: 10/8/2021 11:20:42 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'GP Audit' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'GP Audit'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GP - User Count Limit Notification', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Sends email when user limit is reached', 
		@category_name=N'GP Audit', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check ACTIVITY]    Script Date: 10/8/2021 11:20:43 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check ACTIVITY', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

declare @limit int, @current int
declare @msg varchar(80)
declare @threshold decimal(5,2)

set @limit = 20	/* current Great Plains limit - unable to extract from reg keys of table */
set @threshold = 0.80
select @current  = count(*) from ACTIVITY
print ''Current = '' + str ( @current)

if @current >= @limit begin
	set @msg = ''GP user limit of '' + str (@limit) + '' has been reached.''

	exec msdb.dbo.sp_send_dbmail
	@profile_name = ''Dynamics GP Notifications''
	, @recipients = ''gp_admins@pharmaca.com;developers@pharmaca.com''
	, @subject = ''Great Plains User Limit Reached''
    , @body = @msg
end
else 
if @current >= ( @limit * @threshold  ) begin
	set @msg = ''GP user connections ('' + LTRIM(RTRIM(str ( @current ))) + '') exceeds '' + LTRIM(RTRIM(str ( @threshold * 100))) + ''% limit of the available '' + RTRIM(LTRIM(str ( @limit))) + ''.''

	exec msdb.dbo.sp_send_dbmail
	@profile_name = ''Dynamics GP Notifications''
	, @recipients = ''gp_admins@pharmaca.com;developers@pharmaca.com''
	, @subject = ''Great Plains User Count Exceeds Threshold''
	, @body = @msg

end', 
		@database_name=N'DYNAMICS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Stats Collection]    Script Date: 10/8/2021 11:20:43 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Stats Collection', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=1, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @usercnt int
select @usercnt = count(*) from DYNAMICS.dbo.ACTIVITY
insert emeUSERCOUNT values ( ''GP'', getdate(), @usercnt )

', 
		@database_name=N'DYNAMICS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Frequently', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20060822, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f7af5394-3bc4-413f-ad2a-deace827dc8c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


