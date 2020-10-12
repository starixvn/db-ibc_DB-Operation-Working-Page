USE [bodb_OWP]
GO

/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

/* SECTION */
UPDATE [dbo].[RefResource] SET  [Value] = 'R&D CSD' WHERE  [ResourceId] = 22 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Licensee CSD' WHERE  [ResourceId] = 19 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Automation' WHERE  [ResourceId] = 14 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'EST' WHERE  [ResourceId] = 1 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Live Assistant-VN' WHERE  [ResourceId] = 2 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Live Trading-VN' WHERE  [ResourceId] = 3 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'LST' WHERE  [ResourceId] = 15 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Management' WHERE  [ResourceId] = 4 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Fraud & Keyscore' WHERE  [ResourceId] = 13 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Risk & Support' WHERE  [ResourceId] = 5 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Pre-Match' WHERE  [ResourceId] = 21 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Supportive' WHERE  [ResourceId] = 18 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'OPS Admin' WHERE  [ResourceId] = 7 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Other Sports' WHERE  [ResourceId] = 20 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'OSST' WHERE  [ResourceId] = 23 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'PH VN-Site' WHERE  [ResourceId] = 8 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'PM' WHERE  [ResourceId] = 16 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'PO' WHERE  [ResourceId] = 17 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Basketball' WHERE  [ResourceId] = 6 AND [RefName] = N'Section'
UPDATE [dbo].[RefResource] SET  [Value] = 'Virtual Team' WHERE  [ResourceId] = 12 AND [RefName] = N'Section'
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 24, N'Esports')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 25, N'Cricket')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 26, N'B2C CSD')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 27, N'Credit CSD')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 28, N'Live Trading-PH')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 29, N'PH PH-Site')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Section', 30, N'Live Assistant-PH')

/* DEPARTMENT */
UPDATE [dbo].[RefResource] SET  [Value] = 'LICENSEE' WHERE  [ResourceId] = 3 AND [RefName] = N'Department'
UPDATE [dbo].[RefResource] SET  [Value] = 'CASINO & EXTERNAL' WHERE  [ResourceId] = 4 AND [RefName] = N'Department'
UPDATE [dbo].[RefResource] SET  [Value] = 'OTHER SPORTS' WHERE  [ResourceId] = 2 AND [RefName] = N'Department'
UPDATE [dbo].[RefResource] SET  [Value] = 'SOCCER' WHERE  [ResourceId] = 1 AND [RefName] = N'Department'
UPDATE [dbo].[RefResource] SET  [Value] = 'OTHERS' WHERE  [ResourceId] = 5 AND [RefName] = N'Department'
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 6, N'R&D')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 7, N'SUPPORT & VR')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 8, N'GO')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 9, N'AUTOMATION')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 10, N'POOL HOUSE')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 11, N'BASKETBALL')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 12, N'CRICKET')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 13, N'ESPORTS')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 14, N'B2C')
INSERT INTO [dbo].[RefResource]([RefName],[ResourceId],[Value]) VALUES (N'Department', 15, N'CREDIT')
