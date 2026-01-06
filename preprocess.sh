#Shawn Arreguin - 12/31/25
#Downloads SRR and preprocesses it 

#echo some stuff
echo "SRR to download: ${SRR} " | tee -a "${HPATH}/${code}/${code}.log"
echo "4 Letter Code: ${code} " | tee -a "${HPATH}/${code}/${code}.log"

#download SRR
mkdir "${HPATH}/${code}"
echo "fasterq-dump "$SRR" -O "${HPATH}/${code}" -e "$threads"" | tee -a "${HPATH}/${code}/${code}.log"
fasterq-dump "$SRR" -O "${HPATH}/${code}" -e "$threads"


#preprocess raw reads
mkdir "${HPATH}/${code}"/preprocess
"$SPATH"/bin/semblans preprocess -1 "${HPATH}/${code}"/*_1* -2 "${HPATH}/${code}"/*_2* -f -r "$ram" -t "$threads" -v -o "${HPATH}/${code}"/preprocess -p "${code}" | tee -a "${HPATH}/${code}/${code}.log"


#delete (compress for now)  raw reads
echo "rm *.fastq" | tee -a "${HPATH}/${code}/${code}.log"
rm *.fastq
rm -r "${HPATH}/${code}"/preprocess/preprocess/04* "${HPATH}/${code}"/preprocess/preprocess/05* "${HPATH}/${code}"/preprocess/preprocess/06* "${HPATH}/${code}"/preprocess/preprocess/02*