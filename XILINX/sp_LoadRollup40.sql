/****** Object:  StoredProcedure [dba].[LoadRollup40]    Script Date: 7/7/2015 12:06:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dba].[LoadRollup40]
as 
begin

BEGIN TRANSACTION
update dba.costructload
set child =  right('000000' + convert(varchar, child, 6), 6)


update dba.costructload
set parent =  right('000000' + convert(varchar, parent, 6), 6)
where parent<>''

COMMIT TRANSACTION


BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child
, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
, t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc], t1.Child, [desc]
 from dba.costructload t1
where parent = ''
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup1
and t2.COSTRUCTID = 'MANAGERIAL_new'
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup2
and t2.rollup2 <> t2.rollup1
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup3
and t2.rollup3 <> t2.rollup2
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup4
and t2.rollup4 <> t2.rollup3
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup5
and t2.rollup5 <> t2.rollup4
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup6
and t2.rollup6 <> t2.rollup5
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup7
and t2.rollup7 <> t2.rollup6
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, t1.Child, t1.[desc], t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup8
and t2.rollup8 <> t2.rollup7
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
INSERT INTO DBA.Rollup40
select 'MANAGERIAL_new', t1.Child, t1.[desc], ROLLUP1, ROLLUPDESC1, ROLLUP2, ROLLUPDESC2, ROLLUP3, ROLLUPDESC3, ROLLUP4, ROLLUPDESC4
, ROLLUP5, ROLLUPDESC5, ROLLUP6, ROLLUPDESC6, ROLLUP7, ROLLUPDESC7, ROLLUP8, ROLLUPDESC8, ROLLUP9, ROLLUPDESC9, t1.Child
, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
, t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc], t1.Child, t1.[desc]
 from dba.costructload t1, dba.Rollup40 t2
where t1.parent = t2.rollup9
and t2.rollup9 <> t2.rollup8
and t2.COSTRUCTID = 'MANAGERIAL_new'
order by 2
COMMIT TRANSACTION

BEGIN TRANSACTION
insert into dba.rollup40
values ('MANAGERIAL_new','Not Provided','Not Provided','009571','Gavrielov, Moshe','Not Provided', 'Not Provided', NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL,NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL,NULL)
COMMIT TRANSACTION




begin tran
delete dba.ROLLUP40
where COSTRUCTID = 'MANAGERIAL'
commit

begin tran
update dba.ROLLUP40
set COSTRUCTID = 'MANAGERIAL'
where COSTRUCTID = 'MANAGERIAL_new'
commit



end

GO

ALTER AUTHORIZATION ON [dba].[LoadRollup40] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[costructload]    Script Date: 7/7/2015 12:06:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dba].[costructload](
	[child] [varchar](50) NULL,
	[desc] [varchar](255) NULL,
	[parent] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER AUTHORIZATION ON [dba].[costructload] TO  SCHEMA OWNER 
GO

/****** Object:  Table [dba].[ROLLUP40]    Script Date: 7/7/2015 12:06:07 PM ******/
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

/****** Object:  Index [ROLLUP40_I1]    Script Date: 7/7/2015 12:06:20 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUP40_I1] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP1] ASC,
	[ROLLUP2] ASC,
	[ROLLUP3] ASC,
	[ROLLUP4] ASC,
	[ROLLUP5] ASC,
	[ROLLUP6] ASC,
	[ROLLUP7] ASC,
	[ROLLUP8] ASC,
	[ROLLUP9] ASC,
	[ROLLUP10] ASC,
	[ROLLUP11] ASC,
	[ROLLUP12] ASC,
	[ROLLUP13] ASC,
	[ROLLUP14] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ROLLUP40_PX]    Script Date: 7/7/2015 12:06:22 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [ROLLUP40_PX] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [PRIMARY]
GO

/****** Object:  Index [ROLLUPI1]    Script Date: 7/7/2015 12:06:22 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI1] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ROLLUPI2]    Script Date: 7/7/2015 12:06:22 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI2] ON [dba].[ROLLUP40]
(
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [ROLLUPI3]    Script Date: 7/7/2015 12:06:23 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPI3] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[ROLLUP1] ASC,
	[ROLLUP2] ASC,
	[ROLLUP3] ASC,
	[ROLLUP4] ASC,
	[ROLLUP5] ASC,
	[ROLLUP6] ASC,
	[ROLLUP7] ASC,
	[ROLLUP8] ASC,
	[ROLLUP9] ASC,
	[ROLLUP10] ASC,
	[ROLLUP11] ASC,
	[ROLLUP12] ASC,
	[ROLLUP13] ASC,
	[ROLLUP14] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 98) ON [INDEXES]
GO

/****** Object:  Index [ROLLUPPX]    Script Date: 7/7/2015 12:06:24 PM ******/
CREATE NONCLUSTERED INDEX [ROLLUPPX] ON [dba].[ROLLUP40]
(
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  Index [RUI1]    Script Date: 7/7/2015 12:06:24 PM ******/
CREATE NONCLUSTERED INDEX [RUI1] ON [dba].[ROLLUP40]
(
	[ROLLUP1] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI10]    Script Date: 7/7/2015 12:06:24 PM ******/
CREATE NONCLUSTERED INDEX [RUI10] ON [dba].[ROLLUP40]
(
	[ROLLUP10] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI2]    Script Date: 7/7/2015 12:06:24 PM ******/
CREATE NONCLUSTERED INDEX [RUI2] ON [dba].[ROLLUP40]
(
	[ROLLUP2] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI3]    Script Date: 7/7/2015 12:06:25 PM ******/
CREATE NONCLUSTERED INDEX [RUI3] ON [dba].[ROLLUP40]
(
	[ROLLUP3] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI4]    Script Date: 7/7/2015 12:06:26 PM ******/
CREATE NONCLUSTERED INDEX [RUI4] ON [dba].[ROLLUP40]
(
	[ROLLUP4] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI5]    Script Date: 7/7/2015 12:06:26 PM ******/
CREATE NONCLUSTERED INDEX [RUI5] ON [dba].[ROLLUP40]
(
	[ROLLUP5] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI6]    Script Date: 7/7/2015 12:06:27 PM ******/
CREATE NONCLUSTERED INDEX [RUI6] ON [dba].[ROLLUP40]
(
	[ROLLUP6] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI7]    Script Date: 7/7/2015 12:06:27 PM ******/
CREATE NONCLUSTERED INDEX [RUI7] ON [dba].[ROLLUP40]
(
	[ROLLUP7] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI8]    Script Date: 7/7/2015 12:06:28 PM ******/
CREATE NONCLUSTERED INDEX [RUI8] ON [dba].[ROLLUP40]
(
	[ROLLUP8] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [RUI9]    Script Date: 7/7/2015 12:06:28 PM ******/
CREATE NONCLUSTERED INDEX [RUI9] ON [dba].[ROLLUP40]
(
	[ROLLUP9] ASC,
	[COSTRUCTID] ASC,
	[CORPORATESTRUCTURE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

