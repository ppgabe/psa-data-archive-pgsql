with split_psgc_code as ( select left(psgc_rev_1, 2)                as region_code
                               , substring(psgc_rev_1 from 3 for 3) as province_code
                               , substring(psgc_rev_1 from 6 for 2) as mun_code
                               , right(psgc_rev_1, 3)               as bgy_code
                          from psgc_raw_data -- Only select Bgys with NO municipality
                          where geographic_level = 'Bgy'
                            and psgc_rev_1 like '_____00___' )
   , target_barangays as ( select b.id, b.code, b.province_id from psgc_barangays b where municipality_id is null )
   , tb_spc_junction as ( select pm.id as mun_id, tb.id bgy_id
                          from split_psgc_code spc
                                   join psgc_provinces p
                                        on p.code = spc.province_code and p.region_code = spc.region_code
                                   join target_barangays tb on p.id = tb.province_id and tb.code = spc.bgy_code
                                   join psgc_municipalities pm
                                        on pm.code = spc.mun_code and pm.province_id = tb.province_id )
update psgc_barangays pb
set municipality_id = tsj.mun_id
from tb_spc_junction tsj
where pb.id = tsj.bgy_id;
