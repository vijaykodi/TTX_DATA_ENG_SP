/****** Object:  StoredProcedure [dba].[LoadGeoRollup40]    Script Date: 7/7/2015 5:22:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dba].[LoadGeoRollup40]
--YL 06/04/2014
as 
insert into dba.rollup40(COSTRUCTID,CORPORATESTRUCTURE,DESCRIPTION
,ROLLUP1,ROLLUPDESC1,ROLLUP2,ROLLUPDESC2,ROLLUP3,ROLLUPDESC3)
select  distinct 'Geographical',left(BusinessAddress,40),BusinessAddress
, 'Sandvik Global','Sandvik Global'--level1
,left(businesscountry,40),businesscountry --level2
,left(BusinessAddress,40),BusinessAddress  --level3
from dba.Employee
GO

ALTER AUTHORIZATION ON [dba].[LoadGeoRollup40] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[Employee]    Script Date: 7/7/2015 5:22:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[Employee](
	[EmployeeID1] [varchar](20) NULL,
	[LastName] [varchar](35) NULL,
	[FirstName] [varchar](25) NULL,
	[MiddleName] [varchar](15) NULL,
	[EmpEmail] [varchar](100) NULL,
	[EmployeeType] [varchar](50) NULL,
	[EmployeeStatus] [varchar](20) NULL,
	[EmployeeID2] [varchar](20) NULL,
	[BusinessAddress] [varchar](50) NULL,
	[BusinessCity] [varchar](50) NULL,
	[BusinessStateCd] [varchar](20) NULL,
	[BusinessCountry] [varchar](50) NULL,
	[BusinessRegion] [varchar](50) NULL,
	[SupervisorID] [varchar](20) NULL,
	[SupervisorFirstName] [varchar](25) NULL,
	[SupervisorLastName] [varchar](35) NULL,
	[SupervisorEmail] [varchar](100) NULL,
	[CostCenter] [varchar](50) NULL,
	[DeptNumber] [varchar](50) NULL,
	[DivisionNumber] [varchar](50) NULL,
	[OrganizationUnit] [varchar](50) NULL,
	[Company] [varchar](50) NULL,
	[AdditionalInfo1] [varchar](50) NULL,
	[AdditionalInfo2] [varchar](50) NULL,
	[AdditionalInfo3] [varchar](50) NULL,
	[AdditionalInfo4] [varchar](50) NULL,
	[AdditionalInfo5] [varchar](50) NULL,
	[AdditionalInfo6] [varchar](50) NULL,
	[AdditionalInfo7] [varchar](50) NULL,
	[AdditionalInfo8] [varchar](50) NULL,
	[AdditionalInfo9] [varchar](50) NULL,
	[AdditionalInfo10] [varchar](50) NULL,
	[BeginDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ImportDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[Employee] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ROLLUP40]    Script Date: 7/7/2015 5:22:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING OFF
GO

CREATE TABLE [dba].[ROLLUP40](
	[COSTRUCTID] [varchar](20) NOT NULL,
	[CORPORATESTRUCTURE] [varchar](40) NOT NULL,
	[DESCRIPTION] [varchar](255) NULL,
	[ROLLUP1] [varchar](40) NULL,
	[ROLLUPDESC1] [varchar](255) NULL,
	[ROLLUP2] [varchar](40) NULL,
	[ROLLUPDESC2] [varchar](255) NULL,
	[ROLLUP3] [varchar](40) NULL,
	[ROLLUPDESC3] [varchar](255) NULL,
	[ROLLUP4] [varchar](40) NULL,
	[ROLLUPDESC4] [varchar](255) NULL,
	[ROLLUP5] [varchar](40) NULL,
	[ROLLUPDESC5] [varchar](255) NULL,
	[ROLLUP6] [varchar](40) NULL,
	[ROLLUPDESC6] [varchar](255) NULL,
	[ROLLUP7] [varchar](40) NULL,
	[ROLLUPDESC7] [varchar](255) NULL,
	[ROLLUP8] [varchar](40) NULL,
	[ROLLUPDESC8] [varchar](255) NULL,
	[ROLLUP9] [varchar](40) NULL,
	[ROLLUPDESC9] [varchar](255) NULL,
	[ROLLUP10] [varchar](40) NULL,
	[ROLLUPDESC10] [varchar](255) NULL,
	[ROLLUP11] [varchar](40) NULL,
	[ROLLUPDESC11] [varchar](255) NULL,
	[ROLLUP12] [varchar](40) NULL,
	[ROLLUPDESC12] [varchar](255) NULL,
	[ROLLUP13] [varchar](40) NULL,
	[ROLLUPDESC13] [varchar](255) NULL,
	[ROLLUP14] [varchar](40) NULL,
	[ROLLUPDESC14] [varchar](255) NULL,
	[ROLLUP15] [varchar](40) NULL,
	[ROLLUPDESC15] [varchar](255) NULL,
	[ROLLUP16] [varchar](40) NULL,
	[ROLLUPDESC16] [varchar](255) NULL,
	[ROLLUP17] [varchar](40) NULL,
	[ROLLUPDESC17] [varchar](255) NULL,
	[ROLLUP18] [varchar](40) NULL,
	[ROLLUPDESC18] [varchar](255) NULL,
	[ROLLUP19] [varchar](40) NULL,
	[ROLLUPDESC19] [varchar](255) NULL,
	[ROLLUP20] [varchar](40) NULL,
	[ROLLUPDESC20] [varchar](255) NULL,
	[ROLLUP21] [varchar](40) NULL,
	[ROLLUPDESC21] [varchar](255) NULL,
	[ROLLUP22] [varchar](40) NULL,
	[ROLLUPDESC22] [varchar](255) NULL,
	[ROLLUP23] [varchar](40) NULL,
	[ROLLUPDESC23] [varchar](255) NULL,
	[ROLLUP24] [varchar](40) NULL,
	[ROLLUPDESC24] [varchar](255) NULL,
	[ROLLUP25] [varchar](40) NULL,
	[ROLLUPDESC25] [varchar](255) NULL,
 CONSTRAINT [PK_ROLLUP40] PRIMARY KEY CLUSTERED 
(
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[ROLLUP40] TO  SCHEMA OWNER 
GO

/****** Object:  Index [ROLLUPI1]    Script Date: 7/7/2015 5:22:28 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI1] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

/****** Object:  Index [ROLLUPI2]    Script Date: 7/7/2015 5:22:28 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI2] ON [dba].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [INDEXES]
GO

