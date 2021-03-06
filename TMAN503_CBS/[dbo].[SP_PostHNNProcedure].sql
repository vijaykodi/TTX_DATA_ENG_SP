/****** Object:  StoredProcedure [dbo].[SP_PostHNNProcedure]    Script Date: 7/14/2015 7:51:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_PostHNNProcedure]
@BeginIssueDate datetime,
@EndIssueDate datetime

AS
BEGIN
--Creater: Nina Lutz
--Create Date: 04/02/2013
--Modifier:  Tonya True
--Modified date: 01.03.2014
--Modified:  Added for CBS per Case#26857

DECLARE @Iata varchar(50), @ProcName varchar(50), @TransStart datetime

	SET @Iata = 'ALL'
	SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))

-- Any and all edits can be logged using sp_LogProcErrors 
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
--  @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
--	@LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the beginning of a transaction
--	@StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
--	@BeginDate datetime = NULL, -- **OPTIONAL** The BeginIssueDate that is passed to the Parent Procedure
--	@EndDate datetime = NULL, -- **OPTIONAL**	The EndIssueDate that is pased to the Parent Procedure
--	@IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
--	@RowCount int, -- **REQUIRED** Total number of affected rows
--	@ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)




 /************************************************************************
                LOGGING_START - BEGIN
				----------------------
--=======================================--
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--[SP_PostHNNProcedure]
************************************************************************/
--R. Robinson modified added time to stepname
--declare @TransStart DATETIME declare @ProcName varchar(50)
--SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()

declare @tmpStepName nvarchar(50) = 'Stored Procedure Started logging '
declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 

 --select substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_START - END
************************************************************************/



--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Post HNN Stored Procedure Start',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


/*	Adding the Hotel Cap updates to the beginning of this stored procedure so that I
	have clean data prior to running my updates.....5/12/14 by Nina per Case 00035845  */

/* Update 2014 Hotel Caps for division CBS Entertainment for Specific Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */ 
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco')
and ht.HtlCityName = hc.City
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Entertainment'
and hc.Division = 'CBS Entertainment'

/* Update 2014 Hotel Caps for division CBS Entertainment for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Entertainment'
and hc.Division = 'CBS Entertainment'

/* Update 2014 Hotel Caps for division CBS Entertainment for Washington DC */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'Washington%'
and ht.HtlState = 'DC'
and hc.City = 'Washington DC'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Entertainment'
and hc.Division = 'CBS Entertainment'

/* Update 2014 Hotel Caps for division CBS Entertainment for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCityName not in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco','Washington DC','Washington')
or ht.HtlCityName not like 'New York%')
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Entertainment'
and hc.Division = 'CBS Entertainment'

/* Update 2014 Hotel Caps for division CBS Entertainment for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCountryCode <> 'US' or ht.HtlCountryCode is null)
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Entertainment'					   
and hc.Division = 'CBS Entertainment'	


/* Update 2014 Hotel Caps for division CBS Films for Specific Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */ 
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco')
and ht.HtlCityName = hc.City
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Films'
and hc.Division = 'CBS Films'

/* Update 2014 Hotel Caps for division CBS Films for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Films'
and hc.Division = 'CBS Films'

/* Update 2014 Hotel Caps for division CBS Films for Washington DC */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'Washington%'
and ht.HtlState = 'DC'
and hc.City = 'Washington DC'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Films'
and hc.Division = 'CBS Films'

/* Update 2014 Hotel Caps for division CBS Films for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCityName not in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco','Washington DC','Washington')
or ht.HtlCityName not like 'New York%')
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Films'
and hc.Division = 'CBS Films'

/* Update 2014 Hotel Caps for division CBS Films for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCountryCode <> 'US' or ht.HtlCountryCode is null)
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Films'					   
and hc.Division = 'CBS Films'


/* Update 2014 Hotel Caps for division CBS Studios for Specific Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */ 
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco')
and ht.HtlCityName = hc.City
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Studios'
and hc.Division = 'CBS Studios'

/* Update 2014 Hotel Caps for division CBS Studios for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Studios'
and hc.Division = 'CBS Studios'

/* Update 2014 Hotel Caps for division CBS Studios for Washington DC */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'Washington%'
and ht.HtlState = 'DC'
and hc.City = 'Washington DC'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Studios'
and hc.Division = 'CBS Studios'

/* Update 2014 Hotel Caps for division CBS Studios for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCityName not in ('Boston','Chicago','Las Vegas','Los Angeles','San Francisco','Washington DC','Washington')
or ht.HtlCityName not like 'New York%')
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Studios'
and hc.Division = 'CBS Studios'

/* Update 2014 Hotel Caps for division CBS Studios for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCountryCode <> 'US' or ht.HtlCountryCode is null)
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'CBS Studios'					   
and hc.Division = 'CBS Studios'	


/* Update 2014 Hotel Caps for division Network Staff for Specific Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */ 
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName in ('Atlanta','Austin','Boston','Chicago','Las Vegas','Los Angeles','Miami','San Francisco')
and ht.HtlCityName = hc.City
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Network Staff'
and hc.Division = 'Network Staff'

/* Update 2014 Hotel Caps for division Network Staff for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Network Staff'
and hc.Division = 'Network Staff'

/* Update 2014 Hotel Caps for division Network Staff for Washington DC */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'Washington%'
and ht.HtlState = 'DC'
and hc.City = 'Washington DC'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Network Staff'
and hc.Division = 'Network Staff'

/* Update 2014 Hotel Caps for division Network Staff for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCityName not in ('Atlanta','Austin','Boston','Chicago','Las Vegas','Los Angeles','Miami','San Francisco','Washington','Washington DC')
or ht.HtlCityName not like 'New York%')
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Network Staff'
and hc.Division = 'Network Staff'

/* Update 2014 Hotel Caps for division Network Staff for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCountryCode <> 'US' or ht.HtlCountryCode is null)
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Network Staff'					   
and hc.Division = 'Network Staff'	


/* Update 2014 Hotel Caps for division Showtime Networks for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Showtime'
and hc.Division = 'Showtime Networks'


/* Update 2014 Hotel Caps for division Showtime Networks for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName not like 'New York%'
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Showtime'
and hc.Division = 'Showtime Networks'

/* Update 2014 Hotel Caps for division Showtime Networks for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCountryCode <> 'US'
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 = 'Showtime'					   
and hc.Division = 'Showtime Networks'	


/* Update 2014 Hotel Caps for division Other for Specific Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */ 
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName in ('Atlanta','Austin','Boston','Chicago','Las Vegas','Los Angeles','Miami','San Francisco')
and ht.HtlCityName = hc.City
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 not in ('CBS Entertainment','CBS Films','CBS Studios','Network Staff','Showtime')
and hc.Division = 'Other'

/* Update 2014 Hotel Caps for division Other for New York */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName like 'New York%'
and hc.City = 'New York'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 not in ('CBS Entertainment','CBS Films','CBS Studios','Network Staff','Showtime')
and hc.Division = 'Other'

/* Update 2014 Hotel Caps for division Other for Washington DC */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and ht.HtlCityName = 'Washington'
and ht.HtlState = 'DC'
and hc.City = 'Washington DC'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 not in ('CBS Entertainment','CBS Films','CBS Studios','Network Staff','Showtime')
and hc.Division = 'Other'

/* Update 2014 Hotel Caps for division Other for Other US Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc
,TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
and (ht.HtlCityName not in ('Atlanta','Austin','Boston','Chicago','Las Vegas','Los Angeles','Miami','San Francisco','Washington','Washington DC')
or ht.HtlCityName not like 'New York%')
and ht.HtlCountryCode = 'US'
and hc.City = 'Other US Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 not in ('CBS Entertainment','CBS Films','CBS Studios','Network Staff','Showtime')
and hc.Division = 'Other'

/* Update 2014 Hotel Caps for division Other for International Cities */
/* Updated on 5/7/14 by Nina per Case # 00035845 */
update ht
set ht.Remarks5 = case when cr.Text30 = 'EVP' then hc.EVP
					   when cr.Text30 = 'SVP' then hc.SVP
					   when cr.Text30 = 'VP' then hc.VP
					   else hc.Others
					   END
from TTXPASQL01.TMAN503_CBS.dba.Hotel ht, TTXPASQL01.TMAN503_CBS.dba.comrmks cr
, TTXPASQL01.TMAN503_CBS.dba.hotelcap hc, TTXPASQL01.TMAN503_CBS.dba.rollup40 ru
where ht.iatanum in ('CBSAX','CBSBCD')
and ht.CheckinDate between hc.BeginDate and hc.EndDate
and ht.InvoiceDate between '2014-01-01' and '2015-12-31'
and ht.iatanum = cr.iatanum
and ht.recordkey = cr.recordkey
and ht.seqnum = cr.seqnum
and ht.clientcode = cr.clientcode
--and (cr.Text30 in ('EVP','SVP','VP') or cr.Text30 is null)
and ht.HtlCountryCode <> 'US'
and hc.City = 'International Cities'
and ht.Remarks5 is null
and cr.Text5 = ru.corporatestructure
and ru.rollup2 not in ('CBS Entertainment','CBS Films','CBS Studios','Network Staff','Showtime')					   
and hc.Division = 'Other'	   				   


/*	Update preferred hotels in dba.hotel and cchotel   */

update dba.hotel
set prefhtlind = 'N'
where checkindate >= '2013-01-01'

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season1start and pref.season1end

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season2start and pref.season2end

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season3start and pref.season3end

update htl
set htl.prefhtlind = 'Y'
from dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.season4start and pref.season4end


Update htl 
set htl.htlcommamt = 0
FROM dba.hotel htl
where htl.checkindate >= '2013-01-01'

update htl
set htl.htlcommamt = round(pref.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
from dba.currency curr, dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.SEASON1START and pref.SEASON1END
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr

update htl
set htlcommamt = round(pref.LRA_S2_RT1_SGL * curr.baseunitspercurr,2)
from dba.currency curr, dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.SEASON2START and pref.SEASON2END
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr

update htl
set htlcommamt = round(pref.LRA_S3_RT1_SGL * curr.baseunitspercurr,2)
from dba.currency curr, dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.SEASON3START and pref.SEASON3END
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr

update htl
set htlcommamt = round(pref.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
from dba.currency curr, dba.hotel htl,dba.hotelproperty xref,
dba.hotelproperty prop,dba.preferredhotels pref
where htl.checkindate >= '2013-01-01'
and htl.masterid = xref.masterid
and xref.parentid = prop.masterid
and pref.masterid = prop.masterid
and htl.checkindate between pref.SEASON4START and pref.SEASON4END
and curr.basecurrcode = 'USD'
and curr.currbegindate = htl.issuedate
and curr.currcode = pref.rate_curr

--Log Activity
SET @TransStart = getdate()
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName='Post HNN Stored Procedure End',@BeginDate=@BeginIssueDate,@EndDate=@EndIssueDate,@IataNum=@Iata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR



update dba.cchotel
set noshowind = 'N'
where noshowind is null

update dba.cchotel
set othercharges = 0

update cchtl
set othercharges = round(pfh.LRA_S1_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season1Start and pfh.Season1End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'

update cchtl
set othercharges = round(pfh.LRA_S2_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season2Start and pfh.Season2End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'

update cchtl
set othercharges = round(pfh.LRA_S3_RT1_SGL * curr.baseunitspercurr,2) 
,cchtl.noshowind = 'Y'
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season3Start and pfh.Season3End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'

update cchtl
set othercharges = round(pfh.LRA_S4_RT1_SGL * curr.baseunitspercurr,2)
,cchtl.noshowind = 'Y' 
from dba.cchotel cchtl, dba.preferredhotels pfh, dba.currency curr, dba.ccmerchant ccm, dba.hotelproperty HTLXREF
where ISNULL(cchtl.arrivaldate,cchtl.transactiondate) between pfh.Season4Start and pfh.Season4End
and pfh.masterid = HTLXREF.parentid
and HTLXREF.MasterID = CCM.MasterId
and cchtl.merchantid = ccm.merchantid
and curr.basecurrcode = 'USD'
and curr.currbegindate = cchtl.transactiondate
and curr.currcode = pfh.rate_curr
and cchtl.noshowind = 'N'


 
 /************************************************************************
                LOGGING_ENDED - BEGIN
				---------------------
--Date: 03/13/2015
--Modification:  Added Comment line for tracking
--R. Robinson
--
************************************************************************/
--R. Robinson modified 02/19/2015 added time to stepname
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @TransStart = getdate()
SET @tmpStepName = 'Stored Procedure Ended logging '
--declare @tmpTimeStmp nvarchar(9) = substring(cast(Sysdatetimeoffset() as nvarchar(29)),12,8)
--select @tmpStepName += @tmpTimeStmp
Select @tmpStepName = @tmpStepName + @tmpTimeStmp 
--Log Activity
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@TransStart,@StepName=@tmpStepName,@BeginDate=@TransStart,@EndDate=@TransStart,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
/************************************************************************
                LOGGING_ENDED - END
************************************************************************/

END
GO
