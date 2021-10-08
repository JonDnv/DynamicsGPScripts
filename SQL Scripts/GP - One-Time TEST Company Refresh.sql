USE [msdb]
GO

/****** Object:  Job [GP - One-Time TEST Company Refresh]    Script Date: 10/8/2021 11:19:18 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/8/2021 11:19:18 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GP - One-Time TEST Company Refresh', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job refreshes the test company monthly for use by Finance.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup PHARM]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup PHARM', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [PHARM] 
TO DISK = N''E:\TESTBAK\PHARMBAK.bak'' WITH CHECKSUM, COMPRESSION, COPY_ONLY', 
		@database_name=N'master', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set TEST to SINGLE_USER]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set TEST to SINGLE_USER', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE [TEST] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;', 
		@database_name=N'master', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore PHARM over TEST]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore PHARM over TEST', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'RESTORE DATABASE [TEST] FROM  DISK = N''E:\TESTBAK\PHARMBAK.bak'' 
	WITH  FILE = 1
	,  MOVE N''GPSPHARMDat.mdf'' TO N''E:\Databases\DynamicsGPTestCompany\GPSTESTDat.mdf''
	,  MOVE N''GPSPHARMLog.ldf'' TO N''E:\Databases\Logs\GPSTESTLog.ldf''
	,  NOUNLOAD
	,  REPLACE
	,  STATS = 5', 
		@database_name=N'master', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set TEST to MULTI_USER]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set TEST to MULTI_USER', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE [TEST] SET MULTI_USER', 
		@database_name=N'master', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Change TEST Database Ownership]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Change TEST Database Ownership', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC TEST.dbo.sp_changedbowner ''DYNSA''', 
		@database_name=N'TEST', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set TEST Database to Simple Recovery]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set TEST Database to Simple Recovery', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'ALTER DATABASE TEST SET RECOVERY SIMPLE', 
		@database_name=N'master', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Shrink TEST Database Log File]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Shrink TEST Database Log File', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DBCC SHRINKFILE (N''GPSPHARMLog.ldf'' , 10240)', 
		@database_name=N'TEST', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute Test Company Script]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute Test Company Script', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'if exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = ''SY00100'') begin
  declare @Statement varchar(850)
  select @Statement = ''declare @cStatement varchar(255)
declare G_cursor CURSOR for
select case when UPPER(a.COLUMN_NAME) in (''''COMPANYID'''',''''CMPANYID'''')
  then ''''update ''''+a.TABLE_NAME+'''' set ''''+a.COLUMN_NAME+'''' = ''''+ cast(b.CMPANYID as char(3)) 
  else ''''update ''''+a.TABLE_NAME+'''' set ''''+a.COLUMN_NAME+'''' = ''''''''''''+ db_name()+'''''''''''''''' end
from INFORMATION_SCHEMA.COLUMNS a, ''+rtrim(DBNAME)+''.dbo.SY01500 b
  where UPPER(a.COLUMN_NAME) in (''''COMPANYID'''',''''CMPANYID'''',''''INTERID'''',''''DB_NAME'''',''''DBNAME'''')
    and b.INTERID = db_name() and COLUMN_DEFAULT is not null
 and rtrim(a.TABLE_NAME)+''''-''''+rtrim(a.COLUMN_NAME) <> ''''SY00100-DBNAME''''
  order by a.TABLE_NAME
set nocount on
OPEN G_cursor
FETCH NEXT FROM G_cursor INTO @cStatement
WHILE (@@FETCH_STATUS <> -1)
begin
  exec (@cStatement)
  FETCH NEXT FROM G_cursor INTO @cStatement
end
close G_cursor
DEALLOCATE G_cursor
set nocount off''
  from SY00100
  exec (@Statement)
end
else begin
  declare @cStatement varchar(255)
  declare G_cursor CURSOR for
  select case when UPPER(a.COLUMN_NAME) in (''COMPANYID'',''CMPANYID'')
    then ''update ''+a.TABLE_NAME+'' set ''+a.COLUMN_NAME+'' = ''+ cast(b.CMPANYID as char(3)) 
    else ''update ''+a.TABLE_NAME+'' set ''+a.COLUMN_NAME+'' = ''''''+ db_name()+'''''''' end
  from INFORMATION_SCHEMA.COLUMNS a, DYNAMICS.dbo.SY01500 b
    where UPPER(a.COLUMN_NAME) in (''COMPANYID'',''CMPANYID'',''INTERID'',''DB_NAME'',''DBNAME'')
      and b.INTERID = db_name() and COLUMN_DEFAULT is not null
    order by a.TABLE_NAME
  set nocount on
  OPEN G_cursor
  FETCH NEXT FROM G_cursor INTO @cStatement
  WHILE (@@FETCH_STATUS <> -1)
  begin
    exec (@cStatement)
    FETCH NEXT FROM G_cursor INTO @cStatement
  end
  close G_cursor
  DEALLOCATE G_cursor
  set nocount off
END', 
		@database_name=N'TEST', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove PHARM Backup File]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove PHARM Backup File', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -File "C:\Scripts\TESTBAKRemoval.ps1" -Verb RunAs', 
		@flags=48
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Notify of Refresh]    Script Date: 10/8/2021 11:19:18 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Notify of Refresh', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DYNAMICS.dbo.TestRefreshCompletedNotification', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'One Time Refresh', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201127, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=235959, 
		@schedule_uid=N'9eaa6636-d416-4e99-9661-87bb46cca833'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


