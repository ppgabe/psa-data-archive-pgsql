lock table psgc_provinces in access exclusive mode;
lock table psgc_municipalities in access exclusive mode;
lock table psgc_barangays in access exclusive mode;

create sequence seq_psgc_provinces_id increment by 1;
create sequence seq_psgc_municipalities_id increment by 1;
create sequence seq_psgc_barangays_id increment by 1;

select setval('seq_psgc_provinces_id', ( select max(id) from psgc_provinces ));
select setval('seq_psgc_municipalities_id', ( select max(id) from psgc_municipalities ));
select setval('seq_psgc_barangays_id', ( select max(id) from psgc_barangays ));

alter table psgc_provinces
    alter column id drop identity;
alter table psgc_municipalities
    alter column id drop identity;
alter table psgc_barangays
    alter column id drop identity;

alter table psgc_provinces
    alter column id set default nextval('seq_psgc_provinces_id');
alter table psgc_municipalities
    alter column id set default nextval('seq_psgc_municipalities_id');
alter table psgc_barangays
    alter column id set default nextval('seq_psgc_barangays_id');

alter sequence seq_psgc_provinces_id owned by psgc_provinces.id;
alter sequence seq_psgc_municipalities_id owned by psgc_municipalities.id;
alter sequence seq_psgc_barangays_id owned by psgc_barangays.id;