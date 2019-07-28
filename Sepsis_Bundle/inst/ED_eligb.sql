/*******************************************************************************/
/*@file ED_eligb.sql
/*
/*in: ED_18up, observation_fact
/*
/*params: @dblink, &&i2b2
/*   
/*out: ED_eligb
/*
/*action: write
/********************************************************************************/
create table ED_eligb as
with ed_acu as (
select te.patient_num
      ,te.encounter_num
      ,max(obs.start_date) ed_acu_assgm_dt
from ED_18up te
join &&i2b2data.observation_fact@dblink obs
on te.patient_num = obs.patient_num and te.encounter_num = obs.encounter_num and
   obs.concept_cd like 'KUH|FLO_MEAS_ID%16054%'
group by te.patient_num,te.encounter_num
)
   ,ed_dest as (
select te.patient_num
      ,te.encounter_num
      ,max(obs.start_date) ed_dest_assgm_dt
from ED_18up te
join &&i2b2data.observation_fact@dblink obs
on te.patient_num = obs.patient_num and te.encounter_num = obs.encounter_num and
   obs.concept_cd like 'KUH|FLO_MEAS_ID%:16029%'
group by te.patient_num,te.encounter_num
)
select te.patient_num
      ,te.encounter_num
      ,te.triage_start
      ,ed_acu.ed_acu_assgm_dt
      ,ed_dest.ed_dest_assgm_dt
      ,min(obs.start_date) first_fact_dt
      ,max(obs.start_date) last_fact_dt
      ,te.enc_end
--      ,least(te.triage_start,min(obs.start_date)) triage_start
from ED_18up te
left join &&i2b2data.observation_fact@dblink obs
on te.patient_num = obs.patient_num and te.encounter_num = obs.encounter_num and
   obs.concept_cd like 'KUH|FLO_MEAS_ID%' and
   to_char(obs.start_date,'HH24:MI:SS') <> '00:00:00'
left join ed_acu on te.patient_num = ed_acu.patient_num and te.encounter_num = ed_acu.encounter_num 
left join ed_dest on te.patient_num = ed_dest.patient_num and te.encounter_num = ed_dest.encounter_num
group by te.patient_num,te.encounter_num,te.triage_start,ed_acu.ed_acu_assgm_dt,ed_dest.ed_dest_assgm_dt,te.enc_end