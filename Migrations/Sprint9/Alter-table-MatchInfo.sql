ALTER TABLE dbo.MatchInfo ADD NoOfHDPId INT DEFAULT(0)
GO

update MatchInfo set NoOfHDPId =1 where NoOfHDP='1HDP'
update MatchInfo set NoOfHDPId =2 where NoOfHDP='2HDP'
update MatchInfo set NoOfHDPId =3 where NoOfHDP='2+1H'
update MatchInfo set NoOfHDPId =4 where NoOfHDP='3HDP'
GO