USE [msdb]
GO

/****** Object:  Job [GP - Remove Unused Objects]    Script Date: 10/8/2021 11:20:00 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/8/2021 11:20:00 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GP - Remove Unused Objects', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job executes a stored procedure to remove both the Microsoft Connection and the To-Do sections of the Dynamics GP Homepage.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Homepage Objects]    Script Date: 10/8/2021 11:20:01 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Homepage Objects', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.RemoveHomePageObjects', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove CEIP For All Users]    Script Date: 10/8/2021 11:20:01 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove CEIP For All Users', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DYNAMICS

SET NOCOUNT ON

DECLARE @Userid Char(15)

DECLARE cCEIP CURSOR FOR
SELECT	A.USERID
FROM	dbo.SY01400 A
LEFT JOIN
	dbo.SY01402 B
		ON A.USERID = B.USERID
		AND	B.syDefaultType = 48
WHERE	B.USERID IS NULL
	OR B.SYUSERDFSTR NOT LIKE ''1:%''

OPEN cCEIP
WHILE 1 = 1
BEGIN
FETCH NEXT FROM cCEIP
INTO @Userid
IF @@FETCH_STATUS <> 0
BEGIN
CLOSE cCEIP
DEALLOCATE cCEIP
BREAK
END

IF EXISTS
(
SELECT	syDefaultType
FROM	DYNAMICS.dbo.SY01402
WHERE	USERID = @Userid
	AND syDefaultType = 48
)

BEGIN
UPDATE	DYNAMICS.dbo.SY01402
SET		SYUSERDFSTR = ''1:''
WHERE	USERID = @Userid
		AND syDefaultType = 48
END
ELSE
BEGIN
INSERT	DYNAMICS.dbo.SY01402 (USERID, syDefaultType, SYUSERDFSTR)
VALUES
	(@Userid, 48, ''1:'')
END
END /* while */

SET NOCOUNT OFF', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove User Tasks]    Script Date: 10/8/2021 11:20:01 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove User Tasks', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Delete DYNAMICS.dbo.SY01403', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Custom Reminders]    Script Date: 10/8/2021 11:20:01 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Custom Reminders', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Delete DYNAMICS.dbo.SY01404 ', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'GP User Maintenance - Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=127, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210621, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid=N'71bb982c-5063-4409-98f6-6d58dd2296b0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


