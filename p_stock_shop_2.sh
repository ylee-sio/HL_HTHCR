#!/bin/bash

# running this script requires a list of accessions placed in ~/probe_shop/resources first. use get_accessions.sh

species_search=$1
num_threads=$2
num_probe_pairs=$3
max_homopolymer=$4

psr=~/probe_shop/resources

species_name=$(cat $psr/species_info.csv | grep $species_search | cut -d , -f 1)
species_initial=$(cat $psr/species_info.csv | grep $species_search | cut -d , -f 2)
accession=$(cat $psr/species_info.csv | grep $species_search | cut -d , -f 3)

psr_species="$psr/accessions_by_species/$species_name.$accession"
psr_logs="$psr_species/.num_probe_pairs_log"

if [ $num_probe_pairs -gt 32 ]
  then 
    rm $psr_logs/max_list.csv
    touch $psr_logs/max_list.csv
    cat $psr_species/cleaned_cds_sequences_file_names.txt | parallel -j $num_threads "bash stock_shop_2.sh {} $species_name $species_initial $num_probe_pairs $max_homopolymer"
fi

if [ $num_probe_pairs -le 32 ]
  then
    awk -F, '$5>='$num_probe_pairs'' $psr_logs/max_list.csv > $psr_logs/tmp.run.$num_probe_pairs.csv
    cat $psr_logs/tmp.run.$num_probe_pairs.csv | cut -d , -f 3 | sort -u | parallel -j $num_threads "bash stock_shop_2.sh {} $species_name $species_initial $num_probe_pairs"
fi
