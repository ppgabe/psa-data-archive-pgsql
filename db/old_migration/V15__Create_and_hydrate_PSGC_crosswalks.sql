create table psgc_municipality_correspondence
(
    correspondence_code char(6) primary key,
    municipality_id     int not null,

    constraint fk_psgc_municipality_correspondence_mun_id foreign key (municipality_id) references psgc_municipalities (id)
);

insert into psgc_municipality_correspondence (correspondence_code, municipality_id)
select left(correspondence_code, 6), pm.id
from psgc_raw_data as prd
         join psgc_provinces pp
              on left(prd.psgc_rev_1, 2)::int = pp.region_code and substring(prd.psgc_rev_1 from 3 for 3)::int = pp.code
         join psgc_municipalities as pm
              on pp.id = pm.province_id and substring(prd.psgc_rev_1 from 6 for 2)::int = pm.code
where prd.correspondence_code is not null
  and (prd.geographic_level = 'City' or prd.geographic_level = 'Mun' or
       prd.geographic_level = 'SubMun');
