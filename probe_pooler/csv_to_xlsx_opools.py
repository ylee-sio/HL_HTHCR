import pandas as pd
import sys
from contextlib import suppress

with suppress(Exception):
	csv_file = sys.argv[1]
	outdir = str(sys.argv[2])
	data = pd.read_csv(csv_file)
	data.to_excel(outdir+"_opools_order.xlsx", index=None, header=True)
