/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251203@Frankie
Task : Rename dept and section
DB: bodb_OWP
*/
USE bodb_OWP;
GO;

  UPDATE dbo.RefResource WITH (ROWLOCK, UPDLOCK)
  SET value = 'SP'
  WHERE refname = 'Department' and value = 'CASINO & EXTERNAL';

  UPDATE dbo.RefResource WITH (ROWLOCK, UPDLOCK)
  SET value = 'C&E' 
  WHERE refname = 'Section' and value = 'Casino & External';