INSERT INTO ModuleObject(ModuleObjectId,ModuleObjectName,ModuleId)
VALUES(33,'SpecialProduct',9)

INSERT INTO LogAction(ActionId,ModuleId,ModuleObjectId,ActionTypeId,ActionName,SPName,LogItems)
VALUES(109,9,33,1,'OWPSpecialProductInsert','OWP_SpecialProductInsert','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(110,9,33,2,'OWPSpecialProductUpdate','OWP_SpecialProductUpdate','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(111,9,33,3,'OWPSpecialProductDelete','OWP_SpecialProductDelete','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(112,9,33,3,'OWPSpecialProductDelete_Row','OWP_SpecialProductDeleteRow','<root><xml path="r/z" /><row item="Id" alias="pid" /><row item="FTHDP" alias="fthdp" /><row item="MBNoOfCorner" alias="mbnoofcorner" /><row item="SpreadNoOfCorner" alias="spreadnoofcorner" /><row item="MBNextCorner" alias="mbnextcorner" /><row item="SpreadNextCorner" alias="spreadnextcorner" /><row item="MB1015Mins" alias="mb1015mins" /><row item="Spread1015Mins" alias="sp1015mins" /><row item="MBTotalBooking" alias="mbtb" /><row item="SpreadTotalBooking" alias="spreadtb" /><row item="MBNextTotalBooking" alias="mbntb" /><row item="SpNextTotalBooking" alias="spreadntb" /><row item="MBPenaltyShootout" alias="mbps" /><row item="SpreadPenaltyShootout" alias="spreadps" /><row item="MBWinner" alias="mbwinner" /><row item="SpreadWinner" alias="spreadwinner" /><row item="Remark" alias="remark" /></root>')



