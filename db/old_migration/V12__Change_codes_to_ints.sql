alter table psgc_barangays
    alter column code type int using trim(code)::int;

alter table psgc_municipalities
    alter column code type int using trim(code)::int;

alter table psgc_provinces
    drop constraint fk_psgc_provinces_region_code;

alter table psgc_provinces
    alter column region_code type int using trim(region_code)::int;

alter table psgc_provinces
    alter column code type int using trim(code)::int;

alter table psgc_regions
    alter column code type int using trim(code)::int;

alter table psgc_provinces
    add constraint fk_psgc_provinces_region_code foreign key (region_code) references psgc_regions (code);
