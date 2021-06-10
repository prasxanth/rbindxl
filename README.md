Script to combine tables across sheets by rows in an Excel file.

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
