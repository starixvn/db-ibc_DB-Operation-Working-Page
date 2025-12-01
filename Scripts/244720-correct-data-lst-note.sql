/*<info serverAlias="DBOWP-bodb_OWP" executers="wsv_owp" isFunction="0"></info>*/

/*
Created: 20251201@Frankie
Task : Correct data lst note
DB: bodb_OWP
*/
USE bodb_OWP;
GO;

UPDATE dbo.EventPicking WITH (ROWLOCK, UPDLOCK)
SET LSTNote = 'South east Asia (D1) - Refer SB: Vietnam, Thailand, Indonesia.. /  CF play in TURKEY: Div MJ vs MJ or MJ vs M1 (Offer), the rest (Cancel)'
WHERE Id = 208030;