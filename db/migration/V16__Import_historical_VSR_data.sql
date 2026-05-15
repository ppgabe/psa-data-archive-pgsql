-- sneaky patch because there's a sneaky record with these codes... somewhere in the 2006-2023 data.
-- these were not included in the metadata/dictionary
insert into vsr_icd10_codes (code, description)
values ('U07', 'Emergency use of U07 (COVID-19 and Vaping-related disorders)'),
       ('U10', 'Multisystem inflammatory syndrome associated with COVID-19'),
       ('U049', 'Severe acute respiratory syndrome [SARS], unspecified'),
       ('I84', 'Haemorrhoids')
on conflict (code) do nothing;

drop index idx_vsr_deaths_date_of_death;
drop index idx_vsr_deaths_sex;
drop index idx_vsr_deaths_icd10_code;

alter table vsr_deaths
    drop constraint fk_vsr_deaths_municipality_of_death_id,
    drop constraint fk_vsr_deaths_residence_municipality_id,
    drop constraint fk_vsr_deaths_civil_status,
    drop constraint fk_vsr_deaths_citizenship,
    drop constraint fk_vsr_deaths_place_type,
    drop constraint fk_vsr_deaths_attendant,
    drop constraint fk_vsr_deaths_registration_status,
    drop constraint fk_vsr_deaths_icd10_code,
    drop constraint fk_vsr_deaths_tablist,
    drop constraint fk_vsr_deaths_sex;

create temp table temp_vsr_death_2023_ingest
(
    month_of_death              int,
    day_of_death                int,
    year_of_death               int,
    place_of_death_region       int,
    place_of_death_province     int,
    place_of_death_mun          int,
    place_of_death_region_new   int,
    place_of_death_province_new int,
    place_of_death_mun_new      int,
    sex                         int,
    age                         int,
    residence_region            int,
    residence_province          int,
    residence_mun               int,
    residence_region_new        int,
    residence_province_new      int,
    residence_mun_new           int,
    civil_status                int,
    citizenship                 int,
    place_type                  int,
    attendant                   int,
    registration_status         int,
    icd_code_3d                 varchar(8),
    tablist                     varchar(16)
);

copy temp_vsr_death_2023_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2023-Death.csv' with (format csv, header);

analyze temp_vsr_death_2023_ingest;
create index idx_temp_vsr_death_2023_ingest_place on temp_vsr_death_2023_ingest (place_of_death_region_new,
                                                                                 place_of_death_province_new,
                                                                                 place_of_death_mun_new);
create index idx_temp_vsr_death_2023_ingest_residence on temp_vsr_death_2023_ingest (residence_region_new, residence_province_new, residence_mun_new);

with psgc_table as ( select pr.code reg_code, pp.code as prov_code, pm.code as mun_code, pm.id as mun_id
                     from psgc_municipalities pm
                              join psgc_provinces pp on pm.province_id = pp.id
                              join psgc_regions pr on pp.region_code = pr.code )
insert
into vsr_deaths ( month_of_death, day_of_death, year_of_death, municipality_of_death_id, sex, age, age_years
                , infant_age_days, residence_municipality_id, civil_status, citizenship, place_type, attendant
                , registration_status
                , icd10_code, tablist)
select month_of_death
     , day_of_death
     , year_of_death
     , pod.mun_id
     , sex
     , age
     , case when tvd2023i.age between 201 and 299 then tvd2023i.age - 200
            when tvd2023i.age >= 300 and tvd2023i.age < 999 then tvd2023i.age - 300
            when tvd2023i.age between 0 and 111 then 0 end
     , case when tvd2023i.age between 0 and 28 then tvd2023i.age
            when tvd2023i.age between 101 and 111 then (tvd2023i.age - 100) * 30 end
     , res.mun_id
     , civil_status
     , citizenship
     , place_type
     , attendant
     , registration_status
     , icd_code_3d
     , tablist
from temp_vsr_death_2023_ingest as tvd2023i
         left join psgc_table pod
              on tvd2023i.place_of_death_region_new = pod.reg_code and tvd2023i.place_of_death_province_new = pod.prov_code and
                 tvd2023i.place_of_death_mun_new = pod.mun_code
         left join psgc_table res
              on tvd2023i.residence_region_new = res.reg_code and tvd2023i.residence_province_new = res.prov_code and
                 tvd2023i.residence_mun_new = res.mun_code;

create temp table temp_vsr_death_ingest
(
    month_of_death          int,
    day_of_death            int,
    year_of_death           int,
    place_of_death_region   int,
    place_of_death_province int,
    place_of_death_mun      int,
    sex                     int,
    age                     int,
    residence_region        int,
    residence_province      int,
    residence_mun           int,
    icd_code_3d             varchar(8),
    attendant               int,
    place_type              int,
    registration_status     int
);

copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2022-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2021-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2020-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2019-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2018-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2017-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2016-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2015-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2014-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest from '/var/lib/postgresql/vsr_data/VSR-PUF-2013-Death.csv' with (format csv, header);

analyze temp_vsr_death_ingest;
create index idx_temp_vsr_death_ingest_place on temp_vsr_death_ingest (place_of_death_region, place_of_death_province, place_of_death_mun);
create index idx_temp_vsr_death_ingest_residence on temp_vsr_death_ingest (residence_region, residence_province, residence_mun);

insert into vsr_deaths ( month_of_death, day_of_death, year_of_death, municipality_of_death_id, sex, age, age_years
                       , infant_age_days
                       , residence_municipality_id, place_type, attendant
                       , registration_status, icd10_code)
select month_of_death
     , day_of_death
     , year_of_death
     , pmcd.municipality_id
     , sex
     , age
     , case when tvdi.age >= 201 and tvdi.age < 999 then tvdi.age - 200 when tvdi.age between 0 and 111 then 0 end
     , case when tvdi.age between 0 and 28 then tvdi.age
            when tvdi.age between 101 and 111 then (tvdi.age - 100) * 30 end
     , pmcr.municipality_id
     , place_type
     , attendant
     , registration_status
     , icd_code_3d
from temp_vsr_death_ingest as tvdi
         left join psgc_municipality_correspondence pmcd
              on lpad(tvdi.place_of_death_region::text, 2, '0') || lpad(tvdi.place_of_death_province::text, 2, '0') ||
                 lpad(tvdi.place_of_death_mun::text, 2, '0') = pmcd.correspondence_code
         left join psgc_municipality_correspondence as pmcr
              on lpad(tvdi.residence_region::text, 2, '0') || lpad(tvdi.residence_province::text, 2, '0') ||
                 lpad(tvdi.residence_mun::text, 2, '0') = pmcr.correspondence_code;

create temp table temp_vsr_death_ingest_pre2013
(
    month_of_death          int,
    day_of_death            int,
    year_of_death           int,
    place_of_death_region   int,
    place_of_death_province int,
    place_of_death_mun      int,
    sex                     int,
    age                     int,
    residence_region        int,
    residence_province      int,
    residence_mun           int,
    icd_code_3d             varchar(8),
    attendant               int,
    registration_status     int
);

copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2012-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2011-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2010-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2009-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2008-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2007-Death.csv' with (format csv, header);
copy temp_vsr_death_ingest_pre2013 from '/var/lib/postgresql/vsr_data/VSR-PUF-2006-Death.csv' with (format csv, header);

analyze temp_vsr_death_ingest_pre2013;
create index idx_temp_vsr_death_ingest_pre2013_place on temp_vsr_death_ingest_pre2013 (place_of_death_region, place_of_death_province, place_of_death_mun);
create index idx_temp_vsr_death_ingest_pre2013_residence on temp_vsr_death_ingest_pre2013 (residence_region, residence_province, residence_mun);

insert into vsr_deaths ( month_of_death, day_of_death, year_of_death, municipality_of_death_id, sex, age, age_years
                       , infant_age_days
                       , residence_municipality_id, attendant
                       , registration_status, icd10_code)
select month_of_death
     , day_of_death
     , year_of_death
     , pmcd.municipality_id
     , sex
     , age
     , case when tvdip2013.age >= 201 and tvdip2013.age < 999 then tvdip2013.age - 200 when tvdip2013.age between 0 and 111 then 0 end
     , case when tvdip2013.age between 0 and 28 then tvdip2013.age
            when tvdip2013.age between 101 and 111 then (tvdip2013.age - 100) * 30 end
     , pmcr.municipality_id
     , attendant
     , registration_status
     , icd_code_3d
from temp_vsr_death_ingest_pre2013 as tvdip2013
         left join psgc_municipality_correspondence pmcd
              on lpad(tvdip2013.place_of_death_region::text, 2, '0') || lpad(tvdip2013.place_of_death_province::text, 2, '0') ||
                 lpad(tvdip2013.place_of_death_mun::text, 2, '0') = pmcd.correspondence_code
         left join psgc_municipality_correspondence as pmcr
              on lpad(tvdip2013.residence_region::text, 2, '0') || lpad(tvdip2013.residence_province::text, 2, '0') ||
                 lpad(tvdip2013.residence_mun::text, 2, '0') = pmcr.correspondence_code;

alter table vsr_deaths
    add constraint fk_vsr_deaths_municipality_of_death_id foreign key (municipality_of_death_id) references psgc_municipalities (id),
    add constraint fk_vsr_deaths_residence_municipality_id foreign key (residence_municipality_id) references psgc_municipalities (id),
    add constraint fk_vsr_deaths_civil_status foreign key (civil_status) references vsr_civil_statuses (code),
    add constraint fk_vsr_deaths_citizenship foreign key (citizenship) references vsr_citizenships (code),
    add constraint fk_vsr_deaths_place_type foreign key (place_type) references vsr_place_types (code),
    add constraint fk_vsr_deaths_attendant foreign key (attendant) references vsr_attendants (code),
    add constraint fk_vsr_deaths_registration_status foreign key (registration_status) references vsr_registration_statuses (code),
    add constraint fk_vsr_deaths_icd10_code foreign key (icd10_code) references vsr_icd10_codes (code),
    add constraint fk_vsr_deaths_tablist foreign key (tablist) references vsr_tablist (code),
    add constraint fk_vsr_deaths_sex foreign key (sex) references vsr_sex (code);

create index idx_vsr_deaths_date_of_death on vsr_deaths (year_of_death, month_of_death, day_of_death);
create index idx_vsr_deaths_sex on vsr_deaths (sex);
create index idx_vsr_deaths_icd10_code on vsr_deaths (icd10_code);
