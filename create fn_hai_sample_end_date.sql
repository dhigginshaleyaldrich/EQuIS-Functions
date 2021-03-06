USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_HAI_sample_end_date]    Script Date: 3/15/2017 11:08:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--select rpt.fn_hai_sample_end_date('26:30', 'hr', '1/1/2010')

ALTER function [rpt].[fn_HAI_sample_end_date]
(
 @duration varchar (10) 
 ,@duration_unit varchar(40) = null
 ,@sample_date datetime 
)

returns varchar(30)
as
begin

	declare @duration_value as float = 0

	declare @isnumber bit

	--check if @durantion is a number
	set @isnumber =  isnumeric(@duration)


	if @isnumber <> 0
   begin

		if left(@duration,2) <> '0'
			set @duration = '00' + right(@duration,3)


		if charindex(':',@duration)> 0 and (left(@duration,2) <> '00' or left(@duration,2) <> '0') and (charindex('h',@duration_unit) >0) 

			set @duration_value = cast(cast(left(@duration,2) as real)/24 * 24 as integer)

		if charindex(':',@duration)> 0 and right(@duration,2) <> '00' and (charindex('h',@duration_unit) >0) 

			set @duration_value = @duration_value + cast(right(@duration,2) as real)/60  

			
		if charindex(':',@duration)= 0	
			set @duration_value = @duration
	end

		return
		
			case 
				when @duration_unit = 'hours' and @duration is not null then dateadd(hour,cast(@duration_value as real),@sample_date)
				when @duration_unit = 'hour' and @duration is not null  then dateadd(hour,cast(@duration_value as real),@sample_date)
				when @duration_unit = 'hrs' and @duration is not null  then dateadd(hour,cast(@duration_value as real),@sample_date)
				when @duration_unit = 'hr' and @duration is not null  then dateadd(hour,cast(@duration_value as real),@sample_date)	
				when @duration_unit = 'days' and @duration is not null  then dateadd(day,cast(@duration_value as real),@sample_date)
				when @duration_unit = 'day' and @duration is not null  then dateadd(day,cast(@duration_value as real),@sample_date)
				else @sample_date 
			end



end