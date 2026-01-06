#Shawn Arreguin - 12/31/25
#Extracts bacterial, chloroplast, mito, and nuclear reads using kraken

#Kraken to extract bacterial reads
echo ""${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"/STD_PF/ --paired --classified-out "${HPATH}/${code}"/bacterial\#.fq --unclassified-out "${HPATH}/${code}"/not_bacteria\#.fq "${HPATH}/${code}"/preprocess/preprocess/03-Trimming/*_1.paired* "${HPATH}/${code}"/preprocess/preprocess/03-Trimming/*_2.paired* --threads "$threads" > "${HPATH}/${code}"/DetectedBacteria.txt" | tee -a "${HPATH}/${code}/${code}.log"

"${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"/STD_PF/ --paired --classified-out "${HPATH}/${code}"/bacterial\#.fq --unclassified-out "${HPATH}/${code}"/not_bacteria\#.fq "${HPATH}/${code}"/preprocess/preprocess/03-Trimming/*_1.paired* "${HPATH}/${code}"/preprocess/preprocess/03-Trimming/*_2.paired* --threads "$threads" > "${HPATH}/${code}"/DetectedBacteria.txt | tee -a "${HPATH}/${code}/${code}.log"
	
#gzip preprocessed
pigz -v -p "$threads" "${HPATH}/${code}"/preprocess/preprocess/03-Trimming/*.fq | tee -a "${HPATH}/${code}/${code}.log"

#Kraken to extract chloro
echo ""${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"KrakenDBplastid/ --confidence 0.1 --paired --classified-out "${HPATH}/${code}"/chloro\#.fq --unclassified-out "${HPATH}/${code}"/intermediate\#.fq "${HPATH}/${code}"/not_bacteria_1.fq "${HPATH}/${code}"/not_bacteria_2.fq --threads "$threads" > "${HPATH}/${code}"/DetectChloro.txt" | tee -a "${HPATH}/${code}/${code}.log"

"${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"KrakenDBplastid/ --confidence 0.1 --paired --classified-out "${HPATH}/${code}"/chloro\#.fq --unclassified-out "${HPATH}/${code}"/intermediate\#.fq "${HPATH}/${code}"/not_bacteria_1.fq "${HPATH}/${code}"/not_bacteria_2.fq --threads "$threads" > "${HPATH}/${code}"/DetectChloro.txt | tee -a "${HPATH}/${code}/${code}.log"

#Kraken to extract mito
echo ""${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"KrakenDBmitochondrion/ --confidence 0.1 --paired --classified-out "${HPATH}/${code}"/mito\#.fq --unclassified-out "${HPATH}/${code}"/nuclear\#.fq "${HPATH}/${code}"/intermediate_1.fq "${HPATH}/${code}"/intermediate_2.fq --threads "$threads" > "${HPATH}/${code}"/DetectMito.txt" | tee -a "${HPATH}/${code}/${code}.log"

"${SPATH}"/external/kraken2/kraken2 -db "${KdbPATH}"KrakenDBmitochondrion/ --confidence 0.1 --paired --classified-out "${HPATH}/${code}"/mito\#.fq --unclassified-out "${HPATH}/${code}"/nuclear\#.fq "${HPATH}/${code}"/intermediate_1.fq "${HPATH}/${code}"/intermediate_2.fq --threads "$threads" > "${HPATH}/${code}"/DetectMito.txt | tee -a "${HPATH}/${code}/${code}.log"

#gzip detect files
pigz -v -p "$threads" "${HPATH}/${code}"/DetectedBacteria.txt | tee -a "${HPATH}/${code}/${code}.log"
pigz -v -p "$threads" "${HPATH}/${code}"/DetectChloro.txt | tee -a "${HPATH}/${code}/${code}.log"
pigz -v -p "$threads" "${HPATH}/${code}"/DetectMito.txt | tee -a "${HPATH}/${code}/${code}.log"

#rm intermediate
echo "rm bacterial_* intermediate_* not_bacteria_*" | tee -a "${HPATH}/${code}/${code}.log"
rm bacterial_* intermediate_* not_bacteria_*

