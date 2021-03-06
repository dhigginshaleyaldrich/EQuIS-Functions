USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_thousands_separator]    Script Date: 2/19/2017 12:09:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [rpt].[fn_thousands_separator]                          
	(@val varchar(40))   
returns varchar(40)  -- target value
as 
begin
	declare @new_val varchar(20)
	declare @val_dec varchar(20)

	set @new_val = @val

	if charindex('E',@new_val)= 0  --if incoming value is in scientific notation then ignore
	begin
		

		if charindex(',',@new_val) = 0
			begin
			if charindex('.',@val) > 0
				begin
				Set @new_val = left(@val, charindex('.',@val)-1)
				Set @val_dec =coalesce(right(@val, len(@val) - charindex('.',@val)+1),'') 
				end

			if charindex('.',@val) = 0
				begin
				set @new_val = @val
				set @val_dec = ''
				end

			if len(@new_val) > 3 
			set @new_val = left(@new_val,len(@new_val)-3) + ',' + right(@new_val,3) 

			if len(@New_val) > 7
			set @new_val = left(@new_val,len(@new_val)-7 )+ ',' + right(@new_val,7)

			if len(@New_val) > 11
			set @new_val = left(@new_val,len(@new_val)-11 )+ ',' + right(@new_val,11)
			--Set @new_val =  @val 
			end
	end
	return ltrim(rtrim(@new_val + coalesce( @val_dec,'')))
	
end;
 

