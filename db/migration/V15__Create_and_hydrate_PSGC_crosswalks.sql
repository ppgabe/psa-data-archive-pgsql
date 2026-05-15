create table psgc_region_correspondence (
    correspondence_code char(9) primary key,
    region_code int not null,

    constraint fk_psgc_region_correspondence_region_id foreign key (region_code) references psgc_regions(code)
);

create table psgc_province_correspondence (
    correspondence_code char(9) primary key,
    province_id int not null,

    constraint fk_psgc_province_correspondence_province_id foreign key (province_id) references psgc_provinces(id)
);

create table psgc_municipality_correspondence (
    correspondence_code char(9) primary key,
    municipality_id int not null,

    constraint fk_psgc_municipality_correspondence_mun_id foreign key (municipality_id) references psgc_municipalities(id)
);

create table psgc_barangay_correspondence (
    correspondence_code char(9) primary key,
    barangay_id int not null,

    constraint fk_psgc_barangay_correspondence_barangay_id foreign key (barangay_id) references psgc_barangays(id)
);
