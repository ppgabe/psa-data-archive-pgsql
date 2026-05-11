create table psgc_raw_data
(
    psgc_rev_1            char(10)     not null primary key,
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
)
