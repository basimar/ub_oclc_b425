#!/bin/bash
catmandu convert MARC --type ALEPHSEQ to CSV --collect_fields '1' --sep_char '|' --fix b425-zs-excel-export.fix < b425-zs.seq > b425-zs-excel-export.csv
exit 0
