/****** Object:  StoredProcedure [dba].[UpdateCostructload]    Script Date: 7/14/2015 8:17:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Yuliya Locka
create procedure dba.UpdateCostructload
as
update   dba.costructload
set [desc]= left([desc],LEN([desc])-1)
where substring( [desc],LEN([desc]),1) =','


GO
