USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_List]    Script Date: 10/13/2017 12:18:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [rpt].[fn_List]  (@facility_id int, @sys_sample_code varchar (40))

returns varchar (max)
 as
 begin

declare @list varchar (max)

	SELECT @list =  ISNULL(@list,'') + analytic_method + '; ' 
	FROM (select distinct sys_sample_code, lab_sdg ,analytic_method from dt_sample s 
	inner join dt_test t on s.facility_id = t.facility_id and s.sample_id = t.sample_id
		where s.facility_id = @facility_id
	
	and sys_sample_code =  @sys_sample_code) p

	set @list = left(@list,len(@list) -1)

 return @list
 end
 
 