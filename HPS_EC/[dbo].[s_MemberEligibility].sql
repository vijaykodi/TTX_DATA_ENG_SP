/****** Object:  StoredProcedure [dbo].[s_MemberEligibility]    Script Date: 7/14/2015 7:34:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[s_MemberEligibility]
AS
BEGIN

SET NOCOUNT ON
DECLARE @begin_count int, @end_count int

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MemberEligibility_temp]') AND type in (N'U'))
DROP TABLE [dbo].[MemberEligibility_temp]

select ME_CI_ID, ME_ID, 1 AS ME_ELIG_SEQ, ME_ELIG_TYPE, ME_ELIG_PLAN, ME_ELIG_COV, ME_ELIG
into dbo.MemberEligibility_temp 
from dbo.claimbasemembereligibility

CREATE UNIQUE CLUSTERED INDEX [MemberEligibilityPX] ON [dbo].[MemberEligibility_temp] 
(
	[ME_CI_ID] ASC,
	[ME_ID] ASC,
	[ME_ELIG_SEQ] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 2 AS ME_ELIG_SEQ, ME_ELIG_TYPE_2, ME_ELIG_PLAN_2, ME_ELIG_COV_2, ME_ELIG_2
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 3 AS ME_ELIG_SEQ, ME_ELIG_TYPE_3, ME_ELIG_PLAN_3, ME_ELIG_COV_3, ME_ELIG_3
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 4 AS ME_ELIG_SEQ, ME_ELIG_TYPE_4, ME_ELIG_PLAN_4, ME_ELIG_COV_4, ME_ELIG_4
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 5 AS ME_ELIG_SEQ, ME_ELIG_TYPE_5, ME_ELIG_PLAN_5, ME_ELIG_COV_5, ME_ELIG_5
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 6 AS ME_ELIG_SEQ, ME_ELIG_TYPE_6, ME_ELIG_PLAN_6, ME_ELIG_COV_6, ME_ELIG_6
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 7 AS ME_ELIG_SEQ, ME_ELIG_TYPE_7, ME_ELIG_PLAN_7, ME_ELIG_COV_7, ME_ELIG_7
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 8 AS ME_ELIG_SEQ, ME_ELIG_TYPE_8, ME_ELIG_PLAN_8, ME_ELIG_COV_8, ME_ELIG_8
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 9 AS ME_ELIG_SEQ, ME_ELIG_TYPE_9, ME_ELIG_PLAN_9, ME_ELIG_COV_9, ME_ELIG_9
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 10 AS ME_ELIG_SEQ, ME_ELIG_TYPE_10, ME_ELIG_PLAN_10, ME_ELIG_COV_10, ME_ELIG_10
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 11 AS ME_ELIG_SEQ, ME_ELIG_TYPE_11, ME_ELIG_PLAN_11, ME_ELIG_COV_11, ME_ELIG_11
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 12 AS ME_ELIG_SEQ, ME_ELIG_TYPE_12, ME_ELIG_PLAN_12, ME_ELIG_COV_12, ME_ELIG_12
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 13 AS ME_ELIG_SEQ, ME_ELIG_TYPE_13, ME_ELIG_PLAN_13, ME_ELIG_COV_13, ME_ELIG_13
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 14 AS ME_ELIG_SEQ, ME_ELIG_TYPE_14, ME_ELIG_PLAN_14, ME_ELIG_COV_14, ME_ELIG_14
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 15 AS ME_ELIG_SEQ, ME_ELIG_TYPE_15, ME_ELIG_PLAN_15, ME_ELIG_COV_15, ME_ELIG_15
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 16 AS ME_ELIG_SEQ, ME_ELIG_TYPE_16, ME_ELIG_PLAN_16, ME_ELIG_COV_16, ME_ELIG_16
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 17 AS ME_ELIG_SEQ, ME_ELIG_TYPE_17, ME_ELIG_PLAN_17, ME_ELIG_COV_17, ME_ELIG_17
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 18 AS ME_ELIG_SEQ, ME_ELIG_TYPE_18, ME_ELIG_PLAN_18, ME_ELIG_COV_18, ME_ELIG_18
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 19 AS ME_ELIG_SEQ, ME_ELIG_TYPE_19, ME_ELIG_PLAN_19, ME_ELIG_COV_19, ME_ELIG_19
from dbo.claimbasemembereligibility

insert into dbo.MemberEligibility_temp 
select ME_CI_ID, ME_ID, 20 AS ME_ELIG_SEQ, ME_ELIG_TYPE_20, ME_ELIG_PLAN_20, ME_ELIG_COV_20, ME_ELIG_20
from dbo.claimbasemembereligibility

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MemberEligibility]') AND type in (N'U'))
		exec sp_rename 'MemberEligibility_temp','MemberEligibility'
ELSE
	BEGIN

		select @begin_count = count(*) from dbo.MemberEligibility
		select @end_count = count(*) from dbo.MemberEligibility_temp

		if @begin_count <= @end_count
		begin
			begin transaction

				exec sp_rename 'MemberEligibility','MemberEligibility1'
				exec sp_rename 'MemberEligibility_temp','MemberEligibility'
				exec sp_rename 'MemberEligibility1','MemberEligibility_temp'

			commit;
		end

	END

END

GO
