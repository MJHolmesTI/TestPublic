USE [Admin]
GO

/****** Object:  StoredProcedure [dbo].[sp_ReadLRQ]    Script Date: 9/12/2016 10:46:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER proc [dbo].[sp_ReadLRQ]

(
@db varchar(100) = '',
@EndTime datetime= null,
@text varchar(100) ='',
@MinMs smallint = 1000 ) 

as

if @Endtime is null 
Set @EndTime = getdate() 


declare @tracefilename nvarchar(256)
--select * from tempdb.dbo.sysfiles where name = 'tempdev'

--declare @tracefilebase nvarchar(50)
--set @tracefilebase = 'LongRunningQueries-'+convert(varchar(100),cast(getdate() as date),121)
----select @tracefilebase 

--declare @tempdbpath nvarchar(200)
--select top 1 @tempdbpath =  filename from tempdb.dbo.sysfiles where name = 'tempdev'
--print @tempdbpath 
--set @tracefilename = replace(@tempdbpath,'tempdb.mdf',@tracefilebase)

select @tracefilename = path from sys.traces where path like '%LongRunning%'
--select @tracefilename = 'L:\SQLData\LongRunningQueries-2015-05-30.trc'
print @tracefilename 

select top 250 (duration/1000) as duration_ms, reads as reads__8KB, cpu as cpu_ms, starttime, endtime, databasename, hostname,
left(convert(nvarchar(max),textdata),500 ) as CommandText, 
 right(convert(nvarchar(max),textdata),5000) as TD1,
 datalength(textdata) as TDL, 
 datalength(replace(convert(nvarchar(max),textdata),'@p1','') ) as TDL2
 ,*
 from fn_trace_gettable(@tracefilename,-1) tr
where duration > @minMs*1000--and reads+cpu > 0 
and databasename like  @db+'%' 
--and textdata not like '%backup%' 
and textdata like '%'+@text+'%'
and tr.starttime < @Endtime
--and tr.starttime > '2015-05-04 18:20:00' and tr.starttime <'2015-05-04 18:24:00'-- '2014-11-12 07:27:13.097' 
order by tr.starttime  desc 

--select min(starttime) from fn_trace_gettable(@tracefilename,0)


--select * from sys.traces 
--declare @p1 int
--set @p1=2
--exec sp_prepexec @p1 output,NULL,N'select g.*, g.program_no as guide_id from program_genre_tbl g join program_tbl p on g.program_no = p.program_no and p.is_active = 1'
--select @p1
GO


