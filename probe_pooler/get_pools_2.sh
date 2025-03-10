#!/bin/bash

ps="$HOME/probe_shop"
psp="$ps/probes"
pss="$ps/scripts"
psr="$ps/resources"
pooler="$pss/probe_pooler"
final="$ps/final_probe_sets"
#CRITICAL using species name get species initial, etc etc from the resources file
species_search=$1
species_info=$(cat $HOME/probe_shop/resources/species_info.csv | grep $species_search)
species_name=$(echo $species_info | cut -d , -f 1)
species_initial=$(echo $species_info | cut -d , -f 2)
species_accession=$(echo $species_info | cut -d , -f 3)

session=$(shuf -i 100000000000-999999999999 -n 1)
#CRITICAL make the creation of the final folder part of a setup process
session_dir="$final"/SESSION_"$session"
mkdir -p $session_dir

echo " "
printf 'session,pool,species_name,accession,common_gene_name,hairpin,number_of_probe_pairs' > $session_dir/$session.form.csv

proceed_session='y'
while [ $proceed_session == 'n' ]
  proceed_pool='y'
  probe_num=1
  pool=$(shuf -i 100000000-999999999 -n 1)
  pool_id=POOL_"$pool"
  pool_dir="$session_dir"/POOL_"$pool"
  mkdir -p $pool_dir/components
  mkdir -p $pool_dir/order
  components=$pool_dir/components
  order=$pool_dir/order
  do
    while [ $proceed_pool == 'n' ]
    echo "********** PROBE $probe_num **********" 
      do
        test_probe="fail"
        while [ $test_probe != "pass" ]
          do
            read -p 'Enter accession: ' accession
            test_probe="pass"
            let "probe_num+=1"
            bash $pss/stock_shop_simulate.sh $accession $species_name $species_initial $num_probe_pairs $max_homopolymer_num
            read -p 'Enter maximum homopolymer allowed: ' max_homopolymer_num
            read -p 'Enter maximum number of pairs dedicated for this target: ' num_probe_pairs
            echo " "
            bash $pss/stock_shop_2.sh $accession $species_name $species_initial $num_probe_pairs $max_homopolymer_num
            echo " "
            cp -r $psp/$species_name/$species_initial/$accession $components
            bio fetch $accession > $components/$accession/primary_reports/$accession.ncbi_report.txt
          done

        read -p 'Enter hairpin: ' hairpin
        sed 1d $components/$accession/hcr_probes_all_hairpins/csv/$hairpin* > $order/"$hairpin"_"$accession".csv
        if [[ "$hairpin" != b[0-9] ]]; then
          while [ "$hairpin" != b[0-9] ]
            do
	      echo " "
              echo "$hairpin is not a valid entry for hairpin."
	      echo "Enter b1, b2, b3, b4, or b5."
              echo " "
              read -p 'Enter hairpin: ' hairpin
	      if [[ "$hairpin" =~ ^b+[0-9] ]]; then 
                sed 1d $components/$accession/hcr_probes_all_hairpins/csv/$hairpin* > $order/"$hairpin"_"$accession".csv
                break
              else echo "$hairpin"
              fi
            done
        fi

        read -p 'Enter common gene name (no symbols): ' cgn
        sed -i -e '$a\'SESSION_"$session",POOL_"$pool",$species_name,$accession,$cgn,$hairpin,$num_probe_pairs $session_dir/$session.form.csv
        echo "Your probe request form currently looks like this: "
        echo " "
        cat $session_dir/$session.form.csv
        echo " "
        read -p 'Add another probe to this pool? (Enter y/n): ' proceed_pool
        echo " "
        if [ $proceed_pool == 'n' ]; then
          cat $order/b* > $order/"$pool_id"_opools_order_unmerged.csv
          awk -v pool_name="$pool_id" '$1=pool_name' FS=, OFS=, $order/"$pool_id"_opools_order_unmerged.csv > $order/"$pool_id"_opools_order.csv
          sed -i '1s/^/Pool name,Sequence\n/' $order/"$pool_id"_opools_order.csv
          python $pss/probe_pooler/csv_to_xlsx_opools.py $order/"$pool_id"_opools_order.csv "$order"/"$pool_id"
          mkdir $order/.tmp
          mv $order/*.csv $order/.tmp
          break
        fi
      done
    read -p 'Would you like to make another pool in this session? (Enter y/n): ' proceed_session
    if [ $proceed_session == 'n' ]; then
      break
    fi
done

read -p 'Keep session files? (Enter y/n): ' keep_session

if [ $keep_session == 'n' ]; then
  rm -rf $session_dir
  echo "SESSION_$session has been removed."
else
  zip -rq $session_dir.zip $session_dir
  rm -rf ~/$session_dir
  echo '$session_dir is available in your home directory.'
  echo "The next run of probe pooling will remove $session_dir and all other session files automatically."
  echo 'All session files are archived in final_probe_pools.'
  cp $session_dir.zip ~
fi
