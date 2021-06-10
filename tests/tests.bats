#!/usr/bin/env bats

timestamp=$(date "+%Y%m%d-%H%M%S")

# rscript=/usr/local/bin/Rscript

setup () {
  mkdir -p $timestamp
}

teardown () {
  rm -rf $timestamp
}

@test "Test Case 1: List all sheets in Excel file" {
  run bash -c "Rscript .././rbindxl.R data/test-data.xlsx --list-sheets > $timestamp/test-case-1.txt"
  cmp -s $timestamp/test-case-1.txt expected/test-case-1.txt
}

@test "Test Case 2: Merge tables from all sheets" {
  run bash -c "Rscript .././rbindxl.R data/test-data.xlsx > $timestamp/test-case-2.txt"
  cmp -s $timestamp/test-case-2.txt expected/test-case-2.txt
}

@test "Test Case 3: Merge only tables from sheets starting with 'ver'" {
  run bash -c "Rscript .././rbindxl.R --sheet-names=^ver.* data/test-data.xlsx > $timestamp/test-case-3.txt"
  cmp -s $timestamp/test-case-3.txt expected/test-case-3.txt
}

@test "Test Case 4: Merge only tables from sheets 1-3 and 6" {
  run bash -c "Rscript .././rbindxl.R --sheet-numbers=1-3,6 data/test-data.xlsx > $timestamp/test-case-4.txt"
  cmp -s $timestamp/test-case-4.txt expected/test-case-4.txt
}

@test "Test Case 5: Merge tables from last sheet with sheets starting with setosa" {
  run bash -c "Rscript .././rbindxl.R --sheet-names=^setosa.* --sheet-numbers=6 data/test-data.xlsx > $timestamp/test-case-5.txt"
  cmp -s $timestamp/test-case-5.txt expected/test-case-5.txt
}

@test "Test Case 6: Merge tables in sheets 2 and 5, starting from second row and ignoring header" {
  run bash -c "Rscript .././rbindxl.R --sheet-numbers=2,5 --skip-rows=1 --no-header data/test-data.xlsx > $timestamp/test-case-6.txt"
  cmp -s $timestamp/test-case-6.txt expected/test-case-6.txt
}

@test "Test Case 7: Merge tables in sheets 4-6 and save output to csv file" {
  run bash -c "Rscript .././rbindxl.R --sheet-numbers=4-6 data/test-data.xlsx --output-csv $timestamp/test-case-7.csv"
  cmp -s $timestamp/test-case-7.csv expected/test-case-7.csv
}