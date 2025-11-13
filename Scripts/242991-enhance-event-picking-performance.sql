/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251111@Los
Task : Enhance event picking performance
DB: bodb_OWP

Revisions:
	20251111@Los: Enhance event picking performance - [Redmine: #242991]
*/
USE bodb_OWP;
GO

CREATE NONCLUSTERED INDEX IX_MaxbetHdp_SpreadHdp_SpreadOu_NoOfHDP_LSTNote_Remark2_MaxbetOu
ON [dbo].[EventPicking] (
[InfositeMatchId]) 
INCLUDE (
[MaxbetHdp],
[SpreadHdp],
[SpreadOu],
[NoOfHDP],
[LSTNote],
[Remark2],
[MaxbetOu])

CREATE NONCLUSTERED INDEX IX_InfositeId
ON [dbo].EventPickingConfirmed(
InfositeId
)

CREATE NONCLUSTERED INDEX IX_ParentId
ON [dbo].[EventPickingChildMatch] (
[ParentId]
) 
INCLUDE(
	[MinorBettypeId],
	[MaxbetHdp],
	[MaxbetOU],
	[SpreadHdp],
	[SpreadOu],
	[NoOfHDP]
)