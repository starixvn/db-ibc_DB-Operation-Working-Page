/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/*
Created: 20200710@Esther
Task : Event Upload- Importing match in Neutral Stadium (N)
DB: bodb_OWP	

Revisions:
	20200710@Esther: New structure of Event Upload - [Redmine: #137417]
*/

ALTER TABLE OWPMatch
ADD IsNeutral BIT NOT NULL
                  CONSTRAINT DF_OWPMatch_IsNeutral DEFAULT 0 WITH VALUES;
ALTER TABLE InfositeMatch
ADD IsNeutral BIT NOT NULL
                  CONSTRAINT DF_InfositeMatch_IsNeutral DEFAULT 0 WITH VALUES;


CREATE TABLE [dbo].[AssignmentUploadHistory](
	[UploadDateId] [int] IDENTITY(1,1) NOT NULL,
	[UploadDateTime] [datetime] NOT NULL,
	[EventDate] [date] NOT NULL,
 CONSTRAINT [PK_UploadHistory] PRIMARY KEY CLUSTERED 
(
	[UploadDateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO



