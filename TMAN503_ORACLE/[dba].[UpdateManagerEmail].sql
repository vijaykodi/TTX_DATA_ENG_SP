/****** Object:  StoredProcedure [dba].[UpdateManagerEmail]    Script Date: 7/14/2015 8:12:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure  dba.UpdateManagerEmail
as
update e
set e.MangerEmailAddress = m.Email
from dba.employee e inner join  dba.employee m
on e.ManagerGlobalID = m.GlobalEmployeeID
GO
