/****** Object:  StoredProcedure [dbo].[sp_CITI_VDU_postImport_STDIMPT5]    Script Date: 7/14/2015 7:52:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Ver    Date        Who     SFCase    Change
-- -----  ----------  ------  --------  -------------------------------------------
-- V1.0   2013/02/18  BPerry            Baseline
-- V1.1   2013/04/09  BPerry            Altered SUBID generation
-- V1.2   2013/04/16  BPerry            Added Text48 - Num Segments
-- V1.3   2013/04/19  BPerry            Alter ccnum for BCD NA
-- V1.4   2013/06/10  BPerry            Added reportEnabled export control, BCD NA ccnum map
-- V1.5   2013/09/27  BPerry            Client-specific UDEF mappings for CWT NA
-- V1.6   2013/10/10  BPerry  021748    CWT Prism test feed integration
-- V1.7   2014/02/24  BPerry  025178    CEBCDAL integration
-- V1.8   2014/04/17  BPerry  025178    BCD updates
-- V1.9   2014/05/27  BPerry  022092    Loblaws integration
-- V1.9   2014/06/11  BPerry  022092    Loblaws UDEF modification
-- V1.10  2014/06/13  BPerry  026859    ccnum/token replacement
-- V1.11  2014/09/03  BPerry  040207    CEGEGW integration
-- V1.12  2014/09/29  BPerry  045485    ApprCode integration (CECWTP%)
-- V1.13  2015/04/08  BPerry  06154827  CEVICA - TRAMS BIN filter
-- V1.14  2015/04/09  BPerry  06154827  CEVICA - UDEF mappings
-- V1.15  2015/04/28  BPerry  06048198  CEHRBMCA - TAX mappings
-- V1.16  2015/05/08  BPerry  06020461  CECTMS* - card filter, join cleanup
-- V1.17  2015/05/14  BPerry  06048198  CEHRBMCA - TAX mapping update
-- V1.18  2015/05/27  BPerry  06244215  CEWTIVWR - card replacement
-- V1.19  2015/06/04  BPerry  06460066  CECTMS* - tax mapping update
-- V1.20  2015/06/05  BPerry  06077012  CEEGSB - card replacement
-- V1.21  2015/06/26  BPerry  06011025  DTX feed integration
-- V1.22  2015/07/14  BPerry  06077012  CEEGSB - tax mapping

-- This script performs post-import data updates for standard TMAN503 files
-- ((VDU_Feeds.ImportGroup='STDIMPT5').

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
-- Text23 - Product Specific Information/Merchant Free Text (default Parsed Fields mapping from ID.VendorName or ID.InvoiceTypeDescription)
-- Text24 - Merchant Indicator                              (postImport calculates; Default based on ID.VendorType [BSP/NONBSP -> N, else Y])
-- Text25 - Sales Tax Indicator                             (postImport calculates; Default based on ID.TaxAmt)
-- Text26 - Product Code                                    (postImport calculates; default based on ID.VendorType)  
-- Text31-Text45 - Client Reference 1-15                    (default Parsed Fields mapping from UDID [supplier-specific])
-- Text47 - Max Segment Num                                 (postImport calculates)
-- Text48 - Num Segments                                    (postImport calculates)
-- Text49 - reserved as post-import completion flag         (used only by post-import; prevents reprocessing of a dataset)
-- Text50 - VDU Export Flag                                 (not set in postImport; utilized during export processing)

CREATE PROCEDURE [dbo].[sp_CITI_VDU_postImport_STDIMPT5]
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
                    WHERE IataNum IN (SELECT DISTINCT IataNum FROM dba.VDU_Feeds WHERE ImportGroup='STDIMPT5'))
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

-- TBD


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
--TBD - currently no deviations from default usage of Parsed Field (usually ID.VendorName or ID.InvoiceTypeDescription)

--UPDATE
--   cr
--SET
--   cr.Text23 = id.vendorName
--FROM
--   dba.ComRmks cr
--   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
--   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
--WHERE
--   ih.IMPORTDT = @fileKey

-- Text24 - Merchant Indicator
-- Default based on VendorType - BSP/NONBSP are non-Merchant, others are Merchant
UPDATE
   cr
SET
   cr.Text24 = CASE WHEN ((id.vendorType = 'BSP') OR
                          (id.vendorType = 'NONBSP')) THEN 'N'
                    ELSE 'Y'
               END
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey AND id.IataNum = cr.IataNum AND id.ClientCode = cr.ClientCode AND id.InvoiceDate = cr.InvoiceDate AND id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey
   AND (cr.text24 IS NULL OR cr.text24='')


-- Text25 - Sales Tax Indicator
UPDATE
  cr
SET text25='Y'
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey AND ih.IataNum = cr.IataNum AND ih.ClientCode = cr.ClientCode AND ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey AND id.IataNum = cr.IataNum AND id.ClientCode = cr.ClientCode AND id.InvoiceDate = cr.InvoiceDate AND id.SeqNum = cr.SeqNum
WHERE
   ih.IMPORTDT = @fileKey
   AND (cr.text25 IS NULL OR cr.text25='')
   AND (id.taxamt IS NOT NULL AND id.taxamt<>0.0)

-- Text26 - Product Code
-- Default based on standard GTA/ATD mapping into ID.VendorType
UPDATE
   cr
SET
   cr.Text26 = id.VendorType
FROM
   dba.ComRmks cr
   JOIN dba.InvoiceHeader ih ON ih.RecordKey = cr.RecordKey and ih.IataNum = cr.IataNum and ih.ClientCode = cr.ClientCode and ih.InvoiceDate = cr.InvoiceDate
   JOIN dba.InvoiceDetail id ON id.RecordKey = cr.RecordKey and id.IataNum = cr.IataNum and id.ClientCode = cr.ClientCode and id.InvoiceDate = cr.InvoiceDate and id.SeqNum = cr.SeqNum
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

-- BCD feeds have a 2-char alphabetic prefix to the ccnum
-- 2014-06-13 - no longer needed.  Encrypted feeds have non-numeric prefix stripped during import.
--IF @fileIata like 'CEBC%'
--BEGIN
--   UPDATE dba.InvoiceHeader
--   SET ccnum=right(ccnum,len(ccnum)-2)
--   WHERE
--      IMPORTDT = @fileKey and left(ccnum,2) in ('VI','CA')
--END

-- BCD CA - Rockwell Collins is currently providing a masked ccnum
-- this is an override for the Rockwell Collins CTA
IF @fileIata='CEBCDRCA'
BEGIN
   UPDATE dba.InvoiceHeader
   SET ccnum='70bdb009-7fc6-4f2f-a3dd-373c204b33bb'
   WHERE
      IMPORTDT = @fileKey and ccnum='5525XXXXXXX2276'
END

-- BCD US - Rockwell Collins is currently providing a masked ccnum
-- this is an override for the Rockwell Collins CTA
IF @fileIata='CEBCDRC'
BEGIN
   UPDATE dba.InvoiceHeader
   SET ccnum='c32d13bc-44e9-484a-a576-a40584d204da'
   WHERE
      IMPORTDT = @fileKey and ccnum='5472XXXXXXX4934'
END

-- CTMS requires card replacement of masked values, custom tax mapping
IF (@fileIata='CECTMSCA' OR
    @fileIata='CECTMSUS')
BEGIN
   UPDATE ih SET ih.ccnum='f0f2636e-86b4-43e3-9a08-2c1c91483f9d',
                 ih.ccfirstsix='552522',
                 ih.cclastfour='4181'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey 
      AND ih.iataNum='CECTMSUS'
      AND ih.ccnum='55XXXX4181'
      
   -- GST -> CR6
   -- HST -> CR7 (not currently supported by CTMS)
   -- QST -> CR8
   UPDATE cr SET cr.text36=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum like 'CECTMS%' AND tx.taxseqnum=5

   --UPDATE cr SET cr.text37=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   --FROM dba.comrmks cr
   --     join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
   --     join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   --WHERE
   --   ih.IMPORTDT = @fileKey AND cr.iataNum like 'CECTMS%' AND tx.taxid='RC'

   UPDATE cr SET cr.text38=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum like 'CECTMS%' AND tx.taxseqnum=6
END

-- CWT NA (Prism feed) has client-specific UDEF mappings
IF (@fileIata='CECWTPR' OR 
    @fileIata='CECWTPT')
BEGIN
   -- Givaudan (CFA JQF)
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('JQF') AND ud.udefNum=3

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('JQF') AND ud.udefNum=8

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('JQF') AND ud.udefNum=5

   UPDATE cr SET cr.text34=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('JQF') AND ud.udefNum=11

   UPDATE cr SET cr.text35=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('JQF') AND ud.udefNum=20

   -- Henkel (CFA HEK & HNA)
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=3

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=8

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=9

   UPDATE cr SET cr.text34=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=10

   UPDATE cr SET cr.text35=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=11

   UPDATE cr SET cr.text36=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=12

   UPDATE cr SET cr.text37=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=15

   UPDATE cr SET cr.text38=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=16

   UPDATE cr SET cr.text39=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=20

   UPDATE cr SET cr.text41=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=14

   UPDATE cr SET cr.text42=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=19

   UPDATE cr SET cr.text43=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=21

   UPDATE cr SET cr.text44=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=22

   UPDATE cr SET cr.text45=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('HEK','HNA') AND ud.udefNum=23

   -- Loblaws Inc CA
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=1

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=2

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=8

   UPDATE cr SET cr.text34=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=10

   UPDATE cr SET cr.text35=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=11

   UPDATE cr SET cr.text36=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=14

   UPDATE cr SET cr.text37=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=21

   UPDATE cr SET cr.text38=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=22

   UPDATE cr SET cr.text39=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('2KT','3QQ','4VY','T9Z') AND ud.udefNum=23

   -- Loblaws Inc US
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('4TP','6ES') AND ud.udefNum=1

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('4TP','6ES') AND ud.udefNum=2

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('4TP','6ES') AND ud.udefNum=10

   UPDATE cr SET cr.text34=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('4TP','6ES') AND ud.udefNum=16

   UPDATE cr SET cr.text35=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('4TP','6ES') AND ud.udefNum=20

   -- JFS Inc (Loblaws) US
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('VC3') AND ud.udefNum=1

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('VC3') AND ud.udefNum=2

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('VC3') AND ud.udefNum=10

   UPDATE cr SET cr.text34=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('VC3') AND ud.udefNum=16

   UPDATE cr SET cr.text35=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('VC3') AND ud.udefNum=20

   -- T&T Supermarkat (Loblaws)
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('7RK') AND ud.udefNum=2

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('7RK') AND ud.udefNum=14

   UPDATE cr SET cr.text33=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CECWTPR','CECWTPT') AND ud.clientCode IN ('7RK') AND ud.udefNum=19

   -- Approval/Auth Code conveyed in UDEF99.
   UPDATE ih SET ih.ccapprovalcode=ud.udefdata
   FROM dba.invoiceheader ih
        join dba.udef ud ON ih.recordkey=ud.recordkey AND ih.iataNum=ud.iataNum AND ih.clientCode=ud.clientCode AND ih.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum in ('CECWTPR','CECWTPT') AND ud.udefNum=99
END

-- Egencia requires card replacement, has tax mappings
IF (@fileIata='CEEGSB')
BEGIN
   UPDATE ih SET ih.ccnum='33de8f7e-23ba-40c4-835f-0f5d608e3d30',
                 ih.ccfirstsix='404658',
                 ih.cclastfour='7722'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.ccnum='404658xxxxxx7722'

   UPDATE ih SET ih.ccnum='3d3bb20f-b955-4f72-b511-cbd4226879ef',
                 ih.ccfirstsix='404658',
                 ih.cclastfour='7730'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.ccnum='404658xxxxxx7730'

   UPDATE ih SET ih.ccnum='34aa59c4-77c6-4a10-9a0e-e721a4ed9955',
                 ih.ccfirstsix='480868',
                 ih.cclastfour='1290'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.ccnum='480868xxxxxx1290'

   UPDATE ih SET ih.ccnum='6c9e2d70-1b41-4f73-8ed2-2c4e1f57b380',
                 ih.ccfirstsix='480868',
                 ih.cclastfour='1308'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.ccnum='480868xxxxxx1308'

   -- US:
   -- Tax (XT) -> CR4
   UPDATE cr SET cr.text34=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.origCountry='US' AND tx.taxid='XT'

   -- CA:
   -- GST (XG) -> CR4
   -- HST (RC) -> CR5
   -- QST (XQ) -> CR6
   UPDATE cr SET cr.text34=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.origCountry='CA' AND tx.taxid='XG'

   UPDATE cr SET cr.text35=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.origCountry='CA' AND tx.taxid='RC'

   UPDATE cr SET cr.text36=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND ih.iataNum='CEEGSB'
      AND ih.origCountry='CA' AND tx.taxid='XQ'
END

-- Groupe Encore - George Weston - Groupe Encore is currently providing a masked 
-- ccnum which is only in the Payment table.  
IF @fileIata='CEGEGW'
BEGIN
   UPDATE ih    
   SET ih.ccnum='27f99559-c0e3-4929-8bdb-8a09beaa9cc7',ih.ccfirstsix='552522',ih.cclastfour='4082'
   FROM dba.InvoiceHeader ih
        join dba.Payment pay ON ih.RecordKey = pay.RecordKey AND ih.IataNum = pay.IataNum AND ih.ClientCode = pay.ClientCode AND ih.InvoiceDate = pay.InvoiceDate
   WHERE
      IH.IMPORTDT = @fileKey AND pay.ccnum='xxxxxxxxxx00774082'
END

-- HRG CA - client has TAX mapping requirements
-- HST -> CR7
-- GST -> CR8
-- QST -> CR9
IF (@fileIata='CEHRBMCA')
BEGIN
   UPDATE cr SET cr.text37=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CEHRBMCA') AND tx.taxid='RC'

   UPDATE cr SET cr.text38=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CEHRBMCA') AND tx.taxid='XG'

   UPDATE cr SET cr.text39=ltrim(STR(CONVERT(decimal(12,2),tx.taxamt), 12, 2))
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.tax tx ON cr.recordkey=tx.recordkey AND cr.seqNum=tx.seqNum AND cr.iataNum=tx.iataNum AND cr.clientCode=tx.clientCode AND cr.invoiceDate=tx.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CEHRBMCA') AND tx.taxid='XQ'
END

-- Vision 2000 has client-specific UDEF mappings
-- UDEF28 - Cost Center
-- UDEF126 - Approver
IF (@fileIata='CEVICA')
BEGIN
   UPDATE cr SET cr.text31=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CEVICA') AND ud.udefNum=28

   UPDATE cr SET cr.text32=ud.udefdata
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON ih.recordkey=cr.recordkey AND ih.iataNum=cr.iataNum AND ih.clientCode=cr.clientCode AND ih.invoiceDate=cr.invoiceDate
        join dba.udef ud ON cr.recordkey=ud.recordkey AND cr.seqNum=ud.seqNum AND cr.iataNum=ud.iataNum AND cr.clientCode=ud.clientCode AND cr.invoiceDate=ud.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey AND cr.iataNum in ('CEVICA') AND ud.udefNum=126
END

-- World Travel requires card replacement of masked values
IF (@fileIata='CEWTIVWR')
BEGIN
   UPDATE ih SET ih.ccnum='a5211ed0-23c1-4525-96ac-c6d19fdce60e',
                 ih.ccfirstsix='404658',
                 ih.cclastfour='7569'
   FROM DBA.invoiceheader ih
   WHERE
      ih.IMPORTDT = @fileKey 
      AND ih.iataNum='CEWTIVWR'
      AND ih.ccnum='404658****7569'
END


-- BIN Filters for feeds that include non-Citi data
IF (@fileIata='CEVICA')
BEGIN
   UPDATE cr SET cr.text50='halt-nonciti'
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON cr.recordkey=ih.recordkey AND cr.iataNum=ih.iataNum AND cr.clientCode=ih.clientCode AND cr.invoiceDate=ih.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey 
      AND cr.iataNum in ('CEVICA') 
      AND (ih.CCNum IS NULL 
           OR ih.CCNum=''
           OR (len(ih.CCNum)=16 AND left(ih.CCNum,6)<>'480868')
           OR (ih.CCFirstSix IS NOT NULL AND ih.CCFirstSix <> '480868'))
END

IF (@fileIata='CECTMSCA' OR 
    @fileIata='CECTMSUS')
BEGIN
   UPDATE cr SET cr.text50='halt-nonciti'
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON cr.recordkey=ih.recordkey AND cr.iataNum=ih.iataNum AND cr.clientCode=ih.clientCode AND cr.invoiceDate=ih.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey 
      AND cr.iataNum LIKE 'CECTMS%' 
      AND (ih.CCNum IS NULL 
           OR ih.CCNum=''
           OR NOT (ih.CCCode IS NOT NULL AND ih.CCCode='MC'
                   AND ih.CCFirstSix IS NOT NULL AND ih.CCFirstSix='552522'
                   AND ih.CCLastFour IS NOT NULL AND ih.CCLastFour IN ('4082','4090','4108','4116','4181','4207')))
END


IF (@fileIata='CEWTIVWR')
BEGIN
   UPDATE cr SET cr.text50='halt-nonciti'
   FROM dba.comrmks cr
        join dba.invoiceheader ih ON cr.recordkey=ih.recordkey AND cr.iataNum=ih.iataNum AND cr.clientCode=ih.clientCode AND cr.invoiceDate=ih.invoiceDate
   WHERE
      ih.IMPORTDT = @fileKey 
      AND cr.iataNum IN ('CEWTIVWR')
      AND (ih.CCNum IS NULL 
           OR ih.CCNum=''
           OR (ih.CCFirstSix IS NOT NULL AND ih.CCFirstSix <> '404658')
          )
END


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
