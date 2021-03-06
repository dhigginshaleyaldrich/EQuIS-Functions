USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_HAI_Get_ActionLevels]    Script Date: 11/29/2017 9:36:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Accepts parameter list from EQuIS report and returns action level(s)
--Created by Dan Higgins on 8/20/2015



ALTER function [rpt].[fn_HAI_Get_ActionLevels] (
	@facility_id int, 
	@action_level_codes varchar(1000))


  returns @action_level table(
  facility_id int,
  al_code varchar(1000),
  al_value varchar(20),
  al_param_code varchar (200),
  chemical_name varchar (200),
  al_unit varchar(10),
  al_fraction varchar(10),
  al_matrix varchar(10),
  al_subscript varchar (10),
  al_source varchar (500)
  )

 as
  begin

  if (select count(@action_level_codes)) >0
	begin
		insert into @action_level
		select @facility_id, 
		replace(al.action_level_code,'-','_') as action_level_code,
		alp.action_level,
		alp.param_code,
		ra.chemical_name,
		alp.unit,
		alp.fraction,
		alp.matrix,
		alp.action_level_note,
		alp.custom_field_5
		from dt_action_level_parameter alp
		inner join dt_action_level al on alp.action_level_code = al.action_level_code
		inner join rt_analyte ra on alp.param_code = ra.cas_rn
		where 
		--coalesce(al.facility_id,@facility_id) = @facility_id and
		al.action_level_code in (select cast(value as varchar(300))from equis.split(@action_level_codes))
	end



return
end

