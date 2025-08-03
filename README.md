# comexstat

## Overview

comexstat creates an Apache Arrow database in a user-specified directory using 
export and import data from Comex Stat, Brazil’s official foreign trade data 
portal.
The package also includes functionality to update the database as new data becomes
available.

The database is organized into two subfolders — one for exports and another for
imports — within the specified directory. The database contains the following
columns:

- year
- month
- ncm
- state (Brazilian state abbreviation)
- country code
- fob value (in dollars)
- cif value (only for imports and in dollars)
- kg (net weight in kilograms)
- qt (quantity)

## Installation

To install the development version:

```
# install.packages("pak")
pak::pak("mgcleaver/comexstat")
```


## Usage

```
library(comexstat)
library(arrow)
library(dplyr)

# create Comex Stat database
create_cs_db(dest_dir = "database", initial_year = 2024)

# update Comex Stat database
update_cs_db(dest_dir = "database")

# get total exports by year
open_dataset("database") %>% 
  group_by(year) %>% 
  summarise(value = sum(fob_value)) %>% 
  ungroup() %>% 
  collect()
```
