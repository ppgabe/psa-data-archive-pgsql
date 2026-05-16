set local work_mem = '512MB';

insert into staging.vsr_deaths ( date_of_death_month, date_of_death_day, date_of_death_year, place_of_death_region
                               , place_of_death_province, place_of_death_mun, place_of_death_region_new
                               , place_of_death_province_new, place_of_death_mun_new, place_of_death_psgc_rev_1, sex
                               , age, age_years, infant_age_days, residence_region, residence_province, residence_mun
                               , residence_region_new, residence_province_new, residence_mun_new, residence_psgc_rev_1
                               , civil_status, citizenship, place_type, attendant, registration_status, icd_code
                               , tablist)
select t.date_of_death_month
     , t.date_of_death_day
     , t.date_of_death_year
     , t.place_of_death_region
     , t.place_of_death_province
     , t.place_of_death_mun
     , t.place_of_death_region_new
     , t.place_of_death_province_new
     , t.place_of_death_mun_new
     , dpod.psgc_rev_1_code
     , t.sex
     , t.age
     , case when t.age between 201 and 299 then t.age - 200
            when t.age >= 300 and t.age < 999 then t.age - 300
            when t.age between 0 and 111 then 0 end
     , case when t.date_of_death_year = '2024' and t.age between 0 and 30 then t.age
            when t.date_of_death_year = '2023' and t.age between 0 and 28 then t.age
            when t.age between 101 and 111 then (t.age - 100) * 30 end
     , t.residence_region
     , t.residence_province
     , t.residence_mun
     , t.residence_region_new
     , t.residence_province_new
     , t.residence_mun_new
     , dpr.psgc_rev_1_code
     , t.civil_status
     , t.citizenship
     , t.place_type
     , t.attendant
     , t.registration_status
     , t.icd_code
     , t.tablist
from staging.vsr_deaths_2023_2024 as t
         left join dim_psgc as dpod on t.place_of_death_region_new || t.place_of_death_province_new ||
                                       t.place_of_death_mun_new || '000' = dpod.psgc_rev_1_code
         left join dim_psgc as dpr on residence_region_new || t.residence_province_new ||
                                      t.residence_mun_new || '000' = dpr.psgc_rev_1_code;

insert into staging.vsr_deaths ( date_of_death_month, date_of_death_day, date_of_death_year, place_of_death_region
                               , place_of_death_province, place_of_death_mun, place_of_death_psgc_rev_1, sex
                               , age, age_years, infant_age_days, residence_region, residence_province, residence_mun
                               , residence_psgc_rev_1, place_type, attendant, registration_status, icd_code)
select t.date_of_death_month
     , t.date_of_death_day
     , t.date_of_death_year
     , t.place_of_death_region
     , t.place_of_death_province
     , t.place_of_death_mun
     , dpod.psgc_rev_1_code
     , t.sex
     , t.age
     , case when t.age >= 201 and t.age < 999 then t.age - 200 when t.age between 0 and 111 then 0 end
     , case when t.age between 0 and 28 then t.age when t.age between 101 and 111 then (t.age - 100) * 30 end
     , t.residence_region
     , t.residence_province
     , t.residence_mun
     , dpr.psgc_rev_1_code
     , t.place_type
     , t.attendant
     , t.registration_status
     , t.icd_code
from staging.temp_vsr_deaths_2021_2022 as t
         left join dim_psgc as dpod on t.place_of_death_region || t.place_of_death_province ||
                                       t.place_of_death_mun || '000' = dpod.psgc_rev_1_code
         left join dim_psgc as dpr on t.residence_region || t.residence_province ||
                                      t.residence_mun || '000' = dpr.psgc_rev_1_code;

insert into staging.vsr_deaths ( date_of_death_month, date_of_death_day, date_of_death_year, place_of_death_region
                               , place_of_death_province, place_of_death_mun, place_of_death_psgc_rev_1, sex
                               , age, age_years, infant_age_days, residence_region, residence_province, residence_mun
                               , residence_psgc_rev_1, place_type, attendant
                               , registration_status, icd_code)
select t.date_of_death_month
     , t.date_of_death_day
     , t.date_of_death_year
     , t.place_of_death_region
     , t.place_of_death_province
     , t.place_of_death_mun
     , vpgd.psgc_rev_1_code
     , t.sex
     , t.age
     , case when t.age >= 201 and t.age < 999 then t.age - 200 when t.age between 0 and 111 then 0 end
     , case when t.age between 0 and 28 then t.age when t.age between 101 and 111 then (t.age - 100) * 30 end
     , t.residence_region
     , t.residence_province
     , t.residence_mun
     , vpgr.psgc_rev_1_code
     , t.place_type
     , t.attendant
     , t.registration_status
     , t.icd_code
from staging.vsr_deaths_2013_2020 as t
         left join vsr_puf_geocodes as vpgd on
                                               t.place_of_death_province::int = vpgd.vsr_province_code::int and
                                               t.place_of_death_mun::int = vpgd.vsr_municipality_code::int
         left join vsr_puf_geocodes as vpgr on
                                               t.residence_province::int = vpgr.vsr_province_code::int and
                                               t.residence_mun::int = vpgr.vsr_municipality_code::int;

insert into staging.vsr_deaths ( date_of_death_month, date_of_death_day, date_of_death_year, place_of_death_region
                               , place_of_death_province, place_of_death_mun, place_of_death_psgc_rev_1, sex
                               , age, age_years, infant_age_days, residence_region, residence_province, residence_mun
                               , residence_psgc_rev_1, attendant
                               , registration_status, icd_code)
select t.date_of_death_month
     , t.date_of_death_day
     , t.date_of_death_year
     , t.place_of_death_region
     , t.place_of_death_province
     , t.place_of_death_mun
     , vpgd.psgc_rev_1_code
     , t.sex
     , t.age
     , case when t.age >= 201 and t.age < 999 then t.age - 200 when t.age between 0 and 111 then 0 end
     , case when t.age between 0 and 28 then t.age when t.age between 101 and 111 then (t.age - 100) * 30 end
     , t.residence_region
     , t.residence_province
     , t.residence_mun
     , vpgr.psgc_rev_1_code
     , t.attendant
     , t.registration_status
     , t.icd_code
from staging.vsr_deaths_pre_2013 as t
         left join vsr_puf_geocodes as vpgd on
                                               t.place_of_death_province::int = vpgd.vsr_province_code::int and
                                               t.place_of_death_mun::int = vpgd.vsr_municipality_code::int
         left join vsr_puf_geocodes as vpgr on
                                               t.residence_province::int = vpgr.vsr_province_code::int and
                                               t.residence_mun::int = vpgr.vsr_municipality_code::int;

select
    place_of_death_region as region,
    place_of_death_province as province,
    place_of_death_mun as mun,
    count(*) as missing_count
from staging.vsr_deaths
where place_of_death_psgc_rev_1 is null
group by 1, 2, 3
order by count(*) desc
limit 20;

select vd.place_of_death_psgc_rev_1 is null as is_unmapped, count(*)
from staging.vsr_deaths vd
group by vd.place_of_death_psgc_rev_1 is null;
