/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/
/*
Created: 20250303@Frankie
Task :  add new update type
DB: bodb_OWP

Revisions:
    20250303@Frankie: Insert update type: provider, total round - [Redmine: #218237]
*/

INSERT [dbo].[EventPickingUpdateType] ([Id], [UpdateType], [RAndDUpdate], [Group]) VALUES (55, N'Update Provider', N'Update Provider',N'Provider')
INSERT [dbo].[EventPickingUpdateType] ([Id], [UpdateType], [RAndDUpdate], [Group]) VALUES (56, N'Cancel Provider', N'Cancel Provider',N'Provider')
INSERT [dbo].[EventPickingUpdateType] ([Id], [UpdateType], [RAndDUpdate], [Group]) VALUES (57, N'Update Total Round', N'Update Total Round',NULL)
INSERT [dbo].[EventPickingUpdateType] ([Id], [UpdateType], [RAndDUpdate], [Group]) VALUES (58, N'Cancel Total Round', N'Cancel Total Round',NULL)