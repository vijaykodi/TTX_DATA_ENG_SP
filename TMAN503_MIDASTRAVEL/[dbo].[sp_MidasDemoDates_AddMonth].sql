/****** Object:  StoredProcedure [dbo].[sp_MidasDemoDates_AddMonth]    Script Date: 7/14/2015 8:11:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Cutts
-- Create date: 10/09/2014
-- Description:	add 1 month onto all reportable dates for midas demo data
-- =============================================
CREATE PROCEDURE dbo.sp_MidasDemoDates_AddMonth

AS
BEGIN

	SET NOCOUNT ON;

BEGIN TRANSACTION;
BEGIN TRY
update ih
set InvoiceDate = DATEADD(mm, 1, InvoiceDate)
--select InvoiceDate, DATEADD(mm, 1, InvoiceDate)
from dba.Invoiceheader ih
where iatanum in('DemoData','Predemo')

update id
set BookingDate = DATEADD(mm, 1, bookingdate), InvoiceDate = DATEADD(mm, 1, InvoiceDate), IssueDate = DATEADD(mm, 1, IssueDate), ServiceDate = DATEADD(mm, 1, ServiceDate)
--select BookingDate, DATEADD(mm, 1, bookingdate), InvoiceDate, DATEADD(mm, 1, InvoiceDate), IssueDate, DATEADD(mm, 1, IssueDate), ServiceDate, DATEADD(mm, 1, ServiceDate)
from dba.InvoiceDetail id
where iatanum in('DemoData','Predemo')

update ts
set InvoiceDate = DATEADD(mm, 1, InvoiceDate), issuedate = DATEADD(mm, 1, IssueDate), departureDate = DATEADD(mm, 1, DepartureDate), segarrivaldate = DATEADD(mm, 1, SEGArrivalDate), NOXarrivaldate = DATEADD(mm, 1, NOXArrivalDate), minarrivaldate = DATEADD(mm, 1, MINArrivalDate), yielddateposted = DATEADD(mm, 1, YieldDatePosted)
--select InvoiceDate, DATEADD(mm, 1, InvoiceDate), issuedate, DATEADD(mm, 1, IssueDate), departureDate, DATEADD(mm, 1, DepartureDate), segarrivaldate, DATEADD(mm, 1, SEGArrivalDate), NOXarrivaldate, DATEADD(mm, 1, NOXArrivalDate), minarrivaldate, DATEADD(mm, 1, MINArrivalDate), yielddateposted, DATEADD(mm, 1, YieldDatePosted)
from dba.TranSeg ts
where iatanum in('DemoData','Predemo')

update h 
set invoicedate = DATEADD(mm, 1, InvoiceDate), issuedate = DATEADD(mm, 1, issuedate), checkindate = DATEADD(mm, 1, checkindate), checkoutdate = DATEADD(mm, 1, checkoutdate) 
--select invoicedate, DATEADD(mm, 1, InvoiceDate), issuedate, DATEADD(mm, 1, issuedate), checkindate, DATEADD(mm, 1, checkindate), checkoutdate, DATEADD(mm, 1, checkoutdate) 
from dba.hotel h
where iatanum in('DemoData','Predemo')

update c 
set invoicedate = DATEADD(mm, 1, InvoiceDate), issuedate = DATEADD(mm, 1, issuedate), pickupdate = DATEADD(mm, 1, pickupdate), DropoffDate = DATEADD(mm, 1, DropoffDate) 
--select invoicedate, DATEADD(mm, 1, InvoiceDate), issuedate, DATEADD(mm, 1, issuedate), pickupdate, DATEADD(mm, 1, pickupdate), DropoffDate, DATEADD(mm, 1, DropoffDate) 
from dba.car c
where iatanum in('DemoData','Predemo')

update u 
set InvoiceDate = DATEADD(mm, 1, InvoiceDate), IssueDate = DATEADD(mm, 1, IssueDate)
--select clientcode, InvoiceDate, DATEADD(mm, 1, InvoiceDate), IssueDate, DATEADD(mm, 1, IssueDate)
from dba.Udef u
where iatanum in('DemoData','Predemo')

update cr 
set InvoiceDate = DATEADD(mm, 1, InvoiceDate), IssueDate = DATEADD(mm, 1, IssueDate)
--select InvoiceDate, DATEADD(mm, 1, InvoiceDate), IssueDate,  DATEADD(mm, 1, IssueDate)
from dba.ComRmks cr
where IataNum in ('DemoData','PreDemo')
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;


END

GO
