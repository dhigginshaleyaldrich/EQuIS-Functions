USE [EQuIS]
GO
/****** Object:  UserDefinedFunction [rpt].[fn_HAI_EQuIS_Results]    Script Date: 1/3/2018 2:21:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [rpt].[fn_HAI_EQuIS_Results](@facility_id int, @target_unit varchar(15),@limit_type varchar (10), @coord_type varchar(20))


	Returns Table
	As Return

	Select
		s.facility_id,
		s.sample_id,
		t.test_id,
		s.sys_sample_code,
		s.sample_name,
		t.lab_sample_id,
		fs.field_sdg,
		l.subfacility_code,
		sf.subfacility_name,
		coalesce(s.sys_loc_code,'none') as sys_loc_code,
		coalesce(l.loc_name,'none') as loc_name,
		l.loc_type,
		s.sample_date,
		s.duration,
		s.duration_unit,
		s.matrix_code,
		s.sample_type_code,
		s.sample_source,
		coalesce(s.task_code,'none') as task_code,
		s.start_depth,
		s.end_depth,
		s.depth_unit,
		g.compound_group,
		t.analytic_method,
		t.leachate_method,
		t.dilution_factor,
		t.fraction ,
		t.test_type,
		coalesce(t.lab_sdg,'No_SDG')as lab_sdg,
		t.lab_name_code,
		t.analysis_date,
		t.analysis_location,
		ra.chemical_name,
		r.cas_rn,
		r.result_text,
		r.result_numeric,
		r.reporting_detection_limit,
		r.method_detection_limit,
		r.result_error_delta,
		case when r.detect_flag = 'N' then r.reporting_detection_limit else r.result_text end as result,
		r.result_unit as reported_result_unit,
		r.detect_flag,
		r.reportable_result,
		r.result_type_code,
		r.lab_qualifiers,
		r.validator_qualifiers,
		r.interpreted_qualifiers,
		r.validated_yn,
		approval_code,
		approval_a,
		case 
			when r.interpreted_qualifiers is not null then r.interpreted_qualifiers
			when r.detect_flag = 'N' then 'U' 
		end as qualifier,


		cast(case 
			when r.detect_flag = 'N' and coalesce(@limit_type,'RL') = 'RL' then  --default to RL
			equis.significant_figures(equis.unit_conversion_result(coalesce(reporting_detection_limit,result_text), r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(reporting_detection_limit,result_text) ),default)
			when r.detect_flag = 'N' and @limit_type = 'MDL' then 
			equis.significant_figures(equis.unit_conversion_result(coalesce(method_detection_limit,result_text), r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(method_Detection_limit,result_text) ),default)
			when r.detect_flag = 'N' and @limit_type = 'PQL' then 
			equis.significant_figures(equis.unit_conversion_result(quantitation_limit, r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(quantitation_limit ),default)
			/*FOR RAD RESULTS*/
			when r.detect_flag = 'N' and @limit_type = 'Result' then 
			equis.significant_figures(equis.unit_conversion_result(result_numeric, r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(result_text),default)  --for RAD
			
			when r.detect_flag = 'Y' then
			equis.significant_figures(equis.unit_conversion_result(r.result_numeric,r.result_unit,coalesce(@target_unit,r.result_unit), default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(r.result_text,rpt.trim_zeros(cast(r.result_numeric as varchar)))),default) 
			end as varchar)
			as converted_result, 
	  
			coalesce(case when r.interpreted_qualifiers is not null and charindex(',',r.interpreted_qualifiers) >0 then  left(r.interpreted_qualifiers, charindex(',',r.interpreted_qualifiers)-1)
			when r.interpreted_qualifiers is not null then r.interpreted_qualifiers
			when r.validator_qualifiers is not null then r.validator_qualifiers
			when detect_flag = 'N' and interpreted_qualifiers is null then 'U' 
			when validated_yn = 'N' and charindex('J',lab_qualifiers) >0 then 'J'
			else ''
		end, '') as reporting_qualifier,

/*uses interpreted qualifiers to determine if result is not detected*/
		cast(case 
			/*detect flag = 'Y' and interpreteted qualifiers like '%U%' or like '%R%'*/		
			when (r.interpreted_qualifiers like '%U%' or r.interpreted_qualifiers like '%R%' ) and detect_flag = 'Y' then  
			equis.significant_figures(equis.unit_conversion_result(coalesce(result_text,reporting_detection_limit), r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(result_text,reporting_detection_limit) ),default)
			
			/*detection limit = 'RL' and detect flag = 'N' and interpreted qualifiers like '%U%' or like '%R%'*/
			when (r.interpreted_qualifiers like '%U%' or r.interpreted_qualifiers like '%R%' ) and detect_flag = 'N' and coalesce(@limit_type,'RL') = 'RL' then  --default to RL
			equis.significant_figures(equis.unit_conversion_result(coalesce(reporting_detection_limit,result_text), r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(reporting_detection_limit,result_text) ),default)
			
			/*detection limit = 'MDL' and detect flag = 'N' and interpreted qualifiers like '%U%' or like '%R%'*/
			when (r.interpreted_qualifiers like '%U%' or r.interpreted_qualifiers like '%R%' ) and detect_flag = 'N'  and @limit_type = 'MDL' then 
			equis.significant_figures(equis.unit_conversion_result(coalesce(method_detection_limit,result_text), r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(method_Detection_limit,result_text) ),default)
			
			/*detection limit = 'PQL' and detect flag = 'N' and interpreted qualifiers like '%U%' or like '%R%'*/
			when (r.interpreted_qualifiers like '%U%' or r.interpreted_qualifiers like '%R%' ) and detect_flag = 'N'  and @limit_type = 'PQL' then 
			equis.significant_figures(equis.unit_conversion_result(quantitation_limit, r.result_unit,coalesce(@target_unit, r.result_unit),default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(quantitation_limit ),default)
		
			/*detect flag = 'Y' and interpreted qualifiers not like '%U%' and not like '%R%' or is null*/
			when ((r.interpreted_qualifiers not like '%U%' and r.interpreted_qualifiers not like '%R%') or r.interpreted_qualifiers is null) and detect_flag = 'Y' then
			equis.significant_figures(equis.unit_conversion_result(r.result_numeric,r.result_unit,coalesce(@target_unit,r.result_unit), default,null, null,  null,  r.cas_rn,null),equis.significant_figures_get(coalesce(r.result_text,rpt.trim_zeros(cast(r.result_numeric as varchar)))),default) 
		
		end as varchar)
		as converted_result_IntQual,



		coalesce(@target_unit, result_unit) as converted_result_unit,
		@limit_type as detection_limit_type,
		coord_type_code,
		x_coord,
		y_coord,
		eb.edd_date, 
		eb.edd_user,
		eb.edd_file 

	From dbo.dt_sample s
		inner join dt_test t on s.facility_id = t.facility_id and  s.sample_id = t.sample_id
		inner join dt_result r on t.facility_id = r.facility_id and t.test_id = r.test_id
		inner join rt_analyte ra on r.cas_rn = ra.cas_rn
		inner join dt_location l on s.facility_id = l.facility_id and s.sys_loc_code = l.sys_loc_code
		left join dt_subfacility sf on l.facility_Id = sf.facility_id and l.subfacility_code = sf.subfacility_code
		left join dt_field_sample fs on s.facility_id = fs.facility_id and s.sample_id = fs.sample_id
		left join st_edd_batch eb on r.ebatch = eb.ebatch
		left join (select facility_id, sys_loc_code, coord_type_code,x_coord, y_coord 
					from dt_coordinate 
					where facility_id in (select facility_id from equis.facility_group_members(@facility_id)) and coord_type_code = @coord_type)c 
				on s.facility_id = c.facility_id and s.sys_loc_code = c.sys_loc_code

		inner join  (select facility_id, facility_code
					from equis.facility_group_members(@facility_id)) f 
				on s.facility_id = f.facility_id

		left join (select member_code ,rgm.group_code as compound_group from rt_group_member rgm
				inner join rt_group rg on rgm.group_code = rg.group_code
				 where rg.group_type = 'compound_group')g
		on t.analytic_method = g.member_code

	Where
	 (case  --filter out non-numeric values
		when result_text is not null then isnumeric(result_text) 
		when reporting_detection_limit is not null then isnumeric(reporting_detection_limit)
		else -1
		 end) <> 0

	 

