CREATE TABLE [dbo].[LSTReport] (
    [ReportDate]              DATE               NULL,
    [UserId]                  INT                NULL,
    [Username]                VARCHAR (50)       NULL,
    [SectionId]               INT                NULL,
    [SectionName]             NVARCHAR (50)      NULL,
    [TotalMatch]              INT                NULL,
    [Type1_FT_HDP]            INT                NULL,
    [Type1_FT_OU]             INT                NULL,
    [Type1_FT_HDPOU]          INT                NULL,
    [Type2_AUS_League]        INT                NULL,
    [Type2_AUS_League_Corner] INT                NULL,
    [Type2_JAP_Divison1]      INT                NULL,
    [Type2_JAP_Divison2]      INT                NULL,
    [Robot3_X2]               INT                NULL,
    [Robot3_X3]               INT                NULL,
    [Robot3_X3_Plus]          INT                NULL,
    [Type3_Solo_Major]        INT                NULL,
    [Type4_Major]             INT                NULL,
    [Type4_Minor1]            INT                NULL,
    [Type4_Minor2]            INT                NULL,
    [Type4_Minor3]            INT                NULL,
    [Type4_1ST_Major]         INT                NULL,
    [Type4_1ST_Other]         INT                NULL,
    [Type4_Fantasy]           INT                NULL,
    [Type4_Corner_NextCorner] INT                NULL,
    [Type4_15M]               INT                NULL,
    [Type4_10M]               INT                NULL,
    [Type4_TotalBooking]      INT                NULL,
    [Type4_PKSO]              INT                NULL,
    [Type4_Winner]            INT                NULL,
    [PH_1X2_Major]            INT                NULL,
    [PH_1X2_Minor1]           INT                NULL,
    [PH_1X2_Minor2]           INT                NULL,
    [PH_1X2_Minor3]           INT                NULL,
    [PH_1X2_Others]           INT                NULL,
    [X5]                      INT                NULL,
    [TurnOver_FT_HDP]         INT                NULL,
    [TurnOver_FT_OU]          INT                NULL,
    [TurnOver_1H_HDP]         INT                NULL,
    [TurnOver_1H_OU]          INT                NULL,
    [TurnOver_Others]         INT                NULL,
    [WinLoss_FT_HDP]          INT                NULL,
    [Winloss_FT_OU]           INT                NULL,
    [Winloss_1H_HDP]          INT                NULL,
    [Winloss_1H_OU]           INT                NULL,
    [Winloss_Others]          INT                NULL,
    [CreatedDate]             DATETIMEOFFSET (7) NULL
);










GO
CREATE CLUSTERED INDEX [IX_ReportDate_UserId_LSTReport]
    ON [dbo].[LSTReport]([ReportDate] ASC, [UserId] ASC);

