
/*<info serverAlias="DBOWP-bodb_OWP" executers="bodbOWPNet" isFunction="0"></info>*/

CREATE PROCEDURE [dbo].[OWP_Feedback_GetFunctionFeedback]
AS

/*      
 Created: 20230925@Johnny
 Task : Get Function Feedback
 DB: bodb_OWP      

 Revisions:
	20230925@Johnny: Init Sp - [Redmine: #193811]      
*/

    BEGIN
        SET NOCOUNT ON;
        SELECT rr.ResourceId AS FunctionId, 
               rr.[Value] AS FunctionName
        FROM RefResource AS rr
        WHERE rr.RefName = 'FunctionFeedback';
    END;