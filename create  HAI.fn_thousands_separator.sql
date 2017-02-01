USE [equis]
GO
/****** Object:  UserDefinedFunction [HAI].[fn_thousands_separator]    Script Date: 1/31/2017 4:15:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER function [HAI].[fn_thousands_separator]                          
	(@val varchar(30))   
returns varchar(30)  -- target value
as 
begin
	declare @new_val varchar(30)
	declare @val_dec varchar(30)
	declare @minus varchar(30)

	set @val = ltrim(rtrim(@val))
	if left(rtrim(@val),1) = '-'
	begin
		set @new_val = right(@val,len(@val)-1)
		set @val =@new_val
		set @minus = '-'
	end

	if charindex('-',@val) = 0
	begin
		set @new_val = @val
	end

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

		if len(@New_val) > 15
		set @new_val = left(@new_val,len(@new_val)-15 )+ ',' + right(@new_val,15)
		--Set @new_val =  @val 
		end
	
	return  coalesce(@minus,'') + @new_val --+ @val_dec
	
end;
