file=$1

num_pools=$(cat $file | cut -d , -f 7 | uniq | sed 1d)
for i in $num_pools
do
	echo pool $i
	# column 7 is for pool number in spreadsheet
	csvgrep -c 7 -r $i $file | sed 1d 
done