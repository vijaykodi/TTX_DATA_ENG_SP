/****** Object:  StoredProcedure [dbo].[p_LinkAllDataChangeRecords]    Script Date: 7/14/2015 7:36:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE p_LinkAllDataChangeRecords AS BEGIN UPDATE t1 set t1.eventId=t2.eventId FROM DataChanges t1 INNER JOIN (SELECT * from Events where eventCategory=4) t2 ON (t1.startTime >= t2.startTime AND t1.startTime <= t2.endTime AND t1.eventSequence >= t2.startSequence AND t1.eventSequence <= t2.endSequence AND t1.spid = t2.spid) WHERE t1.eventId IS NULL UPDATE t1 set t1.dcId=t2.dcId FROM ColumnChanges t1 INNER JOIN DataChanges t2 ON (t1.startTime = t2.startTime AND t1.eventSequence = t2.eventSequence AND t1.spid = t2.spid) WHERE t1.dcId IS NULL END
GO
