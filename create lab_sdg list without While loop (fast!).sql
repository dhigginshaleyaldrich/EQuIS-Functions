
use equis
go

set nocount on
go

alter function rpt.fn_List  (@facility_id int, @sys_sample_code varchar (40), @sample_year int )

returns varchar (max)
 as
 begin

declare @list varchar (max)

	SELECT @list =  ISNULL(@list,'') + lab_sdg + '; ' 
	FROM (select distinct sys_sample_code, lab_sdg from dt_sample s 
	inner join dt_field_sample fs on s.facility_id = fs.facility_id and s.sample_id = fs.sample_id
	inner join dt_test t on s.facility_id = t.facility_id and s.sample_id = t.sample_id
		where s.facility_id = @facility_id
	and sample_type_code = 'n'
	and year(sample_date) = @sample_year
	and sys_sample_code =  @sys_sample_code) p

	set @list = left(@list,len(@list) -1)

 return @list
 end
 
 