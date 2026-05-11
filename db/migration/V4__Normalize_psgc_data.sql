create table psgc_regions
(
    code char(3) primary key,
    name varchar(101) unique
);

-- Inserting region data from psgc_raw_data
insert into psgc_regions (code, name)
select left(psgc.psgc_rev_1, 2), psgc.name
from psgc_raw_data psgc
where psgc.geographic_level = 'Reg';

create table psgc_provinces
(
    id          int generated always as identity primary key,
    region_code char(2),
    code        char(3),
    name        varchar(100),

    constraint fk_psgc_provinces_region_code foreign key (region_code) references psgc_regions (code),
    constraint uq_psgc_provinces_code_pair unique (region_code, code)
);

create index idx_psgc_provinces_name on psgc_provinces (name);

with province as ( select psgc.psgc_rev_1, psgc.name
                   from psgc_raw_data psgc
                   where (geographic_level = 'City' and city_class = 'HUC')
                      or geographic_level = 'Prov'
                      or name = 'City of Isabela (Not a Province)' )
insert
into psgc_provinces (region_code, code, name)
select left(p.psgc_rev_1, 2), substring(p.psgc_rev_1 from 3 for 3), p.name
from province p;

create table psgc_municipalities
(
    id          int generated always as identity primary key,
    province_id int not null,
    code        char(2),
    name        varchar(100),

    constraint fk_psgc_municipalities_province_id foreign key (province_id) references psgc_provinces (id),
    constraint uq_psgc_municipalities_province_and_code unique (province_id, code)
);

create index idx_psgc_municipalities_name on psgc_municipalities (name);

with municipalities as ( select psgc.psgc_rev_1 as psgc, psgc.name
                         from psgc_raw_data psgc
                         where (psgc.geographic_level = 'Mun' or psgc.geographic_level = 'SubMun')
                            or (psgc.geographic_level = 'City' and not psgc.city_class = 'HUC') )
   , mun_split_psgc as ( select left(psgc, 2)                as region_code
                              , substring(psgc from 3 for 3) as province_code
                              , substring(psgc from 6 for 2) as mun_code
                              , name
                         from municipalities )
insert
into psgc_municipalities (province_id, code, name)
select provinces.id, msp.mun_code, msp.name
from mun_split_psgc msp
         join psgc_provinces provinces
              on provinces.region_code = msp.region_code and provinces.code = msp.province_code;

create table psgc_barangays
(
    id              int generated always as identity primary key,
    province_id     int          not null,
    municipality_id int,
    code            char(3)      not null,
    name            varchar(100) not null,

    constraint fk_psgc_barangays_municipality_id foreign key (municipality_id) references psgc_municipalities (id),
    constraint fk_psgc_barangays_province_id foreign key (province_id) references psgc_provinces (id),
    constraint uq_psgc_barangays_code_pair unique (municipality_id, code),
    constraint uq_psgc_barangays_code_province_tuple unique (province_id, municipality_id, code)
);

with barangays as ( select psgc.psgc_rev_1 as psgc, psgc.name
                    from psgc_raw_data psgc
                    where psgc.geographic_level = 'Bgy' )
   , barangay_split_psgc as ( select left(b.psgc, 2)                as region_code
                                   , substring(b.psgc from 3 for 3) as province_code
                                   , substring(b.psgc from 6 for 2) as mun_code
                                   , right(b.psgc, 3)               as barangay_code
                                   , name
                              from barangays b )
insert
into psgc_barangays (province_id, municipality_id, code, name)
select provinces.id, municipalities.id, bsp.barangay_code, bsp.name
from barangay_split_psgc bsp
         join psgc_provinces provinces on provinces.region_code = bsp.region_code and provinces.code = bsp.province_code
         left join psgc_municipalities municipalities
                   on provinces.id = municipalities.province_id and municipalities.code = bsp.mun_code;
