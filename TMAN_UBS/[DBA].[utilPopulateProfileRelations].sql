/****** Object:  StoredProcedure [DBA].[utilPopulateProfileRelations]    Script Date: 7/14/2015 7:39:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure dba.utilPopulateProfileRelationsasbegin      /*    This procedure will completely rebuild the ProfileRelations table. */      declare            @dist int,            @count int      delete from dba.ProfileRelations      insert into dba.ProfileRelations( ProfileName, Parent, dist)      select ProfileName, Parent, 1      from dba.Profiles      where Parent is not null      and Parent != ''      select @count=@@rowcount, @dist=2      while( @count > 0) begin            insert into dba.ProfileRelations( ProfileName, Parent, Dist)            select pr.ProfileName, p.parent, @dist            from dba.Profiles p                  inner join dba.ProfileRelations pr on p.ProfileName = pr.parent            where p.Parent is not null            and p.Parent != ''            and pr.Dist = (@dist - 1)                  select @count=@@rowcount, @dist = @dist + 1      endEND
GO
