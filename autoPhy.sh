#Shawn Arreguin - 10/23/26
#Orthology inference 

#this script will run rounds of tree trimming automatically, best for use during later rounds of the Ya Yang pipeline
#You will need:
#	Ya Yang's Scripts
#	phyx
#	mafft
#	iqtree
#	virtual env with python 2.7 (this script specifically uses conda)

#Dependency paths:
iqtreeP=~/analysis/iqtree-3.0.1-Linux/bin/iqtree3
pxclsqP=~/analysis/phyx/src/pxclsq
YaP=~/analysis/yayang

faCount=$(ls *.fa | wc -l)

z=$(pwd)

dirCount=$(echo $z | sed -r 's/.*fastaMCL([0-9]{1,3}).*/\1/')



while [ $faCount -gt 0 ]; do 


		curDir=$(pwd)

		touch "$curDir"/auto_log.txt

		echo $faCount | tee -a "$curDir"/auto_log.txt

		#align
		echo "realign" | tee -a "$curDir"/auto_log.txt
		parallel -j 30 mafft \-\-auto \-\-maxiterate 1000 \-\-thread 2 {} \> {}\.aln ::: *.fa
		#clean
		for x in *.aln; do "$pxclsqP" -s $x -p 0.1 -o $x-cln; done

		#fasttree
		echo "fastTree" | tee -a "$curDir"/auto_log.txt
		mkdir fastTree
		for x in *-cln; do y=$(grep -c "^>" $x); if [ $y -gt 1000 ]; then echo "$x" && echo $y && mv ${x} ./fastTree/; fi done | tee -a "$curDir"/auto_log.txt

		#tree inference
		echo "Tree Inference" | tee -a "$curDir"/auto_log.txt
		cd ./fastTree
		pwd | tee -a "$curDir"/auto_log.txt
		parallel -j 30 "$iqtreeP" \-s {} \-nt 2 \-m GTR+G -fast ::: *-cln

		cd ..
		pwd | tee -a "$curDir"/auto_log.txt
		parallel -j 30 "$iqtreeP" \-s {} \-nt 2 \-m GTR+G \-bb 1000 ::: *-cln

		#Renaming and checks
		echo "Renaming" | tee -a "$curDir"/auto_log.txt
		scp ./fastTree/*-cln .
		scp ./fastTree/*.treefile .

		ls *.fa | wc -l | tee -a "$curDir"/auto_log.txt
		ls *-cln | wc -l | tee -a "$curDir"/auto_log.txt
		ls *.treefile | wc -l | tee -a "$curDir"/auto_log.txt


		for x in *.treefile; do sed -i -r 's/([A-Z]{3,5}[1-9]?)_/\1@/g' ${x}; done
		mkdir ./tooFew
		for x in *-cln; do y=$(grep -c "@" ${x}); z=$(grep -o "@" ${x}.treefile | wc -l); if [ $y != $z ]; then echo ${x} $z $y && scp ${x} ./tooFew/; else echo "good"; fi done | tee -a "$curDir"/auto_log.txt

		#Ya Yang Scripts
		echo "Ya Scripts" | tee -a "$curDir"/auto_log.txt
		conda run -n 2.7 "$YaP"/trim_tips.py . .treefile 0.2 0.3 | tee -a "$curDir"/auto_log.txt
		conda run -n 2.7 "$YaP"/mask_tips_by_taxonID_transcripts.py . . n | tee -a "$curDir"/auto_log.txt

		mkdir ./subtrees
		conda run -n 2.7 "$YaP"/cut_long_internal_branches.py . .mm 0.5 4 ./subtrees/ | tee -a "$curDir"/auto_log.txt

		mkdir ./finalTrees
		c=0
		for x in *.treefile; do echo ${x}; echo ${x%%.*}_1.subtree; OG=$(grep -o "@" ${x} | wc -l); sub=$(grep -o "@" ./subtrees/${x%%.*}_1.subtree | wc -l); if [ $OG == $sub ]; then mv ./subtrees/${x%%.*}_1.subtree ./finalTrees/ && c=$((c+1)); fi done
		echo $c | tee -a "$curDir"/auto_log.txt
		
		#write new fastaFiles
		dirCount=$((dirCount+1)) 
		mkdir ../fastaMCL"$dirCount"
		cd ./subtrees
		pwd | tee -a "$curDir"/auto_log.txt
		conda run -n 2.7 "$YaP" python ~/analysis/yayang/write_fasta_files_from_trees.py ../../total.fa . .subtree ../../fastaMCL"$dirCount" | tee -a "$curDir"/auto_log.txt

		#move to new iteration and check fasta count
		cd ../../fastaMCL"$dirCount"
		pwd | tee -a "$curDir"/auto_log.txt
		faCount=$(ls *.fa | wc -l)
		echo $faCount | tee -a "$curDir"/auto_log.txt


done
















conda run -n 2.7 