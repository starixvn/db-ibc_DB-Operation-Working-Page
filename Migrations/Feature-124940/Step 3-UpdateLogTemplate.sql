/*
	Created: Carlos.Nguyen
	Date: 20191206
	Task: Update language [Redmine: #124940]
	DB: bodb_OWP
*/

UPDATE LogAction
  SET LogItems='<root><xml path="r/z" />    <row item="FullName" alias="fn" />    <row item="NickName" alias="nn" />    <row item="EmployeeId" alias="eid" />    <row item="CategoryId" alias="ca" />    <row item="Extension" alias="ex" />    <row item="Phone" alias="p" />    <row item="Email" alias="e" />    <row item="Skype" alias="s" />    <row item="DepartmentId" alias="d" />    <row item="SectionId" alias="sec" />    <row item="GroupId" alias="grp" />    <row item="RoleId" alias="r" />    <row item="LocationCode" alias="lo" />    <row item="LanguageId" alias="lang" />    </root>'
  WHERE ActionId=58