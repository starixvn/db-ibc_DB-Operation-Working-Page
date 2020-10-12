-- backup
/*

USE bodb_OWP_NEW;
GO
CHECKPOINT

CREATE DATABASE bodb_OWP_NEW_snapshot ON
 (NAME = bodb_OWP, FILENAME = 'D:\IBC_DB\bodb_OWP_New\bodb_OWP_snapshot.ss')
, (NAME = OWP_Data, FILENAME = 'D:\IBC_DB\bodb_OWP_New\OWP_Data_snapshot.ss')
, (NAME = OWP_Index, FILENAME = 'D:\IBC_DB\bodb_OWP_New\OWP_Index_snapshot.ss')
AS SNAPSHOT OF bodb_OWP_NEW

*/

-- restore
/*

USE master;
RESTORE DATABASE bodb_OWP_NEW FROM DATABASE_SNAPSHOT = 'bodb_OWP_NEW_snapshot';

*/