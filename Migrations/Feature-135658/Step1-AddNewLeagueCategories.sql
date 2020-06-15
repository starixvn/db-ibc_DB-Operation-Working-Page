USE [bodb_OWP]
GO

ALTER TABLE [dbo].[NewLeagueSetting]
ALTER COLUMN TV NVARCHAR(200)
GO

ALTER TABLE [dbo].[NewLeagueSetting]
ALTER COLUMN LSTNote NVARCHAR(500)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LeagueCategory'
           ,7
           ,N'Others 1'
           ,0)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LeagueCategory'
           ,8
           ,N'Others 2'
           ,0)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LeagueCategory'
           ,9
           ,N'Others 3'
           ,0)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LeagueCategory'
           ,10
           ,N'Others 4'
           ,0)
GO

INSERT INTO [dbo].[RefResource]
           ([RefName]
           ,[ResourceId]
           ,[Value]
           ,[Order])
     VALUES
           (N'LeagueCategory'
           ,11
           ,N'Others 5'
           ,0)
GO

UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 161
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 97
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 190
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 101
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1859
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1681
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 144
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 3058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1692
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2847
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2410
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19708
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 17968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 17973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5892
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 8494
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8210
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9189
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2965
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3035
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2876
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 529
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8540
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 9625
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 8394
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 18003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 18008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 18018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 23563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 547
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 6293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 584
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 731
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 646
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 699
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9875
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 9926
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 3142
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 10214
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 13362
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6910
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3091
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9171
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 9270
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 9388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 17983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 8580
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 10289
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7575
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 5728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1747
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 18208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 607
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 18243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 661
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 9411
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 305
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1799
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 872
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 84
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 337
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2090
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 182
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2294
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9406
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 18298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 600
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 1901
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 685
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 7545
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2624
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 239
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1716
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 299
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1090
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6599
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 240
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 241
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1669
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 196
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 890
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 904
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 931
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1147
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2912
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 9166
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2695
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 780
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 777
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 974
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7929
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 781
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15562
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 919
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1120
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7576
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1426
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2721
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 892
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 204
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 232
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1906
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 986
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 925
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 951
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3044
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 954
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1621
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1324
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1427
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 977
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 982
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2367
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1032
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2827
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 889
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9726
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7589
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 981
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7707
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2437
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14257
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1517
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15945
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 712
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 666
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 129
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 834
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2601
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7497
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 711
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2411
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1071
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 2896
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 36
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 7411
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 2899
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 71
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 72
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 73
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7590
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 82
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1371
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2714
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3201
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 249
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 662
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 351
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5862
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18648
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 729
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 18653
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 6180
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2631
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 329
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 49
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 667
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18663
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2900
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2704
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 18693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2696
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3080
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2801
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8127
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3172
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 134
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 166
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18718
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3100
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9120
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 51
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 992
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 969
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1121
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1414
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2504
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1689
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 98
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1150
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 224
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 997
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2009
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1110
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 189
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 580
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1151
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 85
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2591
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 340
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18773
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 157
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2247
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5731
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 845
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 944
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1372
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 115
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1910
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1577
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1722
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2789
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15589
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13320
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2094
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 641
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1660
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1152
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2427
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 467
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 18823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8209
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10304
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10305
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 630
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1710
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1006
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1909
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7390
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 642
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 930
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2731
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 3163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3194
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 2198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 631
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1576
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7305
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7990
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8272
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 632
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 994
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2130
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 634
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 439
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1094
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1314
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 654
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 627
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 625
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2525
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 86
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 669
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2831
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 410
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2160
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 492
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 976
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 15693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1690
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18853
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 587
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2165
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 405
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 644
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18913
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 6284
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 709
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1987
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5449
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2175
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 152
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2100
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1040
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8104
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5972
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18783
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 52
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1262
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 37
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18928
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1156
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9710
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 905
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7500
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1479
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 720
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 721
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10075
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 18998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 116
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 19003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 791
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 610
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8300
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 12869
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2867
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1802
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 457
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 774
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 112
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1749
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 490
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2339
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 894
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 985
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1327
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19095
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9032
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1017
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 844
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 19128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6024
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 63
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 8061
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 9482
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 114
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 325
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 696
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1430
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 19188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 19178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 19183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 159
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 10189
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 17988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2005
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8589
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 19448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 577
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2269
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12260
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8355
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 19498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6010
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 431
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 494
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2920
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 87
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 896
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 8895
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 38
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7126
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2829
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 19578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6451
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5819
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 3169
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 995
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 221
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2217
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 259
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 871
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 53
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 7861
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 54
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8269
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 989
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1020
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 990
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 971
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1532
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 831
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 805
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2526
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8572
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 12197
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 55
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1264
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 146
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1567
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 74
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1021
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 75
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 865
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19653
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19648
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 749
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 751
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19663
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 841
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 952
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 842
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1339
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1670
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3104
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1560
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7297
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 924
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 965
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2371
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1079
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1996
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3089
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19713
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19716
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 14725
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 56
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 914
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 12090
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2234
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1432
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 374
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 140
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5467
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 117
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 324
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9725
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 544
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2095
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 590
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 411
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 344
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1911
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 435
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 191
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19813
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 15627
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 282
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 280
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10124
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10034
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 346
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 175
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19773
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 212
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 2
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 19863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 257
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1267
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1270
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 284
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1271
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 2091
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3179
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3180
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1265
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2027
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3129
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 335
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 336
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 19803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 357
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 14757
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19853
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 19838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 1375
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 194
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 19873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 19868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 1317
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 260
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 19883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 19878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 591
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 461
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 459
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 486
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 286
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 460
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19913
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 19918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3069
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11067
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19928
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 88
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1340
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1341
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 50
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 147
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 850
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1942
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 482
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1561
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 17421
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2606
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1350
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 3125
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7289
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 19998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 17998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11617
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1912
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 145
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 46
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1342
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 43
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 40
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 57
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1351
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1166
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1415
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6519
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 572
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 695
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1486
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1019
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1501
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 694
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 2296
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 20073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1639
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 20083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 441
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 522
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 20138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 20148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 454
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 89
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 1502
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 90
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1487
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2926
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 9017
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 310
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 500
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 426
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1711
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 402
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10086
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 8152
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 962
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 922
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2457
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 13020
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 59
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 67
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1521
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1065
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 68
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1506
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 58
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 701
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1592
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 909
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1099
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7644
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 20313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 847
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 744
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1534
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 60
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 254
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 64
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 69
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 83
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3175
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 15866
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 562
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3176
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1077
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5830
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 250
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1174
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2532
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1175
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 355
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3042
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9975
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 9486
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10167
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 307
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3131
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 12734
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 570
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 404
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2266
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 495
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 195
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 496
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3134
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 20418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2886
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6081
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 184
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 20473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 92
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 91
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1344
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 264
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 269
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 579
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1014
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 576
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2932
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 252
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 121
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 3170
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 246
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 6237
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 20488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 24
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 677
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 390
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 379
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 531
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 705
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 736
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 787
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 807
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 839
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 870
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1024
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1439
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1524
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1456
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1600
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1276
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 427
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 767
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 7187
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 7220
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1277
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 504
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 485
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2569
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1552
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1196
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 93
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1490
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7212
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 12366
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1562
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2322
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2934
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1970
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1891
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 17
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7469
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6257
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 385
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3046
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2476
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2162
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 3157
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9219
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 165
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2170
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18708
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9522
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2821
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 717
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1176
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9274
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 19138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2302
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2719
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2039
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 9091
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 1 WHERE [OWPLeagueId] = 20623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9045
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20653
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20663
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 20673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20708
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20713
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20718
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20773
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20783
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2897
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 452
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2585
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 386
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13826
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 415
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 171
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 105
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 104
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1029
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2272
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 687
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 20838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10261
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 330
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1034
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1346
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 207
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1457
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 371
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1197
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 334
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1892
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1982
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 185
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9487
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20853
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 637
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 804
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7775
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 20873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 462
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1915
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 2640
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 502
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1102
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1914
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2734
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 354
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2285
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 99
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1475
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20913
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5426
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1642
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 271
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 319
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2136
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 20953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 20958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 235
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 927
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1004
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 849
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 984
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1075
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1122
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9787
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2040
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 20973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6126
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2257
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7166
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 20993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 862
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 180
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 30
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3040
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6269
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 946
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1334
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1097
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7552
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7406
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2002
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 2435
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2442
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 14
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1587
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 891
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 130
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 132
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 21083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 11226
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 399
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1491
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1382
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9022
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 897
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1089
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 349
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 592
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 551
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1719
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 3015
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 690
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 822
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 549
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 15494
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 469
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 265
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 6144
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11675
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6676
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8414
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1844
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 6786
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 3106
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8956
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 125
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 122
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1960
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1955
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1956
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1780
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 526
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6800
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 6305
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6411
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1180
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7259
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 15009
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 830
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 141
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 856
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 94
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1920
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 277
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 546
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6780
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8469
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6217
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 3151
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2041
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 229
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 127
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 234
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1581
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1061
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2686
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1060
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7547
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8416
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9246
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 100
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 586
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 790
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 274
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1044
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1010
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1235
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 32
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 28
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1111
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1335
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2636
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1091
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1109
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1925
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1107
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1564
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 487
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 837
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9549
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3060
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9490
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 416
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 174
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2952
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6947
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8812
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3191
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21648
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9154
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9190
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9175
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21653
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21663
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 126
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2894
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 230
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1012
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 15140
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6911
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6127
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21708
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21713
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21718
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 835
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 876
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 25
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 864
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 61
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1281
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2840
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 964
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1282
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 14865
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2570
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21773
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 437
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21783
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3184
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6897
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 394
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 160
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 392
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 109
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 222
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2015
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3071
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7007
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1582
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 757
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 8974
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 192
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2330
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21813
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2540
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6395
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2574
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2919
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1977
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 181
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21853
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1364
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 47
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 970
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 832
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 895
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2534
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 21908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21913
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 718
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 48
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 34
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2901
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8900
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1402
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2820
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 10092
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 21953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 209
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10559
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 21968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5797
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 6283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 21973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 9031
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1846
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2907
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 290
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1410
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1766
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 561
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 291
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1366
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 292
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1367
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 789
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5445
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 106
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 22053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1337
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3047
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3070
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3145
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3144
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1667
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 979
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2194
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12604
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 95
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2539
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 929
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10191
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7876
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 857
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 22118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7430
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 7094
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 22123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 1546
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1671
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2479
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 910
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1201
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9685
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 955
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1007
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1066
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2609
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 940
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 991
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 960
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1547
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1184
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1854
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 300
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2710
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 934
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 216
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 215
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 96
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 5500
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5567
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2694
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 12759
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 12784
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 760
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 10
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8347
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8764
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1554
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 770
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8475
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 155
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6156
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 339
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 2993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1566
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 22243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 22238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 22248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1629
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 301
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1445
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 79
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1446
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2182
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 419
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1540
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 7330
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2736
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7941
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 22298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8776
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15629
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 350
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 18728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1945
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 9316
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 1185
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 1245
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 22368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 22373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 22363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 1285
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 80
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 81
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2446
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2531
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7401
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 947
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1612
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2749
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9830
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2699
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 762
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1286
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1575
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 2 WHERE [OWPLeagueId] = 682
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 681
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 8332
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 912
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 911
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 879
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 22398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1095
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 377
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 22438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22468
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 556
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2924
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 22483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1674
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2796
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 1777
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22723
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 645
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 886
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7746
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2289
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 802
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 302
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6165
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 722
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 652
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 665
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 22558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 424
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6541
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6534
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22648
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22653
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22663
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22673
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22675
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 7333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6544
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1997
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22698
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22703
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22708
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22713
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22718
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 231
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 2097
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22728
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2880
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1632
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22743
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22758
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3025
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22768
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22773
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22783
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 796
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7456
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22808
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 436
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22813
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22823
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22848
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 18313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 22853
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22863
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22873
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22883
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 107
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 220
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2638
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1835
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 169
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22888
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22893
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 22908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22913
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22928
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5636
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8032
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9580
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22968
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 22988
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 389
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2444
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23003
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 22993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 13724
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 13725
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 33
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 369
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23008
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 211
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 210
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23013
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23018
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 23023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 23028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 23038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 23033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 384
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 2333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2192
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 575
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 262
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6899
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6254
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2917
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23048
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23053
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23058
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23073
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23098
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7864
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3167
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 8909
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1041
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 8524
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 7331
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23103
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1043
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2957
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23123
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23128
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23133
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3150
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8955
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1530
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 9533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 149
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1740
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 15
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1770
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 62
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1771
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1356
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1101
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1189
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 26
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1450
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 12569
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23213
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23218
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23243
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23263
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23268
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1451
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23273
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23283
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 706
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1584
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 256
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 935
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2342
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 119
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 23303
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 3 WHERE [OWPLeagueId] = 23298
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7865
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23308
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 118
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1516
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23328
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 670
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2524
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7014
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2752
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 3168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3051
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23343
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 1589
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 671
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 656
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 684
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23373
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 1295
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23378
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2063
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 137
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 5948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 391
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 425
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1384
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1051
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 465
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2187
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1850
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6035
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 2338
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 3027
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23403
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23408
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 10170
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23418
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23428
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23423
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 227
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 724
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 567
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 564
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 8 WHERE [OWPLeagueId] = 23443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23448
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2909
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23458
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 9168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2947
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23473
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1072
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23493
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2582
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 1668
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23478
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23483
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 4 WHERE [OWPLeagueId] = 766
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 764
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23488
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2845
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 581
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 550
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 1542
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2647
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3177
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2688
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23498
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23518
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 23513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 23523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23503
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 2955
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23528
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 20173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23533
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 22568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23553
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23558
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23588
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 23593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 23608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 7 WHERE [OWPLeagueId] = 23613
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 21078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 242
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20928
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19983
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17943
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17948
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17953
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18028
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18038
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22078
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23623
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 6828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7619
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7219
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 21368
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 18713
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7745
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7744
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 267
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7751
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7862
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 6278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 7915
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7450
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7616
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 18353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8339
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8361
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 7710
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 15921
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8482
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8525
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8526
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8599
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8444
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8161
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8590
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 3156
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8640
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 11 WHERE [OWPLeagueId] = 8672
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8756
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21633
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 8162
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 8858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 2497
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 9 WHERE [OWPLeagueId] = 8910
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8976
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9009
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9033
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 9055
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9096
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9155
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 10 WHERE [OWPLeagueId] = 8568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9224
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9325
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9247
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8954
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9335
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9326
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9342
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9460
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9532
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9425
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9417
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9551
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9982
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 9540
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = 5 WHERE [OWPLeagueId] = 5929
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9334
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9567
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9606
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9691
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9597
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9611
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 746
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9636
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9624
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9707
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2858
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2527
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9714
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16111
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6020
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9790
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9642
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9643
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9644
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9764
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10020
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10037
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9979
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10099
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10096
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10150
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10104
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13745
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9594
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8367
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9867
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10211
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10216
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10219
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23233
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10292
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12222
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12217
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23258
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9930
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10235
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20648
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20753
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10570
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11211
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11030
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11535
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11620
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11514
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11985
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20543
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12040
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11699
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12065
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11780
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11826
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12646
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12304
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12381
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11803
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11164
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12370
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12548
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18878
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12636
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12610
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12697
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12725
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12108
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5950
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18793
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12927
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11429
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12951
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12973
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13026
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13042
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13025
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13062
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12958
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13065
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13075
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13134
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 585
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12926
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13255
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13241
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13224
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 7379
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18828
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9866
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14361
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20208
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13541
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13512
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13735
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13740
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13611
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13850
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13719
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13840
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13845
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15205
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 432
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13825
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13634
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13714
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9972
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1505
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14444
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6757
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14191
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10021
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6032
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23333
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9874
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14025
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13310
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13929
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13939
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14000
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 471
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13866
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10239
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13857
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13856
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13855
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14139
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14192
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 1776
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14238
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10236
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14171
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14023
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14665
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9919
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14504
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 697
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14531
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14476
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14248
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14455
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10280
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11680
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14398
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14699
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14694
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14538
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12932
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 11223
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15380
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13083
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14362
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15510
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15971
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18433
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18393
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18438
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18463
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15976
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18573
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18583
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18598
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15696
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18603
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18608
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8472
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 8412
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10306
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18778
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15556
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18813
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10276
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18838
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18908
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10115
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15701
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16169
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14724
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 18993
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9998
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 763
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19093
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15617
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17935
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19593
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9942
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19783
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19818
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 19978
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15557
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9715
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14499
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2515
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 554
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20348
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20353
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20358
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20363
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10090
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20388
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20413
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13615
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9809
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20813
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20833
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2031
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 20843
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15112
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 12143
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10094
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21138
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21228
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14974
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21253
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 5693
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21383
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10169
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21523
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 288
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21563
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21568
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21578
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21658
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15709
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21733
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21738
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21748
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21898
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21903
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21918
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21923
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21928
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21933
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9678
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 21938
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14443
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 2513
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13319
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13084
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22313
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22323
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15065
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16591
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16425
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10067
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10068
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23088
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23148
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23153
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23158
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23168
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23173
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23178
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23183
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23188
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23193
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23198
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23203
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15868
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14359
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23278
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 23293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 13085
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14751
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10279
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14780
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14766
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14827
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14789
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14929
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14994
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15234
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14554
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15113
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15163
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15215
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15287
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15318
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15282
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15252
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 14829
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 814
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15396
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 10139
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15382
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22293
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 6087
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 9798
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15628
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15672
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 15944
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16086
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16087
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16081
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 22453
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16552
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16502
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16167
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16216
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16265
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16217
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16683
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16830
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16618
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16597
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16507
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16508
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16509
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16510
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16530
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16531
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16702
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16862
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16786
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16787
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16788
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 17963
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16869
GO
UPDATE [dbo].[OWPLeague] WITH (ROWLOCK) SET [CategoryId] = null WHERE [OWPLeagueId] = 16926
GO