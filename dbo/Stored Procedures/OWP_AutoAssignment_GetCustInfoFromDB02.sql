
/*<info serverAlias="DBACC-bodb02" executers="bodbAdminNet" isFunction="0"></info>*/

CREATE PROCEDURE OWP_AutoAssignment_GetCustInfoFromDB02
AS

/*
Created: 20210225@Tyler
Task : Get users for auto assignment
DB: bodb02

Revisions:
	20210225@Tyler: Initial - [Redmine: #150268]
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT ci.custid
        FROM dbo.custInfo AS ci WITH(NOLOCK)
        WHERE ci.closed = 0
              AND ci.reject = 0
              AND ci.[Enabled] = 1;
    END;
GO