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

		#realign
		parallel -j 30 mafft \-\-auto \-\-maxiterate 1000 \-\-thread 2 {} \> {}\.aln ::: *.fa
		#clean
		for x in *.aln; do "$pxclsqP" -s $x -p 0.1 -o $x-cln; done

		#fasttree
		mkdir fastTree
		for x in *-cln; do y=$(grep -c "^>" $x); if [ $y -gt 1000 ]; then echo "$x" && echo $y && mv ${x} ./fastTree/; fi done

		#tree inference
		cd ./fastTree
		parallel -j 30 "$iqtreeP" \-s {} \-nt 2 \-m GTR+G -fast ::: *-cln
		cd ..
		parallel -j 30 "$iqtreeP" \-s {} \-nt 2 \-m GTR+G \-bb 1000 ::: *-cln

		#Renaming and checks
		scp ./fastTree/*-cln .
		scp ./fastTree/*.treefile .

		for x in *.treefile; do sed -i -r 's/([A-Z]{3,5}[1-9]?)_/\1@/g' ${x}; done
		mkdir ./tooFew
		for x in *-cln; do y=$(grep -c "@" ${x}); z=$(grep -o "@" ${x}.treefile | wc -l); if [ $y != $z ]; then echo ${x} $z $y && scp ${x} ./tooFew/; else echo "good"; fi done

		#Ya Yang Scripts
		conda run -n 2.7 "$YaP"/trim_tips.py . .treefile 0.2 0.3 
		conda run -n 2.7 "$YaP"/mask_tips_by_taxonID_transcripts.py . . n

		mkdir ./subtrees
		conda run -n 2.7 "$YaP"/cut_long_internal_branches.py . .mm 0.5 4 ./subtrees/

		mkdir ./finalTrees
		for x in *.treefile; do echo ${x}; echo ${x%%.*}_1.subtree; OG=$(grep -o "@" ${x} | wc -l); sub=$(grep -o "@" ./subtrees/${x%%.*}_1.subtree | wc -l); if [ $OG == $sub ]; then mv ./subtrees/${x%%.*}_1.subtree ./finalTrees/ && c=$((c+1)); fi done
		
		#write new fastaFiles
		dirCount=$((dirCount+1))
		mkdir ../fastaMCL"$dirCount"
		cd ./subtrees
		conda run -n 2.7 "$YaP" python ~/analysis/yayang/write_fasta_files_from_trees.py ../../total.fa . .subtree ../../fastaMCL"$dirCount"

		#move to new iteration and check fasta count
		cd ../../fastaMCL"$dirCount"
		faCount=$(ls *.fa | wc -l)


done
















conda run -n 2.7 