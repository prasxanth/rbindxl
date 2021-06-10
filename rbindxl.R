#!/usr/bin/env r

# Load packages
packages <- c("dplyr",    # mutate
              "purrr",    # map_dfr
              "readxl",   # read_excel
              "janitor",  # remove_empty, clean_names
              "readr",    # type_convert, format_csv
              "docopt")   # docopt

success  <- suppressMessages(sapply(
  packages,
  library,
  logical.return = TRUE,
  character.only = TRUE
))

# Install missing packages
if (!any(success)) {
  install.packages(names(success)[!success],
                   repos = "http://cran.us.r-project.org")
}

sapply(names(success)[!success], require, character.only = TRUE) %>%
    invisible() # Suppress `sapply` output `named list()`

options(readr.num_columns = 0)
                                        # Range expansion definition
                                        # Reference: https://rosettacode.org/wiki/Range_expansion#R
range_expand <- function(text) {
    lst <- strsplit(text, ",") %>%
        unlist() %>%
        gsub("(\\d)-", "\\1:", .)

    sapply(lst, function (x)
        eval(parse(text = x))) %>%
        unlist(use.names = FALSE)
}

## docopt Configurations
doc <-
  'Script to combine tables across sheets by rows in an Excel file.

Usage:
  rbindxl.R <file>
  rbindxl.R <file> [--sheet-names=<regex>]
  rbindxl.R <file> [--sheet-numbers=<ranges>]
  rbindxl.R <file> [--sheet-names=<regex>] [--sheet-numbers=<ranges>] [--skip-rows=<rows>] [--no-header] [--output-csv=FILE]
  rbindxl.R <file> --list-sheets
  rbindxl.R (-h | --help)
  rbindxl.R --version

Options:
  -h --help                       Show this screen.
  -v --version                    Show version.
  -l --list-sheets                List sheets in the Excel file.
  -r --sheet-names=<regex>        Regex identify sheet names to bind.
  -p --sheet-numbers=<ranges>     Sheet numbers to bind.
  -s --skip-rows=<rows>           Number of rows to skip from each sheet [default: 0].
  -n --no-header                  Flag to indicate if tables do not have header row.
  -o FILE --output-csv=FILE       CSV filename to save table.


Example:
 ./rbindxl.R sample.xlsx --list-sheets
 ./rbindxl.R sample.xlsx --sheet-names=^ver.* --sheet-numbers=1-2,4,6-8 --skip-rows=1 --no-header output-csv=test-ver.csv

Notes:
 * This script requires identical table columns and placement across all sheets.
 * If no regex or positions are specified then all sheets are used by default.
 * The `--sheet-numbers` argument can take a comma seperated list of integers or a range of integers denoted by the starting integer separated from the end integer in the range by a dash, `-`.
 * A `sheetname` column is added to the combined table.
 * Empty rows and columns are removed from the final combined.

Requirements:
 * R >= 3.4.4
 * Missing packages will be installed, so running this script the first time may take longer.
'

args <- docopt(doc, version = '\nrbindxl - Version 1.0\n')

all_sheets <- excel_sheets(args$file)

if(args$list_sheets) {
    all_sheets %>%
        map(~as_tibble(.)) %>%
        bind_rows(.id="sheet_number") %>%
        rename(sheet_name = value) %>%
        as.data.frame() %>%
        print(row.names = FALSE)
    quit(save = "no")
}

if (is_null(args$sheet_names)) {
    sheet_names <- vector(mode = "list", length = 0)
} else {
    sheet_names <- grep(args$sheet_names, all_sheets, value = TRUE)
}

if (is_null(args$sheet_numbers)) {
    sheet_numbers <- vector(mode = "list", length = 0)
} else {
    sheet_numbers <- all_sheets[range_expand(args$sheet_numbers)]
}

sheets <- union(sheet_names, sheet_numbers) %>% unlist()

if (is_empty(sheets)) {
  sheets <- all_sheets
}

df <- sheets %>%
    map_dfr(
        ~ read_excel(args$file, sheet = .x,
                     skip = as.integer(args$skip_rows),
                     col_names = (!args$no_header)) %>%
            mutate(across(everything(), as.character)) %>%
            mutate(sheet_name = .x)
    )

mdf <- df %>%
    remove_empty(which = c("rows", "cols")) %>%
    clean_names() %>%
    type_convert()

if (!is.character(args$output_csv)) {
  cat(format_csv(mdf))
} else {
  write_csv(mdf, args$output_csv, append = FALSE)
}
