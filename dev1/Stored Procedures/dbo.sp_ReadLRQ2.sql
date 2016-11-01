SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[sp_ReadLRQ2]

(
@db VARCHAR(100) = '',
@EndTime DATETIME= NULL,
@text VARCHAR(100) ='',
@MinMs SMALLINT = 1000 ) 

AS
--test remote 3

IF @Endtime IS NULL 
SET @EndTime = GETDATE() 


DECLARE @tracefilename NVARCHAR(256)
--select * from tempdb.dbo.sysfiles where name = 'tempdev'

--declare @tracefilebase nvarchar(50)
--set @tracefilebase = 'LongRunningQueries-'+convert(varchar(100),cast(getdate() as date),121)
----select @tracefilebase 

--declare @tempdbpath nvarchar(200)
--select top 1 @tempdbpath =  filename from tempdb.dbo.sysfiles where name = 'tempdev'
--print @tempdbpath 
--set @tracefilename = replace(@tempdbpath,'tempdb.mdf',@tracefilebase)

SELECT @tracefilename = path FROM sys.traces WHERE path LIKE '%LongRunning%'
--select @tracefilename = 'L:\SQLData\LongRunningQueries-2015-05-30.trc'
PRINT @tracefilename 

SELECT TOP 250 (duration/1000) AS duration_ms, reads AS reads__8KB, cpu AS cpu_ms, starttime, endtime, databasename, hostname,
LEFT(CONVERT(NVARCHAR(MAX),textdata),500 ) AS CommandText, 
 RIGHT(CONVERT(NVARCHAR(MAX),textdata),5000) AS TD1,
 DATALENGTH(textdata) AS TDL, 
 DATALENGTH(REPLACE(CONVERT(NVARCHAR(MAX),textdata),'@p1','') ) AS TDL2
 ,*
 FROM fn_trace_gettable(@tracefilename,-1) tr
WHERE duration > @minMs*1000--and reads+cpu > 0 
AND databasename LIKE  @db+'%' 
--and textdata not like '%backup%' 
AND textdata LIKE '%'+@text+'%'
AND tr.starttime < @Endtime
--and tr.starttime > '2015-05-04 18:20:00' and tr.starttime <'2015-05-04 18:24:00'-- '2014-11-12 07:27:13.097' 
--and hostname like 'SC01FMWEB19%'
ORDER BY tr.starttime  DESC 

--select min(starttime) from fn_trace_gettable(@tracefilename,0)


--select * from sys.traces 
--declare @p1 int
--set @p1=2
--exec sp_prepexec @p1 output,NULL,N'select g.*, g.program_no as guide_id from program_genre_tbl g join program_tbl p on g.program_no = p.program_no and p.is_active = 1'
--select @p1

GO
