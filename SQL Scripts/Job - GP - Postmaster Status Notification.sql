USE [msdb]
GO

/****** Object:  Job [GP - Postmaster Status Notification]    Script Date: 10/8/2021 11:19:35 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 10/8/2021 11:19:35 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GP - Postmaster Status Notification', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job checks if Postmaster may be stuck and notifies the development team so it can be checked and restarted if necessary.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check for Stuck Batches]    Script Date: 10/8/2021 11:19:35 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check for Stuck Batches', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Drop Temp Table
IF OBJECT_ID(''tempdb..#PostmasterChecker'') IS NOT NULL
DROP TABLE #PostmasterChecker
;
-- Find the number of unposted batches that Post Master would normally post.
DECLARE @TotalBatches Int
SELECT	@TotalBatches = COUNT(DISTINCT S.BACHNUMB)
FROM	PHARM.dbo.SY00500 S
WHERE	(
		(BCHSOURC = ''Rcvg Trx Entry'' AND BACHNUMB LIKE ''%RCV%'')
		OR (BCHSOURC = ''Sales Entry'' AND BACHNUMB LIKE ''%-%'')
		OR (BCHSOURC = ''Rcvg Trx Ivc'' AND BACHNUMB LIKE ''%-%'')
		OR (BCHSOURC = ''Transaction Entry'' AND BACHNUMB LIKE ''%VENDRETRN'')
		OR (BACHNUMB LIKE ''%TRANSFER'')
		OR (BACHNUMB LIKE ''999IV%'')
		OR (BACHNUMB LIKE ''IVTFR%'')
		OR (BACHNUMB LIKE ''IVADJ%'')
		OR (BACHNUMB LIKE ''RMCSH%'')
		OR (BACHNUMB LIKE ''RXCOUNTS%'')
		OR (BACHNUMB LIKE ''AFPAYMENT'')
		OR (BACHNUMB LIKE ''%ONHAND%'')
		OR (BACHNUMB LIKE ''%AFINVOICE%'')
		OR (BACHNUMB LIKE ''%AMFRESH%'')
		OR (BACHNUMB LIKE ''AFREFUND'')
		OR (BACHNUMB LIKE ''WAREHOUSE%'')
		OR (BACHNUMB LIKE ''%SPTCNT'')
		OR (BACHNUMB LIKE ''%ADJUST'')
		OR (BACHNUMB LIKE ''%REPLENISH%'')
		OR (BACHNUMB LIKE ''ETRF%'')
		OR (BACHNUMB LIKE ''RECVG%'')
		)
		AND USERID = ''''
		AND NUMOFTRX != 0

-- Find the number of unposted transactions that Post Master would normally post.
DECLARE @TOTALTRX INT
SELECT	@TOTALTRX = SUM(NUMOFTRX)
FROM	PHARM.dbo.SY00500 WITH (NOLOCK)
WHERE	(
	(BCHSOURC = ''Rcvg Trx Entry'' AND BACHNUMB LIKE ''%RCV%'')
	OR (BCHSOURC = ''Sales Entry'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Rcvg Trx Ivc'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Transaction Entry'' AND BACHNUMB LIKE ''%VENDRETRN'')
	OR (BACHNUMB LIKE ''%TRANSFER'')
	OR (BACHNUMB LIKE ''999IV%'')
	OR (BACHNUMB LIKE ''IVTFR%'')
	OR (BACHNUMB LIKE ''IVADJ%'')
	OR (BACHNUMB LIKE ''RMCSH%'')
	OR (BACHNUMB LIKE ''RXCOUNTS%'')
	OR (BACHNUMB LIKE ''AFPAYMENT'')
	OR (BACHNUMB LIKE ''%ONHAND%'')
	OR (BACHNUMB LIKE ''%AFINVOICE%'')
	OR (BACHNUMB LIKE ''%AMFRESH%'')
	OR (BACHNUMB LIKE ''AFREFUND'')
	OR (BACHNUMB LIKE ''WAREHOUSE%'')
	OR (BACHNUMB LIKE ''%SPTCNT'')
	OR (BACHNUMB LIKE ''%ADJUST'')
	OR (BACHNUMB LIKE ''%REPLENISH%'')
	OR (BACHNUMB LIKE ''ETRF%'')
	OR (BACHNUMB LIKE ''RECVG%'')
	)
	AND USERID = ''''
	AND NUMOFTRX != 0
;

-- Get transaction differential since last run.
DECLARE @DIFF INT
SELECT	@DIFF = @TOTALTRX - [Count]
FROM	Integration.dbo.SYS_GPErrors
WHERE	ErrorId = 18
;

-- Store current unposted transactions.
UPDATE	Integration.dbo.SYS_GPErrors
SET	[Count] = @TOTALTRX
WHERE	ErrorId = 18

-- Script Email 
SELECT	BACHNUMB BatchNumber
	, NUMOFTRX TransactionCount
	, CONVERT(Varchar(10),MODIFDT,101) BatchModifiedDate
INTO	#PostmasterChecker
FROM	PHARM.dbo.SY00500 WITH (NOLOCK)
WHERE	(
	(BCHSOURC = ''Rcvg Trx Entry'' AND BACHNUMB LIKE ''%RCV%'')
	OR (BCHSOURC = ''Sales Entry'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Rcvg Trx Ivc'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Transaction Entry'' AND BACHNUMB LIKE ''%VENDRETRN'')
	OR (BACHNUMB LIKE ''%TRANSFER'')
	OR (BACHNUMB LIKE ''999IV%'')
	OR (BACHNUMB LIKE ''IVTFR%'')
	OR (BACHNUMB LIKE ''IVADJ%'')
	OR (BACHNUMB LIKE ''RMCSH%'')
	OR (BACHNUMB LIKE ''RXCOUNTS%'')
	OR (BACHNUMB LIKE ''AFPAYMENT'')
	OR (BACHNUMB LIKE ''%ONHAND%'')
	OR (BACHNUMB LIKE ''%AFINVOICE%'')
	OR (BACHNUMB LIKE ''%AMFRESH%'')
	OR (BACHNUMB LIKE ''AFREFUND'')
	OR (BACHNUMB LIKE ''WAREHOUSE%'')
	OR (BACHNUMB LIKE ''%SPTCNT'')
	OR (BACHNUMB LIKE ''%ADJUST'')
	OR (BACHNUMB LIKE ''%REPLENISH%'')
	OR (BACHNUMB LIKE ''ETRF%'')
	OR (BACHNUMB LIKE ''RECVG%'')
	)
	AND USERID = ''''
	AND NUMOFTRX != 0

DECLARE @EmailSubject NVarchar(150)
DECLARE @xml NVarchar(MAX)
DECLARE @body NVarchar(MAX)

SELECT	@EmailSubject = ''Postmaster Notification | '' 
	+ CONVERT(Varchar(10),COUNT(BACHNUMB)) + '' Unposted Batches''	
FROM	PHARM.dbo.SY00500 WITH (NOLOCK)
WHERE	(
	(BCHSOURC = ''Rcvg Trx Entry'' AND BACHNUMB LIKE ''%RCV%'')
	OR (BCHSOURC = ''Sales Entry'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Rcvg Trx Ivc'' AND BACHNUMB LIKE ''%-%'')
	OR (BCHSOURC = ''Transaction Entry'' AND BACHNUMB LIKE ''%VENDRETRN'')
	OR (BACHNUMB LIKE ''%TRANSFER'')
	OR (BACHNUMB LIKE ''999IV%'')
	OR (BACHNUMB LIKE ''IVTFR%'')
	OR (BACHNUMB LIKE ''IVADJ%'')
	OR (BACHNUMB LIKE ''RMCSH%'')
	OR (BACHNUMB LIKE ''RXCOUNTS%'')
	OR (BACHNUMB LIKE ''AFPAYMENT'')
	OR (BACHNUMB LIKE ''%ONHAND%'')
	OR (BACHNUMB LIKE ''%AFINVOICE%'')
	OR (BACHNUMB LIKE ''%AMFRESH%'')
	OR (BACHNUMB LIKE ''AFREFUND'')
	OR (BACHNUMB LIKE ''WAREHOUSE%'')
	OR (BACHNUMB LIKE ''%SPTCNT'')
	OR (BACHNUMB LIKE ''%ADJUST'')
	OR (BACHNUMB LIKE ''%REPLENISH%'')
	OR (BACHNUMB LIKE ''ETRF%'')
	OR (BACHNUMB LIKE ''RECVG%'')
	)
	AND USERID = ''''
	AND NUMOFTRX != 0

SET @xml = CAST((SELECT PC.BatchNumber AS ''td'','''', PC.TransactionCount AS ''td'','''', PC.BatchModifiedDate AS ''td'' FROM #PostmasterChecker PC FOR XML PATH(''tr''), ELEMENTS ) AS NVarchar(MAX))

SET @xml = REPLACE(@xml,''<td>'',''<td align="Center">'')

SET @body = ''<html><body>The batch or batches listed below should be automatically posted by Postmaster. It is possible Postmaster has become stuck and needs to be restarted. <br><H3 align="Center">Unposted Batches</H3><table border = 3 align="Center"><tr><th align="Center">  Batch Number  </th><th align = "Center">  Transaction Count  </th><th align = "Center">  Modification Date  </th></tr>''

SET @body = @body + @xml + ''</table>''

-- Send an email only if there is a backlog and it''s not shrinking.
IF (
	DATEPART(HOUR,GETDATE()) IN (3,4,5)
	AND @TotalBatches > 100
	AND @DIFF >= 0
	)
	OR
	(
	DATEPART(HOUR,GETDATE()) NOT IN (0,1,2,3,4,5)
	AND @TotalBatches > 10
	AND @DIFF >= 0
	)

EXEC msdb.dbo.sp_send_dbmail 
@profile_name = ''Dynamics Notifications''
, @recipients = ''developers@Pharmaca.com''
, @subject = @EmailSubject
, @body = @body
, @body_format = ''HTML''
;

-- Delete Temp Table
IF OBJECT_ID(''tempdb..#StuckBatches'') IS NOT NULL
DROP TABLE #StuckBatches
;', 
		@database_name=N'DYNAMICS', 
		@flags=20
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'GP - Postmaster Notification', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180930, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'3f47e110-b695-47fb-804a-6359c334f9b3'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


