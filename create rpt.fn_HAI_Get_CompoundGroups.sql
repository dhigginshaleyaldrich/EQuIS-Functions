USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_HAI_Get_TaskCode]    Script Date: 10/13/2017 9:13:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


alter function [rpt].[fn_HAI_Get_CompoundGroups] (
	@facility_id int, 
	@compound_groups varchar(2000))


  returns @compounds table(
  facility_id int,
  compound_group varchar(40),
  analytic_method varchar (40)
  )

 as
  begin
  if (select count(@compound_groups)) >0
	begin
		insert into @compounds
		select @facility_id, rgm.group_code as compound_group , member_code as analytic_method  from rt_group_member rgm
		inner join rt_group rg on rgm.group_code = rg.group_code
		where rg.group_type = 'compound_group'
		and rg.group_code in (select cast(value as varchar(200))from equis.split(@compound_groups))
		and member_code in (select distinct analytic_method from dt_test where facility_id = @facility_id)
	end

	if (select count(*) from @compounds) = 0
	begin
		insert into @compounds
		select @facility_id, rgm.group_code as compound_group , member_code as analytic_method  from rt_group_member rgm
		inner join rt_group rg on rgm.group_code = rg.group_code
		where rg.group_type = 'compound_group'
		and member_code in (select analytic_method from dt_test where facility_id = @facility_id)
	end
return
end

