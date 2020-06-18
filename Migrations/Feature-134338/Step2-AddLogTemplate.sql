INSERT INTO ModuleObject(ModuleObjectId,ModuleObjectName,ModuleId)
VALUES(33,'SpecialProduct',9)

INSERT INTO LogAction(ActionId,ModuleId,ModuleObjectId,ActionTypeId,ActionName,SPName,LogItems)
VALUES(109,9,33,1,'OWPSpecialProductInsert','OWP_SpecialProductInsert','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(110,9,33,2,'OWPSpecialProductUpdate','OWP_SpecialProductUpdate','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
,(111,9,33,3,'OWPSpecialProductDelete','OWP_SpecialProductDelete','<root><xml path="r/z" /><row item="Product" alias="p" /><row item="Value" alias="vl" /></root>')
