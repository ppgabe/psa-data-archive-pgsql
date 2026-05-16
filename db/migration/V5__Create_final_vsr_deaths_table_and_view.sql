create table vsr_deaths
(
    id                          int generated always as identity primary key,
    date_of_death_month         int,
    date_of_death_day           int,
    date_of_death_year          int,
    place_of_death_region       varchar(2),
    place_of_death_province     varchar(3),
    place_of_death_mun          varchar(2),
    place_of_death_region_new   varchar(2),
    place_of_death_province_new varchar(3),
    place_of_death_mun_new      varchar(2),
    place_of_death_psgc_rev_1   char(10),
    sex                         int,
    age                         int,
    age_years                   int,
    infant_age_days             int,
    residence_region            varchar(2),
    residence_province          varchar(3),
    residence_mun               varchar(2),
    residence_region_new        varchar(2),
    residence_province_new      varchar(3),
    residence_mun_new           varchar(2),
    residence_psgc_rev_1        char(10),
    civil_status                int,
    citizenship                 int,
    place_type                  int,
    attendant                   int,
    registration_status         int,
    icd10_code                  varchar(8),
    tablist                     varchar(16)
);

insert into vsr_deaths ( date_of_death_month, date_of_death_day, date_of_death_year, place_of_death_region
                       , place_of_death_province, place_of_death_mun, place_of_death_region_new
                       , place_of_death_province_new, place_of_death_mun_new, place_of_death_psgc_rev_1, sex, age
                       , age_years, infant_age_days, residence_region, residence_province, residence_mun
                       , residence_region_new, residence_province_new, residence_mun_new, residence_psgc_rev_1
                       , civil_status, citizenship, place_type, attendant, registration_status, icd10_code, tablist)
select *
from staging.vsr_deaths;

alter table vsr_deaths
    add constraint fk_vsr_deaths_place_of_death_psgc foreign key (place_of_death_psgc_rev_1) references dim_psgc (psgc_rev_1_code),
    add constraint fk_vsr_deaths_residence_psgc foreign key (residence_psgc_rev_1) references dim_psgc (psgc_rev_1_code),
    add constraint fk_vsr_deaths_sex foreign key (sex) references vsr_sex (code),
    add constraint fk_vsr_deaths_civil_status foreign key (civil_status) references vsr_civil_statuses (code),
    add constraint fk_vsr_deaths_citizenship foreign key (citizenship) references vsr_citizenships (code),
    add constraint fk_vsr_deaths_place_type foreign key (place_type) references vsr_place_types (code),
    add constraint fk_vsr_deaths_attendant foreign key (attendant) references vsr_attendants (code),
    add constraint fk_vsr_deaths_registration_status foreign key (registration_status) references vsr_registration_statuses (code),
    add constraint fk_vsr_deaths_icd_code foreign key (icd10_code) references vsr_icd10_codes (code),
    add constraint fk_vsr_deaths_tablist foreign key (tablist) references vsr_tablist (code);

create index idx_vsr_deaths_pod_psgc on vsr_deaths (place_of_death_psgc_rev_1);
create index idx_vsr_deaths_sex on vsr_deaths (sex);
create index idx_vsr_deaths_icd10_code on vsr_deaths (icd10_code);
create index idx_vsr_deaths_tablist on vsr_deaths (tablist);
create index idx_vsr_deaths_date on vsr_deaths (date_of_death_year, date_of_death_month, date_of_death_day);
create index idx_vsr_deaths_place_type on vsr_deaths (place_type);
create index idx_vsr_deaths_registration_status on vsr_deaths (registration_status);
create index idx_vsr_deaths_attendant on vsr_deaths (attendant);

create or replace view vw_vsr_deaths_joined as
select
     -- temporal
    vd.date_of_death_year         as death_year
     , vd.date_of_death_month     as death_month
     , vd.date_of_death_day       as death_day

     -- demographic
     , vd.age_years               as age_years
     , vd.infant_age_days         as infant_age_days
     , vs.description             as sex
     , vcs.description            as civil_status
     , vc.description             as citizenship

     -- circumstances
     , vpt.description            as place_type
     , va.description             as attendant
     , vrs.description            as registration_status
     , vi10c.code                 as icd10_code
     , vi10c.description          as icd10_description
     , vt.code                    as ucod_code
     , vt.description             as ucod_description

     -- place of death
     , dpod.psgc_rev_1_code       as pod_psgc
     , dpod.name                  as pod_name
     , dpod.geographic_level      as pod_level
     , dpod.urban_classification  as pod_urban_class
     , dpod.income_classification as pod_income_class
     , dpod.population            as pod_population_2024

     -- place of residence
     , dpr.psgc_rev_1_code        as res_psgc
     , dpr.name                   as res_name
     , dpr.geographic_level       as res_level
     , dpr.urban_classification   as res_urban_class
     , dpr.income_classification  as res_income_class
from vsr_deaths vd
         left join dim_psgc dpod on vd.place_of_death_psgc_rev_1 = dpod.psgc_rev_1_code
         left join dim_psgc dpr on vd.residence_psgc_rev_1 = dpr.psgc_rev_1_code
         left join vsr_sex vs on vd.sex = vs.code
         left join vsr_civil_statuses vcs on vd.civil_status = vcs.code
         left join vsr_citizenships vc on vd.citizenship = vc.code
         left join vsr_place_types vpt on vd.place_type = vpt.code
         left join vsr_attendants va on vd.attendant = va.code
         left join vsr_registration_statuses vrs on vd.registration_status = vrs.code
         left join vsr_icd10_codes vi10c on vd.icd10_code = vi10c.code
         left join vsr_tablist vt on vd.tablist = vt.code
