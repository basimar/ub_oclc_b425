#!/bin/bash
catmandu convert MARC --type ALEPHSEQ to CSV --collect_fields '1' --sep_char '|' --fix b425-hol-excel-export.fix < b425-bib-hol-combined.seq > b425-hol-excel-export.csv
exit 0
