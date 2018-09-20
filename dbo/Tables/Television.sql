CREATE TABLE [dbo].[Television] (
    [TVCode]   NVARCHAR (100) NOT NULL,
    [TVName]   NVARCHAR (100) NULL,
    [Decoder]  NVARCHAR (100) NULL,
    [Country]  NVARCHAR (100) NULL,
    [IsActive] BIT            NOT NULL,
    [Color]    NVARCHAR (20)  DEFAULT ('#444') NOT NULL,
    CONSTRAINT [PK_Television] PRIMARY KEY CLUSTERED ([TVCode] ASC)
);

