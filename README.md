# PSA Data Archive (in PostgreSQL)

This repository contains SQL migration scripts to quickly spin up a highly structured database for data provided by the
Philippine Statistics Authority and its Data Archive (PSADA). It is meant to be used with datafiles from official PSA
publications and the PSADA website.

As of May 15, 2026, it encompasses the following:

1. Philippine Standard Geographic Code (PSGC)
2. Vital Statistics Reports (VSRs) on Deaths in the Philippines (2004-2024)
3. Vital Statistics Report on Births in the Philippines (2024)

## Disclaimer

This repository comes with the Q1 2026 PSGC datafile, obtained from
[https://psa.gov.ph/classification/psgc](https://psa.gov.ph/classification/psgc).

However, this repository **does not distribute** datafiles obtained from the PSADA website (including VSRs) in
accordance with its Terms and Conditions. As such, you are expected to get your own copies from the official
[PSADA Website](https://psada.psa.gov.ph/). The author of this repository will not entertain any request for datafiles.

You are expected to follow the setup guide which will lay out basic steps to prepare the datafiles for use with this
repository.

## Prerequisites

1. Docker

If you don't have Docker yet, consult the following webpage:
[Get Docker](https://docs.docker.com/get-started/get-docker/).

## Setting Up

### 1. Acquiring the VSR Datafiles

Make sure you have registered and logged in to the PSADA website. Head to the
[Vital Statistics catalog](https://psada.psa.gov.ph/catalog/VSR/about).

![Vital Statistics catalog page at the PSADA website](/readme/vital-statistics-catalog.png)

**Download the following microdata:**

1. VSRs on Death, 2004-2024
2. VSR on Birth, 2024

### 2. Extract the VSR Datafiles

Using your preferred archive management tool (e.g. [7-zip](https://www.7-zip.org), [WinRAR](https://www.win-rar.com)),
extract the datafiles from the .zip archives.

### 3. Convert the XLSX Datafiles into CSVs

This guide will use Microsoft Excel to demonstrate this process, but you may use any tool as long as it produces
a well-formatted, UTF-8 CSVs with headers.

Open the datafile in Microsoft Excel (or a similar program) and go to `File > Save As`. Save the file as a
**CSV (UTF-8)** with the following filename format:

1. For VSR on Deaths: `VSR-PUF-[YYYY]-Death`
2. For VSR on Births: 'VSR-Births-[YYYY]-[Male/Female]'

Keep in mind that for Excel workbooks with multiple sheets, such as the one found in VSRs on Births, you must
save once for each sheet. This is why VSR on Births has a `[Male/Female]` suffix, as you must have two separate
CSVs for this VSR.

![Excel Save As screen](/readme/excel-save-as.png)

### 4. Convert the Metadata/Dictionary XLSX into CSVs

Repeat the same process from the previous step, but this time, for the following files and their listed sheets:

1. `vsr_2024_death_metadata(dictionary).xlsx`: ICD_codes3, tabulation list
2. `vsr_2023_death_metadata(dictionary).xlsx`: citizenship

Their filenames must be:

1. **ICD_codes3**: `VSR-ICD10.csv`
2. **tabulation list**: `VSR-Tablist.csv`
3. **citizenship**: `VSR-Citizenship.csv`

### 5. Move all the CSVs into `/db/vsr_data`

Move all the CSVs you have saved into `PROJECT_DIR/db/vsr_data/`. It should look like this:

![vsr_data folder after all CSVs have been moved](/readme/vsr-data-folder.png)

### 6. Create a Database `password` File

Inside `db/`, create a file named `password` (without any file extensions) and open it with your preferred
text editor. Inside the file, create a secure password. This will be the password you use to connect to your
database initially!

You may check and modify your database username inside the `docker-compose.yml` file. Be sure to edit this before
proceeding to the next step!

### 7. Start the Database

On your terminal, `cd` into the project root directory and run the command `docker compose up`. If you follow
everything closely, the migrations will be completed successfully, and you will have a working database!

You can connect to this local database through `localhost:5432` using the username and password you provided.

This README will not cover how to connect the database to your preferred programming environment.
