
	SET LINES 200;
	SET PAGES 999;
	SELECT
				SESSION_RECID,
				SESSION_STAMP,
				OBJECT_TYPE,
				(
					SELECT DISTINCT
							CASE
								WHEN (D.BACKUP_TYPE = 'D') AND (D.INCREMENTAL_LEVEL = '')  THEN
									'FULL'
								WHEN (D.BACKUP_TYPE = 'D') AND (D.INCREMENTAL_LEVEL = '0') THEN
									'LEVEL 0'
								WHEN (D.BACKUP_TYPE = 'I') AND (D.INCREMENTAL_LEVEL = '0') THEN
									'LEVEL 0'
								WHEN (D.BACKUP_TYPE = 'I') AND (D.INCREMENTAL_LEVEL = '1') THEN
									'LEVEL 1/LEVEL 1C'
								ELSE
									'NONE'
							END
					FROM        V$BACKUP_SET_DETAILS D
					INNER JOIN  V$BACKUP_SET S
					ON          S.SET_STAMP             =   D.SET_STAMP
					AND         S.SET_COUNT             =   D.SET_COUNT
					WHERE       S.INPUT_FILE_SCAN_ONLY  =   'NO'
					AND         S.BACKUP_TYPE           IN  ('D', 'I')
					AND         D.CONTROLFILE_INCLUDED  =   'NO'
					AND         D.SESSION_RECID         =   RS.SESSION_RECID
					AND         D.SESSION_STAMP         =   RS.SESSION_STAMP
				) AS INCREMENTAL_LEVEL,
				STATUS,
				TO_CHAR(START_TIME, 'DD/MM/YYYY HH24:MI:SS') AS START_TIMES,
				TO_CHAR(END_TIME, 'DD/MM/YYYY HH24:MI:SS') AS END_TIME,
				CAST(INPUT_BYTES/1024/1024 AS NUMERIC(12,2)) AS INPUT_MB,
				CAST(OUTPUT_BYTES/1024/1024 AS NUMERIC(12,2)) AS OUTPUT_MB
	FROM     V$RMAN_STATUS RS
	WHERE    OBJECT_TYPE   IN  ('DB FULL', 'DB INCR', 'BACKUPSET', 'BACKUP BACKUPSET')
	AND      OPERATION     =    'BACKUP'
	AND      START_TIME    >=  (SYSDATE - 7)
	ORDER BY START_TIME;

-- !Roda essa primeiro
 
set lines 300
col STATUS format a22
col hrs format 999.99
select
SESSION_KEY, SESSION_RECID, SESSION_STAMP,INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
elapsed_seconds/3600 hrs
from V$RMAN_BACKUP_JOB_DETAILS
order by session_key;
 
 
-- !Depois executa esse colocando a informação que pedir após dar enter
 
 
set lines 200
set pages 1000
select output from GV$RMAN_OUTPUT
where session_recid = &SESSION_RECID
and session_stamp = &SESSION_STAMP
order by recid;


set pages 200
 set lines 200
 col START_TIME for a20
 col END_TIME for a20
 col OUTPUT_BYTES_DISPLAY for a15
 col TIME_TAKEN_DISPLAY for a20
 select session_key,
       input_type,
       status,
       to_char(start_time,'yyyy-mm-dd hh24:mi') start_time,
       to_char(end_time,'yyyy-mm-dd hh24:mi')   end_time,
       output_bytes_display,
       time_taken_display, output_device_type
from v$rman_backup_job_details
where end_time > sysdate -30
and input_type like 'DB FULL'
--or input_type like 'DB INCR'
order by session_key asc;
