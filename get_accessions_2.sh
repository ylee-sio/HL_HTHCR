#!/bin/bash

#this is the first script to be run in the entire probe library generation process. however, even before this, you must make a file called 
#'species_info.csv' and place it in the resources directory

search=$1
species_info=$(cat $HOME/probe_shop/resources/species_info.csv | grep $search)
species_name=$(echo $species_info | cut -d , -f 1)
species_initial=$(echo $species_info | cut -d , -f 2)
accession=$(echo $species_info | cut -d , -f 3)

species_dir="$HOME/probe_shop/resources/accessions_by_species/$species_name.$accession"
cds_dir="$species_dir/cds_sequence_files"
mkdir -p $species_dir
mkdir -p $cds_dir

datasets download genome accession $accession --include cds --filename "$species_dir"/ncbi_dataset.zip
unzip "$species_dir"/ncbi_dataset.zip -d "$species_dir"
cds_location=$(find $species_dir/*/*/GCF* -name *cds* -name *cds*)
echo $gtf_location
mv $cds_location $species_dir
rm -rf "$species_dir"/ncbi_dataset* "$species_dir"/README*

seqkit split -j 8 -O $cds_dir -i "$species_dir"/cds_from_genomic.fna

# make a list of cds sequence file names to refer to for subsequent scripts
ls $cds_dir > $species_dir/cds_sequences_file_names.txt

# make a cleaned list just with the protein accessions
cat "$species_dir"/cds_sequences_file_names.txt | cut -d "_" -f 9,10 > "$species_dir"/cleaned_cds_sequences_file_names.txt

# optional- probably should do this if making probe library available for entire community
# get ncbi summary report for each protein accession
#mkdir -p "$species_dir"/ncbi_reports
#cat "$species_dir"/cleaned_cds_sequences_file_names.txt | parallel -j 1 "bio fetch {} > $species_dir/ncbi_reports/{}.ncbi_report.txt"

# for logging max number of probes generatable
#"species_name,species_initial,accession,num_probe_pairs,actual_probe_pairs_num"
mkdir $species_dir/.num_probe_pairs_log
touch $species_dir/.num_probe_pairs_log/max_list.csv
