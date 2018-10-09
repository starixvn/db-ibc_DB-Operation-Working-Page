CREATE TABLE [dbo].[Television] (
    [TVId]   INT            IDENTITY (1, 1) NOT NULL,
    [TVCode] NVARCHAR (100) NOT NULL,
    [Color]  VARCHAR (20)   CONSTRAINT [DF_Television_Color] DEFAULT ('#444') NOT NULL,
    CONSTRAINT [PK_Television] PRIMARY KEY CLUSTERED ([TVId] ASC)
);



