/*******************************************************************************/
/*@file ED_SI_LACTATE.sql
/*
/*in: SI_case_ctrl, observation_fact
/*
/*params: @dblink, &&i2b2, &&within_d
/*       
/*out: ED_SI_LACTATE
/*
/*action: write
/********************************************************************************/
create table ED_SI_LACTATE as
select obs.patient_num
      ,obs.encounter_num
      ,'Lactate' variable
      ,obs.nval_num nval
      ,obs.units_cd units
      ,obs.concept_cd code
      ,case when obs.nval_num > 2.0 then 1 else 0
       end as flag
      ,obs.start_date start_dt
      ,round((obs.start_date-init.triage_start)*24,2) start_since_triage
      ,obs.end_date end_dt
      ,round((obs.end_date-init.triage_start)*24,2) end_since_triage
from SI_case_ctrl init
join &&i2b2data.observation_fact@dblink obs
on init.patient_num = obs.patient_num and init.encounter_num = obs.encounter_num
where obs.concept_cd in ('KUH|COMPONENT_ID:2015','KUH|COMPONENT_ID:2016') and 
      obs.modifier_cd = '@' and obs.nval_num is not null and
      obs.start_date between init.triage_start and 
                             init.triage_start + &&within_d and
      to_char(obs.start_date,'HH24:MI:SS') <> '00:00:00' and
      init.case_ctrl=1



