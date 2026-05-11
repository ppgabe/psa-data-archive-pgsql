copy psgc_raw_data from '/var/lib/postgresql/psgc_data/PSGC-1Q-2026-Publication-Datafile.csv' delimiter ',' csv header;

alter table psgc_raw_data
    alter column population type int using nullif(regexp_replace(population, '[^0-9]', '', 'g'), '')::int;
