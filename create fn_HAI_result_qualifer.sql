USE [EQuIS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**Creates 'Result Qualfier Column in Get EQuIS Data Report***/
/*Accepts incoming arguements specifying how the combination of result, nd flag and qualifer are presented in the [result_qualifier] column*/
ALTER function [rpt].[fn_HAI_result_qualifier]
(@result varchar(40),  --the numeric result value
 @nd_flag varchar (10),   --can be '<', 'N', or 'Y'
 @reporting_qualifier varchar (20),   --the designated qualifier to use in the report
 @interp_qualifier varchar (20),   --dt_result.interpreted_qualifier included if the reporting qualifier rules fail
 @user_qual_def varchar (10)  --User-specified result and qualifer: '< # Q'; '# Q'; '< #'; 'ND(#) Q' where # = result value, Q = reporting qualifer, < = less symbol presented with data
)
returns varchar(30)
as
begin
	/****handles cases where the detect_flag = 'Y' but the qualifer is 'U' or 'UJ' ***/
	/****For cases where an detected result is flagged as "U" by the validator with an elevated reporting limit at the reported concenctration e.g. due to method blank detection, etc.**/
		if @nd_flag = 'n' or @nd_flag = '<' 
			set @nd_flag =  '<' 
		if isnull(@nd_flag,'Y') = 'Y' and charindex('u', @reporting_qualifier ) >0  
			set @nd_flag =  '<'
		if isnull(@nd_flag,'Y') = 'Y' and charindex( 'u' , @interp_qualifier) >0 
			set @nd_flag = '<'
	
		if @nd_flag = 'Y' --clear cases where the nd_flag = 'Y' for the section below. reports should pass a null if detect_flag = 'Y', but just in case...
			set @nd_flag = NULL
	return
	rtrim(ltrim(case 
		when (@nd_flag = 'N' or @nd_flag = '<') and @result is null then 'ND'
		when @user_qual_def = '< # Q' then coalesce(@nd_flag,'') + ' '  + coalesce(@result,'check') + ' ' +  coalesce(replace(coalesce(@reporting_qualifier,@interp_qualifier),'U',''),'') 
		when @user_qual_def = '< #' then coalesce(@nd_flag,'')  + ' ' + coalesce(@result,'check') 
		when @user_qual_def = '# Q' then coalesce(@result,'check') + ' ' + coalesce(@reporting_qualifier,@interp_qualifier,'')
		when @user_qual_def = 'ND(#) Q' and @nd_flag = '<' then 
			'ND (' + @result + ') ' + coalesce(replace(coalesce(@reporting_qualifier,@interp_qualifier),'U',''),'') 
		when @user_qual_def = 'ND(#) Q' and @nd_flag is null then 
			@result + ' ' + coalesce(replace(coalesce(@reporting_qualifier,@interp_qualifier),'U',''),'') 
	
		else @result
	end))
	
end