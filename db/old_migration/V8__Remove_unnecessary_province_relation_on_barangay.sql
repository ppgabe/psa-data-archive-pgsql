alter table psgc_barangays
    drop column province_id;

-- We no longer need a province_id since all barangay entries now point to a valid municipality, which itself
-- points to a province.