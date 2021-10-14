
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/
/*
Created: 20211014@Mira
Task : Overtime Report
DB: bodb_OWP	

Revisions:
	20211014@Mira: Create tables for overtime report - [Redmine: #162821]
*/

-- Table Overtime Report
IF OBJECT_ID('dbo.OvertimeReport', 'U') IS NOT NULL
    DROP TABLE dbo.[OvertimeReport]; 
GO
CREATE TABLE [dbo].[OvertimeReport](
	[ReportDate] [date] NOT NULL,
	[TraderId] [int] NOT NULL,
	[TraderName] [varchar](30) NULL,
	[Hour] [float] NULL,
	[IsOffDay] [bit] NULL,
	[IsWeekend] [bit] NULL,
	[DayOfWeek] [nchar](20) NULL,
 CONSTRAINT [PK_OvertimeReport] PRIMARY KEY CLUSTERED 
(
	[ReportDate] ASC,
	[TraderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [OWP_Data]
) ON [OWP_Data]
GO
