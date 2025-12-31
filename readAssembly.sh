#Shawn Arreguin, 12/28/25
#Downloading and assembling SRRs

SRRs=$1

SPATH=~/analysis/Semblans/bin/semblans
HPATH=/archive/shawn/Lamiaceae
KPATH=~/analysis/Semblans/external/kraken2/kraken2
KdbPATH=~/kraken-dbs/

while IFS= read -r line
do
	code="${line%%	*}"
	SRR="${line##*	}"
	mkdir "$code"
        cd "$code"/
	echo "SRR to download: ${SRR} " | tee -a "${code}".log
	echo "4 Letter Code: ${code} " | tee -a "${code}".log
	

	#download SRR
	echo "fasterq-dump "$SRR" -O . -e 10" | tee -a "${code}".log
	#fasterq-dump "$SRR" -O . -e 16 | tee -a "${code}".log

	#preprocess SRR
	#mkdir preprocess
	#"$SPATH" preprocess -1 *_1* -2 *_2* -f -r 60 -t 16 -v -o preprocess -p "$code" | tee -a "${code}".log

	#delete (compress for now)  raw reads
	pigz -p 10 *.fastq* | tee -a "${code}".log

	#Kraken to extract bacterial reads
	echo ""$KPATH" -db "${KdbPATH}"STD_PF/ --paired --classified-out bacterial\#.fq --unclassified-out not_bacteria\#.fq preprocess/preprocess/03-Trimming/*_1.paired* preprocess/preprocess/03-Trimming/*_2.paired* --threads 10 > DetectedBacteria.txt | tee -a "${code}".log" | tee -a "${code}".log
	
	#"$KPATH" -db "${KdbPATH}"STD_PF/ --paired --classified-out bacterial\#.fq --unclassified-out not_bacteria\#.fq preprocess/preprocess/03-Trimming/*_1.paired* preprocess/preprocess/03-Trimming/*_2.paired* --threads 10 > DetectedBacteria.txt | tee -a "${code}".log
	
	#gzip preprocessed
	pigz -p 10 preprocess/preprocess/03-Trimming/*.fq | tee -a "${code}".log

	#Kraken to extract chloro
	echo ""$KPATH" -db "${KdbPATH}"KrakenDBplastid/ --confidence 0.1 --paired --classified-out chloro\#.fq --unclassified-out intermediate\#.fq not_bacteria_1.fq not_bacteria_2.fq --threads 10 > DetectChloro.txt" | tee -a "${code}".log

	#"$KPATH" -db "${KdbPATH}"KrakenDBplastid/ --confidence 0.1 --paired --classified-out chloro\#.fq --unclassified-out intermediate\#.fq not_bacteria_1.fq not_bacteria_2.fq --threads 10 > DetectChloro.txt | tee -a "${code}".log

	#gzip/rm bac & not_bac
	pigz -p 10 bacterial* | tee -a "${code}".log
	pigz -p 10 not_bacteria* | tee -a "${code}".log

	#Kraken to extract mito
	echo ""$KPATH" -db "${KdbPATH}"KrakenDBmitochondrion/ --confidence 0.1 --paired --classified-out mito\#.fq --unclassified-out nuclear\#.fq intermediate_1.fq intermediate_2.fq --threads 10 > DetectMito.txt" | tee -a "${code}".log

	#"$KPATH" -db "${KdbPATH}"KrakenDBmitochondrion/ --confidence 0.1 --paired --classified-out mito\#.fq --unclassified-out nuclear\#.fq intermediate_1.fq intermediate_2.fq --threads 10 > DetectMito.txt | tee -a "${code}".log
	
	#gzip/rm intermediate
	pigz -p 10 intermediate_* | tee -a "${code}".log

	#Nuclear Assembly
	mkdir nuclear
	"$SPATH" assemble -1 ./nuclear_1.fq -2 ./nuclear_2.fq -p "$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o nuclear | tee -a "${code}".log
	"$SPATH" postprocess -1 ./nuclear_1.fq -2 ./nuclear_2.fq -p "$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o nuclear -a ./nuclear/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${code}".log
	
	#gzip nuclear reads
	pigz -p 10 nuclear_* | tee -a "${code}".log

	#Mito Assembly
	mkdir mitochondrial
	"$SPATH" assemble -1 ./mito_1.fq -2 ./mito_2.fq -p Mito_"$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o mitochondrial | tee -a "${code}".log
        "$SPATH" postprocess -1 ./mito_1.fq -2 ./mito_2.fq -p Mito_"$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o mitochondrial -a ./mitochondrial/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${code}".log
	
	#gzip mito reads
	pigz -p 10 mito_* | tee -a "${code}".log

	#Chloro Assembly
	mkdir chloroplast	
	"$SPATH" assemble -1 ./chloro_1.fq -2 ./chloro_2.fq -p Chloro_"$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o chloroplast | tee -a "${code}".log
        "$SPATH" postprocess -1 ./chloro_1.fq -2 ./chloro_2.fq -p Chloro_"$code" -rp /archive/shawn/ensembl_plant.pep.all.fa -t 30 -r 100 -o chloroplast -a ./chloroplast/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${code}".log
	
	#gzip chloro reads
	pigz -p 10 chloro_* | tee -a "${code}".log

done < $SRRs
