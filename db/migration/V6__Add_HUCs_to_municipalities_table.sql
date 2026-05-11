with hucs as ( select psgc.psgc_rev_1 psgc, psgc.name from psgc_raw_data psgc where city_class = 'HUC' )
   , hucs_split_psgc as ( select left(hucs.psgc, 2)                as region_code
                               , substring(hucs.psgc from 3 for 3) as province_code
                               , substring(hucs.psgc from 6 for 2) as mun_code
                               , name
                          from hucs )
insert
into psgc_municipalities (province_id, code, name)
select provinces.id, hsp.mun_code, hsp.name
from hucs_split_psgc hsp
         join psgc_provinces provinces
              on provinces.region_code = hsp.region_code and provinces.code = hsp.province_code;
