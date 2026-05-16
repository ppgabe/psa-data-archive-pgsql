create table staging.map_vsr_to_psgc
(
    id                    int generated always as identity primary key,
    vsr_region_code       text,
    vsr_province_code     text,
    vsr_municipality_code text,
    vsr_region_name       text,
    vsr_province_name     text,
    vsr_municipality_name text,
    vsr_concat_name       text,
    psgc_rev_1_code       char(10),
    match_type            varchar(20),
    confidence_score      numeric(5, 2)
);

insert into staging.map_vsr_to_psgc ( vsr_region_code, vsr_province_code, vsr_municipality_code, vsr_region_name
                                    , vsr_province_name, vsr_municipality_name, vsr_concat_name)
select distinct lpad(region_code, 2, '0')
              , lpad(province_code, 3, '0')
              , lpad(municipality_code, 2, '0')
              , vsg.region_description
              , vsg.province_description
              , vsg.municipality_description
              , upper(trim(region_description) || ' | ' || coalesce(trim(province_description), '') || ' | ' ||
                      coalesce(trim(municipality_description), ''))
from staging.vsr_puf_geocodes as vsg
on conflict do nothing;

update staging.map_vsr_to_psgc v
set psgc_rev_1_code  = p.psgc_rev_1_code
  , match_type       = 'Code-Mun'
  , confidence_score = 100.00
from dim_psgc p
where v.psgc_rev_1_code is null
  and v.vsr_municipality_code is not null
  and p.correspondence_code is not null
  -- Cast both sides to int to bypass the leading zeros
  and v.vsr_province_code::int = substring(p.correspondence_code, 3, 2)::int
  and v.vsr_municipality_code::int = substring(p.correspondence_code, 5, 2)::int
  and p.geographic_level in ('Mun', 'City', 'SubMun');

update staging.map_vsr_to_psgc v
set psgc_rev_1_code  = p.psgc_rev_1_code
  , match_type       = 'Code-Prov'
  , confidence_score = 100.00
from dim_psgc p
where v.psgc_rev_1_code is null
  and v.vsr_municipality_code is null
  and v.vsr_province_code is not null
  and p.correspondence_code is not null
  -- Cast both sides to int to bypass the leading zeros
  and v.vsr_province_code::int = substring(p.correspondence_code, 3, 2)::int
  and p.geographic_level = 'Prov';

update staging.map_vsr_to_psgc
set psgc_rev_1_code = (select psgc_rev_1_code from dim_psgc where name ilike '%Iloilo City%' limit 1)
  , match_type = 'Manual-HUC'
  , confidence_score = 100.00
where vsr_province_code = '302'
  and (vsr_municipality_code = '00' or vsr_municipality_code is null);

-- Fallback for NIR and Missing Correspondence Codes
update staging.map_vsr_to_psgc v
set psgc_rev_1_code = p_mun.psgc_rev_1_code,
    match_type = 'Name-Fallback',
    confidence_score = 90.00
from dim_psgc p_mun
         join dim_psgc p_prov
              on substring(p_mun.psgc_rev_1_code, 1, 5) || '00000' = p_prov.psgc_rev_1_code
                  and p_prov.geographic_level = 'Prov'
where v.psgc_rev_1_code is null
  and v.vsr_municipality_name is not null
  -- Match by Name instead of Code
  and upper(trim(v.vsr_municipality_name)) = upper(trim(p_mun.name))
  and upper(trim(v.vsr_province_name)) = upper(trim(p_prov.name))
  and p_mun.geographic_level in ('Mun', 'City', 'SubMun');

insert into vsr_puf_geocodes (vsr_region_code, vsr_province_code, vsr_municipality_code, psgc_rev_1_code)
select trim(mvtp.vsr_region_code)
     , trim(mvtp.vsr_province_code)
     , coalesce(trim(mvtp.vsr_municipality_code), '00')
     , mvtp.psgc_rev_1_code
from staging.map_vsr_to_psgc as mvtp;

create index idx_vsr_puf_geocodes on vsr_puf_geocodes (vsr_region_code, vsr_province_code, vsr_municipality_code);
