import pandas as pd 
import numpy as np

df = pd.read_csv("round_3.csv")
total_pool_num = pd.unique(df["pool_number"])

for i in total_pool_num:
	pool = df[df["pool_number"] == i]
	total_target_num = pd.unique(pool["target_number"])
		for n in total_target_num:
			name = pool[pool["target_number"] == n]["name"]
			protein_accession = pool[pool["target_number"] == n]["protein_accession"]
			number_of_probe_pairs_designed = pool[pool["target_number"] == n]["number_of_probe_pairs_designed"]
			hairpin = pool[pool["target_number"] == n]["hairpin"]
			probes_out = maker(name,fullseq,amplifier,pause,choose,polyAT,polyCG,BlastProbes,db,dropout,show,report,maxprobe,numbr)