/****** Object:  StoredProcedure [dbo].[sp_CITI_VDU_postImport_GTAATD]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ver    Date        Who     SFCase    Change
-- -----  ----------  ------  --------  -------------------------------------------
-- V1.00  2015/06/25  BPerry  06011052  Baseline

-- This script performs post-import data updates for standard TMAN503 files
-- ((VDU_Feeds.ImportGroup='GTAATD').

-- Once complete, it initiates the remote execution for the appropriate TTXDR
-- batch/report which concludes with report delivery.

-- Note: this script currently relies on a serial loading assumption that
-- implies the maximum InvoiceHeader.IMPORTDT is for the most recent/current
-- load and that all records for the associated input file will have this same
-- value.


-- Citi VDU "standard" ComRmks Definitions
-- =======================================
-- Text21 - Matrix Subid Value                              (postImport calculates; default based on IH.ImportDT)
-- Text22 - Supplier (TMC/Agency Name)                      (postImport calculates; default based on IH.IataNum and VDU_Feeds entry)
-- Text23 - Product Specific Information/Merchant Free Text (postImport calculates; default based on ID.Remarks1)
-- Text24 - Merchant Indicator                              (postImport calculates; default based on ID.Remarks5)
-- Text25 - Sales Tax Indicator                             (postImport calculates; default based on ID.Remarks4)
-- Text26 - Product Code                                    (postImport calculates; default based on ID.InvoiceType)  
-- Text31-Text45 - Client Reference 1-15                    (postImport calculates; default based on UD.UdefNum=1-15)

-- Text47 - Max Segment Num                                 (postImport calculates)
-- Text48 - Num Segments                                    (postImport calculates)
-- Text49 - reserved as post-import completion flag         (used only by post-import; prevents reprocessing of a dataset)
-- Text50 - VDU Export Flag                                 (not set in postImport; utilized during export processing)

CREATE PROCEDURE [dbo].[sp_CITI_VDU_postImport_GTAATD]
   @BEGINIssueDate   datetime,
   @ENDIssueDate     datetime
AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

DECLARE @ProcName varchar(50), @ProcStart datetime
SET @ProcName = CONVERT(varchar(50),OBJECT_NAME(@@PROCID))
SET @ProcStart = getdate()

DECLARE @freeText varchar(100)

-- Get max IMPORTDT from loaded records (max represents latest dataset)
DECLARE @fileKey datetime
-- normal logic (most recent import)
SET @fileKey = (SELECT MAX(IMPORTDT)
                    FROM dba.InvoiceHeader
                    WHERE IataNum IN (SELECT DISTINCT IataNum FROM dba.VDU_Feeds WHERE ImportGroup='GTAATD'))
-- temp patch for specified single file run
--SET @fileKey = '2013-09-27 03:51:27.000'

-- Get IataNum for latest dataset
DECLARE @fileIata varchar(8)
Set @fileIata = (SELECT DISTINCT IataNum
                   FROM dba.InvoiceHeader
                   WHERE IMPORTDT = @fileKey)

-- Get supplier and report details for IataNum
DECLARE @feedSupplier varchar(50), @reportBatch varchar(500), @reportServer varchar(50), @reportingEnabled varchar(1)
SELECT @feedSupplier=Supplier, @reportBatch=ReportBatch, @reportServer=ReportServer, @reportingEnabled=ReportingEnabled
  FROM dba.VDU_Feeds
  WHERE IataNum = @fileIata

-- Any and all edits can be logged using sp_LogProcErrors
-- Insert a row into the dbo.procedurelogs table using sp....when the procedure starts
-- Define all the parameters needed to log each step of a stored procedure and raise an error if necessary
-- @ProcedureName varchar(50), -- **REQUIRED** Name of the Procedure being run
-- @LogStart datetime, -- **REQUIRED** Create a variable and capture a timestamp at the BEGINning of a transaction
-- @StepName varchar(50) = NULL,  -- **OPTIONAL** Name of the Step in the Stored Procedure (For Ex. 'Update ComRmks' OR 'Insert Udef'
-- @BEGINDate datetime = NULL, -- **OPTIONAL** The BEGINIssueDate that is passed to the Parent Procedure
-- @ENDDate datetime = NULL, -- **OPTIONAL** The ENDIssueDate that is pased to the Parent Procedure
-- @IataNum varchar(50) = NULL, -- **OPTIONAL** The IataNum that is passed to the Parent Procedure
-- @RowCount int, -- **REQUIRED** Total number of affected rows
-- @ERR int) -- **REQUIRED** The Error number, even if it is still 0 (Zero)

-- Log Stored Proc BEGIN
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='1 - Stored Procedure BEGIN',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @freeText = '2a - IMPORTDT='+CHAR(39)+CONVERT(VARCHAR(25),@FILEKEY,121)+CHAR(39)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName=@freeText,@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @freeText = '2b - IataNum='+CHAR(39)+@fileIata+CHAR(39)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName=@freeText,@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
SET @freeText = '2c - Supplier='+CHAR(39)+@feedSupplier+CHAR(39)
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName=@freeText,@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR


-- Test data set for prior processing (text49 set)
--
-- This most likely occurs because an empty import file is loaded and DMA doesn't
-- halt execution of the post-import.  As a result, the fileKey query above
-- returns the last non-empty dataset rather than the current dataset
-- (which didn't have nay data to load)
--
-- If Text49 is set, exit post-import processing.
-- Otherwise, update this dataset and continue.

DECLARE @importCnt smallint
SET @importCnt = (SELECT count(*)
                  FROM dba.InvoiceHeader ih
                      join dba.ComRmks cr ON ih.recordkey=cr.recordkey and ih.iatanum=cr.iatanum and ih.InvoiceDate=cr.InvoiceDate
                  WHERE ih.IMPORTDT = @fileKey
                        and cr.text49 IS NOT NULL)
IF (@importCnt <> 0)
BEGIN
   SET @freeText = '99 - text49 already set (cnt='+CONVERT(VARCHAR(10),@importCnt)+'), post-import aborted'
   EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName=@freeText,@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR
   RETURN
END

UPDATE
   cr
SET
   cr.Text49 = 'Y'
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.InvoiceDate = cr.InvoiceDate
WHERE
   ih.IMPORTDT = @fileKey


-- Misc Standardization
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='3 - Standardization',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- InvoiceDate Update
-- The ATD Invoice Date field is required but is occasionally omitted.  However, 
-- getting corrected data can be difficult and Citi accepts empty string  as a 
-- replacement value.  This section updates the following:
--    InvoiceHeader
--    InvoiceDetail
--    TranSeg
--    Car
--    Hotel
--    Payment
--    Tax
--    Udef
--    ComRmks
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='02a - ClientCode Updates',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

UPDATE dba.InvoiceHeader SET InvoiceDate='' WHERE InvoiceDate IS NULL and IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.InvoiceDetail tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.TranSeg tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.Car tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.Hotel tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.Payment tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.Tax tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.Udef tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey

UPDATE tbl SET tbl.InvoiceDate = ''
FROM
   dba.ComRmks tbl
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = tbl.RecordKey AND ih.IataNum = tbl.IataNum
WHERE
   tbl.InvoiceDate IS NULL and ih.IMPORTDT = @fileKey


-- Kaleva Travel does not use standard GTA product codes
-- Original value mapped to ClientRef9 (CR.Text39) - also in ID.ProductType
-- Replacement value mapped into ID.InvoiceType
-- Dependent updates made to ID.InvoiceTypeDescription, ID.VendorType
-- NOTE: this is performed during the standardization section due to later dependencies on ID.VendorType
IF ((@fileIata='CEKTFIA') OR
    (@fileIata='CEKTFIB'))
BEGIN
   UPDATE
      cr
   SET
      cr.Text39 = id.InvoiceType
   FROM
      dba.ComRmks cr
      JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
      JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
   WHERE
      ih.IMPORTDT = @fileKey

   UPDATE
      id
   SET
      id.InvoiceType = CASE WHEN id.ProductType='951' THEN '010'
                            WHEN id.ProductType='952' THEN '010'
                            WHEN id.ProductType='953' THEN '001'
                            WHEN id.ProductType='954' THEN '001'
                            WHEN id.ProductType='955' THEN '001'
                            WHEN id.ProductType='956' THEN '001'
                            WHEN id.ProductType='957' THEN '957'
                            WHEN id.ProductType='958' THEN '958'
                            WHEN id.ProductType='959' THEN '011'
                            WHEN id.ProductType='960' THEN '011'
                            WHEN id.ProductType='961' THEN '023'
                            WHEN id.ProductType='962' THEN '023'
                            WHEN id.ProductType='963' THEN '014'
                            WHEN id.ProductType='964' THEN '014'
                            WHEN id.ProductType='965' THEN '005'
                            WHEN id.ProductType='966' THEN '005'
                            WHEN id.ProductType='967' THEN '005'
                            WHEN id.ProductType='968' THEN '006'
                            WHEN id.ProductType='969' THEN '004'
                            WHEN id.ProductType='979' THEN '004'
                            ELSE id.InvoiceType
                       END,
      id.InvoiceTypeDescription = 
                       CASE WHEN id.ProductType='951' THEN 'Hotels'
                            WHEN id.ProductType='952' THEN 'Hotels'
                            WHEN id.ProductType='953' THEN 'Airline Tickets'
                            WHEN id.ProductType='954' THEN 'Airline Tickets'
                            WHEN id.ProductType='955' THEN 'Airline Tickets'
                            WHEN id.ProductType='956' THEN 'Airline Tickets'
                            WHEN id.ProductType='957' THEN 'Unknown Code'
                            WHEN id.ProductType='958' THEN 'Unknown Code'
                            WHEN id.ProductType='959' THEN 'Car Hire'
                            WHEN id.ProductType='960' THEN 'Car Hire'
                            WHEN id.ProductType='961' THEN 'Service Charges'
                            WHEN id.ProductType='962' THEN 'Service Charges'
                            WHEN id.ProductType='963' THEN 'Passports & Visas'
                            WHEN id.ProductType='964' THEN 'Passports & Visas'
                            WHEN id.ProductType='965' THEN 'Domestic Rail'
                            WHEN id.ProductType='966' THEN 'Domestic Rail'
                            WHEN id.ProductType='967' THEN 'Domestic Rail'
                            WHEN id.ProductType='968' THEN 'Foreign Rail'
                            WHEN id.ProductType='969' THEN 'Ferries'
                            WHEN id.ProductType='979' THEN 'Ferries'
                            ELSE id.InvoiceTypeDescription
                       END
   FROM
      dba.InvoiceDetail id
      JOIN dba.InvoiceHeader ih ON ih.RecordKey = id.RecordKey and ih.IataNum = id.IataNum and ih.ClientCode = id.ClientCode and ih.InvoiceDate = id.InvoiceDate
   WHERE
      ih.IMPORTDT = @fileKey

   UPDATE
      id
   SET
      id.VendorType = CASE WHEN id.InvoiceType='001' THEN 'BSP'   
                           WHEN id.InvoiceType='002' THEN 'NONAIR'
                           WHEN id.InvoiceType='004' THEN 'NONAIR'
                           WHEN id.InvoiceType='005' THEN 'RAIL'  
                           WHEN id.InvoiceType='006' THEN 'RAIL'  
                           WHEN id.InvoiceType='007' THEN 'NONAIR'
                           WHEN id.InvoiceType='008' THEN 'NONAIR'
                           WHEN id.InvoiceType='009' THEN 'NONAIR'
                           WHEN id.InvoiceType='010' THEN 'NONAIR'
                           WHEN id.InvoiceType='011' THEN 'NONAIR'
                           WHEN id.InvoiceType='012' THEN 'NONAIR'
                           WHEN id.InvoiceType='013' THEN 'NONAIR'
                           WHEN id.InvoiceType='014' THEN 'NONAIR'
                           WHEN id.InvoiceType='015' THEN 'NONAIR'
                           WHEN id.InvoiceType='018' THEN 'NONAIR'
                           WHEN id.InvoiceType='023' THEN 'NONAIR'
                           WHEN id.InvoiceType='030' THEN 'NONAIR'
                           WHEN id.InvoiceType='031' THEN 'NONAIR'
                           WHEN id.InvoiceType='032' THEN 'NONAIR'
                           WHEN id.InvoiceType='037' THEN 'NONAIR'
                           WHEN id.InvoiceType='078' THEN 'NONAIR'
                           WHEN id.InvoiceType='097' THEN 'NONAIR'
                           ELSE 'NONAIR'
                       END
   FROM
      dba.InvoiceDetail id
      JOIN dba.InvoiceHeader ih ON ih.RecordKey = id.RecordKey and ih.IataNum = id.IataNum and ih.ClientCode = id.ClientCode and ih.InvoiceDate = id.InvoiceDate
   WHERE
      ih.IMPORTDT = @fileKey
END


-- Additional ComRmks mappings
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='4 - ComRmks Mappings',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- Text21 - Submission ID
-- Map ImportDT (yyyy-mm-dd hh:mm:ss.mmm) to a 10-char version compatible with Matrix
-- 10-char Key:
-- 1st Digit - mapping of 20yy value (A=10, B=11, C=12, D=13, ..., Z = 35)
-- 2nd Digit - mapping of 01-12 mm value to single char 1-C
-- 3rd/4th Digit - mapping of 01-31 dd value
-- 5th/6th Digit - hh
-- 7th/8th Digit - mm
-- 9th/10th Digit - ss
-- This also presumes that two loads will not occur within the same second
DECLARE @sFileKey varchar(25), @SUBID varchar(10), @subidY varchar(2), @subidM varchar(2)

SET @sFileKey = CONVERT(VARCHAR(25),@fileKey,121)

SET @subidY = SUBSTRING(@sFileKey,3,2)
IF      @subidY = '10' BEGIN SET @subidY = 'A' END
ELSE IF @subidY = '11' BEGIN SET @subidY = 'B' END
ELSE IF @subidY = '12' BEGIN SET @subidY = 'C' END
ELSE IF @subidY = '13' BEGIN SET @subidY = 'D' END
ELSE IF @subidY = '14' BEGIN SET @subidY = 'E' END
ELSE IF @subidY = '15' BEGIN SET @subidY = 'F' END
ELSE IF @subidY = '16' BEGIN SET @subidY = 'G' END
ELSE IF @subidY = '17' BEGIN SET @subidY = 'H' END
ELSE IF @subidY = '18' BEGIN SET @subidY = 'I' END
ELSE IF @subidY = '19' BEGIN SET @subidY = 'J' END
ELSE IF @subidY = '20' BEGIN SET @subidY = 'K' END
ELSE IF @subidY = '21' BEGIN SET @subidY = 'L' END
ELSE IF @subidY = '22' BEGIN SET @subidY = 'M' END
ELSE IF @subidY = '23' BEGIN SET @subidY = 'N' END
ELSE IF @subidY = '24' BEGIN SET @subidY = 'O' END
ELSE IF @subidY = '25' BEGIN SET @subidY = 'P' END
ELSE IF @subidY = '26' BEGIN SET @subidY = 'Q' END
ELSE IF @subidY = '27' BEGIN SET @subidY = 'R' END
ELSE IF @subidY = '28' BEGIN SET @subidY = 'S' END
ELSE IF @subidY = '29' BEGIN SET @subidY = 'T' END
ELSE IF @subidY = '30' BEGIN SET @subidY = 'U' END
ELSE IF @subidY = '31' BEGIN SET @subidY = 'V' END
ELSE IF @subidY = '32' BEGIN SET @subidY = 'W' END
ELSE IF @subidY = '33' BEGIN SET @subidY = 'X' END
ELSE IF @subidY = '34' BEGIN SET @subidY = 'Y' END
ELSE IF @subidY = '35' BEGIN SET @subidY = 'Z' END

SET @subidM = SUBSTRING(@sFileKey,6,2)
IF      @subidM = '01' BEGIN SET @subidM = '1' END
ELSE IF @subidM = '02' BEGIN SET @subidM = '2' END
ELSE IF @subidM = '03' BEGIN SET @subidM = '3' END
ELSE IF @subidM = '04' BEGIN SET @subidM = '4' END
ELSE IF @subidM = '05' BEGIN SET @subidM = '5' END
ELSE IF @subidM = '06' BEGIN SET @subidM = '6' END
ELSE IF @subidM = '07' BEGIN SET @subidM = '7' END
ELSE IF @subidM = '08' BEGIN SET @subidM = '8' END
ELSE IF @subidM = '09' BEGIN SET @subidM = '9' END
ELSE IF @subidM = '10' BEGIN SET @subidM = 'A' END
ELSE IF @subidM = '11' BEGIN SET @subidM = 'B' END
ELSE IF @subidM = '12' BEGIN SET @subidM = 'C' END

SET @subid = @subidY +
             @subidM +
             SUBSTRING(@sFileKey,9,2) +
             SUBSTRING(@sFileKey,12,2) +
             SUBSTRING(@sFileKey,15,2) +
             SUBSTRING(@sFileKey,18,2)

UPDATE
   cr
SET
   cr.Text21 = @subid
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey AND id.SeqNum = cr.SeqNum AND id.IataNum = cr.IataNum AND id.ClientCode = cr.ClientCode AND id.InvoiceDate = cr.InvoiceDate
WHERE
   ih.IMPORTDT = @fileKey

-- Text22 - Supplier Name
UPDATE
   cr
SET
   cr.Text22 = @feedSupplier
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey AND id.SeqNum = cr.SeqNum AND id.IataNum = cr.IataNum AND id.ClientCode = cr.ClientCode AND id.InvoiceDate = cr.InvoiceDate
WHERE
   ih.IMPORTDT = @fileKey

-- Text23 - Product Specific Information
-- Default based on standard GTA/ATD mapping into ID.Remarks1
UPDATE
   cr
SET
   cr.Text23 = id.Remarks1
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey

-- Text24 - Merchant Indicator
-- Default based on standard GTA/ATD mapping into ID.Remarks5
UPDATE
   cr
SET
   cr.Text24 = id.Remarks5
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey

-- Text25 - Sales Tax Indicator
-- Default based on standard GTA/ATD mapping into ID.Remarks4
UPDATE
   cr
SET
   cr.Text25 = id.Remarks4
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey

-- Text26 - Product Code
-- Default based on standard GTA/ATD mapping into ID.InvoiceType
UPDATE
   cr
SET
   cr.Text26 = id.InvoiceType
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey

-- Text31 - Text45 - Client Reference 1-15
-- Default based on standard GTA/ATD mapping into UDEF with udefnum=1-15
UPDATE
   cr
SET
   cr.Text31 = ud01.udefData,
   cr.Text32 = ud02.udefData,
   cr.Text33 = ud03.udefData,
   cr.Text34 = ud04.udefData,
   cr.Text35 = ud05.udefData,
   cr.Text36 = ud06.udefData,
   cr.Text37 = ud07.udefData,
   cr.Text38 = ud08.udefData,
   cr.Text39 = ud09.udefData,
   cr.Text40 = ud10.udefData,
   cr.Text41 = ud11.udefData,
   cr.Text42 = ud12.udefData,
   cr.Text43 = ud13.udefData,
   cr.Text44 = ud14.udefData,
   cr.Text45 = ud15.udefData
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   LEFT OUTER JOIN dba.Udef ud01 ON ud01.RecordKey = cr.RecordKey and ud01.IataNum = cr.IataNum and ud01.ClientCode = cr.ClientCode and ud01.InvoiceDate = cr.InvoiceDate and ud01.SeqNum = cr.SeqNum AND ud01.UdefNum=1
   LEFT OUTER JOIN dba.Udef ud02 ON ud02.RecordKey = cr.RecordKey and ud02.IataNum = cr.IataNum and ud02.ClientCode = cr.ClientCode and ud02.InvoiceDate = cr.InvoiceDate and ud02.SeqNum = cr.SeqNum AND ud02.UdefNum=2
   LEFT OUTER JOIN dba.Udef ud03 ON ud03.RecordKey = cr.RecordKey and ud03.IataNum = cr.IataNum and ud03.ClientCode = cr.ClientCode and ud03.InvoiceDate = cr.InvoiceDate and ud03.SeqNum = cr.SeqNum AND ud03.UdefNum=3
   LEFT OUTER JOIN dba.Udef ud04 ON ud04.RecordKey = cr.RecordKey and ud04.IataNum = cr.IataNum and ud04.ClientCode = cr.ClientCode and ud04.InvoiceDate = cr.InvoiceDate and ud04.SeqNum = cr.SeqNum AND ud04.UdefNum=4
   LEFT OUTER JOIN dba.Udef ud05 ON ud05.RecordKey = cr.RecordKey and ud05.IataNum = cr.IataNum and ud05.ClientCode = cr.ClientCode and ud05.InvoiceDate = cr.InvoiceDate and ud05.SeqNum = cr.SeqNum AND ud05.UdefNum=5
   LEFT OUTER JOIN dba.Udef ud06 ON ud06.RecordKey = cr.RecordKey and ud06.IataNum = cr.IataNum and ud06.ClientCode = cr.ClientCode and ud06.InvoiceDate = cr.InvoiceDate and ud06.SeqNum = cr.SeqNum AND ud06.UdefNum=6
   LEFT OUTER JOIN dba.Udef ud07 ON ud07.RecordKey = cr.RecordKey and ud07.IataNum = cr.IataNum and ud07.ClientCode = cr.ClientCode and ud07.InvoiceDate = cr.InvoiceDate and ud07.SeqNum = cr.SeqNum AND ud07.UdefNum=7
   LEFT OUTER JOIN dba.Udef ud08 ON ud08.RecordKey = cr.RecordKey and ud08.IataNum = cr.IataNum and ud08.ClientCode = cr.ClientCode and ud08.InvoiceDate = cr.InvoiceDate and ud08.SeqNum = cr.SeqNum AND ud08.UdefNum=8
   LEFT OUTER JOIN dba.Udef ud09 ON ud09.RecordKey = cr.RecordKey and ud09.IataNum = cr.IataNum and ud09.ClientCode = cr.ClientCode and ud09.InvoiceDate = cr.InvoiceDate and ud09.SeqNum = cr.SeqNum AND ud09.UdefNum=9
   LEFT OUTER JOIN dba.Udef ud10 ON ud10.RecordKey = cr.RecordKey and ud10.IataNum = cr.IataNum and ud10.ClientCode = cr.ClientCode and ud10.InvoiceDate = cr.InvoiceDate and ud10.SeqNum = cr.SeqNum AND ud10.UdefNum=10
   LEFT OUTER JOIN dba.Udef ud11 ON ud11.RecordKey = cr.RecordKey and ud11.IataNum = cr.IataNum and ud11.ClientCode = cr.ClientCode and ud11.InvoiceDate = cr.InvoiceDate and ud11.SeqNum = cr.SeqNum AND ud11.UdefNum=11
   LEFT OUTER JOIN dba.Udef ud12 ON ud12.RecordKey = cr.RecordKey and ud12.IataNum = cr.IataNum and ud12.ClientCode = cr.ClientCode and ud12.InvoiceDate = cr.InvoiceDate and ud12.SeqNum = cr.SeqNum AND ud12.UdefNum=12
   LEFT OUTER JOIN dba.Udef ud13 ON ud13.RecordKey = cr.RecordKey and ud13.IataNum = cr.IataNum and ud13.ClientCode = cr.ClientCode and ud13.InvoiceDate = cr.InvoiceDate and ud13.SeqNum = cr.SeqNum AND ud13.UdefNum=13
   LEFT OUTER JOIN dba.Udef ud14 ON ud14.RecordKey = cr.RecordKey and ud14.IataNum = cr.IataNum and ud14.ClientCode = cr.ClientCode and ud14.InvoiceDate = cr.InvoiceDate and ud14.SeqNum = cr.SeqNum AND ud14.UdefNum=14
   LEFT OUTER JOIN dba.Udef ud15 ON ud15.RecordKey = cr.RecordKey and ud15.IataNum = cr.IataNum and ud15.ClientCode = cr.ClientCode and ud15.InvoiceDate = cr.InvoiceDate and ud15.SeqNum = cr.SeqNum AND ud15.UdefNum=15
WHERE
   ih.IMPORTDT = @fileKey


-- Text 47 - Max Segment Number
UPDATE
 cr1
SET text47=maxQ.maxSegNum
FROM
   dba.ComRmks cr1
   JOIN (SELECT
            cr.RecordKey as recKey,
            cr.iataNum as iataNum,
            cr.SeqNum as seqNum,
            MAX(ts.segmentNum) AS maxSegNum
         FROM
           dba.ComRmks cr
           JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
           JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey AND id.SeqNum = cr.SeqNum AND id.IataNum = cr.IataNum AND id.ClientCode = cr.ClientCode AND id.InvoiceDate = cr.InvoiceDate
           LEFT OUTER JOIN DBA.TranSeg ts ON ts.RecordKey = cr.RecordKey AND ts.SeqNum = cr.SeqNum AND ts.IataNum = cr.IataNum AND ts.ClientCode = cr.ClientCode AND ts.InvoiceDate = cr.InvoiceDate
         WHERE
           id.vendorType IN ('BSP','NONBSP')
           and ts.SegmentNum IS NOT NULL
           and ih.IMPORTDT = @fileKey
        GROUP BY cr.RecordKey, cr.iataNum, cr.SeqNum
        ) maxQ
      ON cr1.RecordKey=maxQ.recKey AND cr1.IataNum=maxQ.IataNum AND cr1.SeqNum=maxQ.SeqNum
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr1.RecordKey AND ih.IataNum = cr1.IataNum AND ih.ClientCode = cr1.ClientCode AND ih.InvoiceDate = cr1.InvoiceDate
WHERE
   ih.IMPORTDT = @fileKey

-- Text 48 - Num Segments
UPDATE
 cr
SET text48=tsegs.segcnt
FROM
   dba.ComRmks cr
   JOIN (SELECT
            ts.recordkey,ts.iatanum,ts.invoicedate,ts.seqnum,count(*) as segcnt
         FROM
            dba.invoiceheader ih
            JOIN dba.transeg ts ON ih.recordkey = ts.recordkey AND ih.iatanum = ts.iatanum AND ih.ClientCode = ts.ClientCode AND ih.invoicedate = ts.invoicedate
         WHERE
            ih.importdt = @fileKey
         GROUP BY ts.recordkey,ts.iatanum,ts.invoicedate,ts.seqnum
         ) tsegs
      ON cr.recordkey = tsegs.recordkey and cr.seqnum = tsegs.seqnum and cr.iatanum = tsegs.iatanum and cr.invoicedate = tsegs.invoicedate
   JOIN dba.invoiceheader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
WHERE
   ih.IMPORTDT = @fileKey


-- TMC-Specific Customizations
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='5 - TMC-Specific Customization',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

-- NOTE: Kaleva Travel customizations performed with standardizations due to VendorType dependencies after standardization


-- initiate remote batch reporting
IF ((@reportServer = '') OR (@reportingEnabled<>'Y'))
BEGIN
   SET @freeText = '6 - No Report Server set or reporting not enabled'
END ELSE BEGIN
   SET @reportBatch = 'D:\Batch\CitiVDU\bin\' + @reportBatch + '.bat'
   SET @freeText = '6 - Initiate Remote TTXDR  (' + @reportBatch + ' on ' + @reportServer + ')'
   EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName=@freeText,@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

   EXEC dbo.sp_ExecuteLocalBatchFile @RemoteServer=@reportServer, @RemoteBatch='D:\Batch\bin\ttxdrs.bat', @RemoteArgs=@reportBatch
END


-- Log Stored Proc END
EXEC dbo.sp_LogProcErrors @ProcedureName=@ProcName,@LogStart=@ProcStart,@StepName='7 - Stored Procedure END',@BEGINDate=@BEGINIssueDate,@ENDDate=@ENDIssueDate,@IataNum=@fileIata,@RowCount=@@ROWCOUNT,@ERR=@@ERROR

END

GO
