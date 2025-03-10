#!/bin/bash

#gene_name
gn=$1
species_name=$2
species_initial=$3
num_probe_pairs=$4
max_homopolymer=$5

#PATHS

#probe shop
ps="$HOME/probe_shop"
#probe shop probes
psp="$ps/probes"
#probe shop scripts
pss="$ps/scripts"
#species probe num dir
spnd="$psp/"$species_name"/"$species_initial""
mkdir -p "$spnd"

#gene item
gi="$spnd/$gn"

# creates directories for subsequent files related to this probe target
mkdir -p "$gi/primary_reports"
mkdir -p "$gi/processed_report_components"
mkdir -p "$gi/hcr_probegen_reports"
mkdir -p "$gi/hcr_probes_all_hairpins"

# shortened 
pr="$gi/primary_reports"
prc="$gi/processed_report_components"
hpr="$gi/hcr_probegen_reports"
hpa="$gi/hcr_probes_all_hairpins"

#resource directories
res="$ps/resources/accessions_by_species/$species_name*"

# copies ncbi report
#cp $res/ncbi_reports/$gn* $pr/$gn.ncbi_report.txt

# copies cds sequence file 
cp $res/cds_sequence_files/*$gn* $pr/$gn.cds.txt

# remove headers and whitespace from cds_report
cat $pr/$gn.cds.txt | tail -n +2 | tr -d " \t\n\r" > $prc/$gn.cds.cleaned.txt

mkdir -p "$hpa/csv"

for i in "b1" "b2" "b3" "b4" "b5"
do
   python "$ps"/ipg/make_probe.py "sp" $gn $i $prc/$gn.cds.cleaned.txt $num_probe_pairs $max_homopolymer > $hpr/$i.$gn.probegen_report.txt
   begin=$(cat $hpr/$i.$gn.probegen_report.txt | grep -Fn "Pool name, Sequence" | cut -d ":" -f 1)
   end_num=$(cat $hpr/$i.$gn.probegen_report.txt | grep -Fn "Figure Layout of Probe Sequences" | cut -d ":" -f 1)
   end=$(expr "$end_num" - 3)
   cat $hpr/$i.$gn.probegen_report.txt | sed -n "$begin","$end"p | sed 's/ *, */,/' > $hpa/csv/$i.$gn.opools_order.csv
   python "$pss"/csv_to_xlsx.py $hpa/csv/$i.$gn.opools_order.csv "$gn" "$i" "$hpa/"
done

actual_probe_num=$(cat $hpa/csv/b1.$gn.opools_order.csv | sed 1d | wc -l)
actual_probe_pairs_num=$(expr $actual_probe_num / 2)
echo "$gn,$num_probe_pairs,$actual_probe_pairs_num" >> ~/probe_shop/resources/actual_probe_pairs_record.txt
echo "***** Probes generated for $gn - $num_probe_pairs probe pairs run - $actual_probe_pairs_num probe pairs actually made - $species_name *****"

if [ $num_probe_pairs -gt 32 ]
  then 
    # make an initial list of maximum probe pairs available to make for each accession
    mkdir -p  $res/.num_probe_pairs_log
    echo "$species_name,$species_initial,$gn,$num_probe_pairs,$actual_probe_pairs_num" >> $res/.num_probe_pairs_log/max_list.csv
fi
