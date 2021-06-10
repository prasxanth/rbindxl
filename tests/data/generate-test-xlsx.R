library(openxlsx)
library(readr)
library(purrr)
library(janitor)
library(dplyr)

data <- read_csv("tests/iris.csv") %>%
  clean_names()

# Divide data into 6 sheets
splits <- paste(seq(1, nrow(data), nrow(data) / 6),
              c(seq(nrow(data) / 6 + 1, nrow(data), nrow(data) / 6), nrow(data)),
              sep =":") 

data_list <- splits %>%
  map(~ data %>% slice(eval(parse(text = .x))))

# Sheet names
data_names <- data_list %>% 
  map(~ .x %>% select(species) %>% 
        unique() %>% unlist(use.names = FALSE) %>% paste(collapse="-")) %>% 
  unlist()

# Rename duplicate fields
# https://stackoverflow.com/questions/16646446/renaming-duplicate-strings-in-r
ids <- data_names %>%  rle()

sheet_names <- paste0(rep(ids$values, times = ids$lengths), "_", 
                      unlist(lapply(ids$lengths, seq_len)))
  
names(data_list) <- sheet_names

write.xlsx(data_list, file = "tests/test-data.xlsx")



