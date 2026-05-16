create schema if not exists staging;

create table dim_psgc
(
    psgc_rev_1_code       char(10)     not null primary key,
    name                  varchar(100) not null,
    correspondence_code   char(9),
    geographic_level      varchar(10),
    old_name              varchar(100),
    city_class            varchar(10),
    income_classification varchar(10),
    urban_classification  varchar(4),
    population            text,
    status                varchar(10),

    constraint uq_psgc_data_correspondence_code unique (correspondence_code)
);

copy dim_psgc from '/var/lib/postgresql/psgc_data/PSGC-1Q-2026-Publication-Datafile.csv' with (format csv, header);

insert into dim_psgc ( psgc_rev_1_code, name, correspondence_code, geographic_level, old_name, city_class
                     , income_classification, urban_classification, population, status)
values ('0', 'Foreign Country', '0', null, null
       , null, null, null, null, null)
on conflict (psgc_rev_1_code) do nothing;

analyze dim_psgc;

create index idx_dim_psgc_geo_level on dim_psgc (geographic_level);
create index idx_dim_psgc_income_classification on dim_psgc (income_classification);
create index idx_dim_psgc_urban_classification on dim_psgc (urban_classification);

create table staging.vsr_puf_geocodes
(
    region_code              text,
    region_description       text,
    province_code            text,
    province_description     text,
    municipality_code        text,
    municipality_description text
);

create table staging.vsr_puf_geocodes_new
(
    region_code              text,
    region_description       text,
    province_code            text,
    province_description     text,
    municipality_code        text,
    municipality_description text
);

copy staging.vsr_puf_geocodes from '/var/lib/postgresql/vsr_data/VSR-Geocodes.csv' with (format csv, header);
copy staging.vsr_puf_geocodes_new from '/var/lib/postgresql/vsr_data/VSR-Geocodes-New.csv' with (format csv, header);

-- Step 1: Generate and insert the 15 explicit rows (00 through 14)
insert into staging.vsr_puf_geocodes ( region_code, region_description, province_code, province_description
                                     , municipality_code, municipality_description)
select region_code
     , region_description
     , province_code
     , province_description
     , lpad(g.num::text, 2, '0') as municipality_code -- Converts 1 to '01', 2 to '02', etc.
     , municipality_description
from staging.vsr_puf_geocodes
         cross join generate_series(0, 14) as g(num)
where municipality_code = '00 to 14';

-- Step 2: Delete the original unmapped text row
delete
from staging.vsr_puf_geocodes
where municipality_code = '00 to 14';

update staging.vsr_puf_geocodes
set province_code     = ''
  , municipality_code = ''
where province_code = 'BLANK'
  and municipality_code = 'BLANK';

create table vsr_puf_geocodes
(
    vsr_region_code       varchar(2) not null,
    vsr_province_code     varchar(3),
    vsr_municipality_code varchar(2),
    psgc_rev_1_code       char(10),

    constraint pk_vsr_puf_geocodes primary key (vsr_region_code, vsr_province_code, vsr_municipality_code),
    constraint fk_vsr_puf_geocodes_psgc_rev_1 foreign key (psgc_rev_1_code) references dim_psgc (psgc_rev_1_code)
);
