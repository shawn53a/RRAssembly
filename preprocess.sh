#Shawn Arreguin - 12/31/25
#Downloads SRR and preprocesses it 

#download SRR
mkdir "${HPATH}"/"$code"
echo "fasterq-dump "$SRR" -O "${HPATH}"/"${code}" -e "$threads"" | tee -a "${code}".log
fasterq-dump "$SRR" -O "${HPATH}"/"${code}" -e "$threads"


#preprocess raw reads
mkdir "${HPATH}"/"${code}"/preprocess
"$SPATH"/bin/semblans preprocess -1 "${HPATH}"/"${code}"/*_1* -2 "${HPATH}"/"${code}"/*_2* -f -r "$ram" -t "$threads" -v -o "${HPATH}"/"${code}"/preprocess -p "$code" | tee -a "${code}".log


#delete (compress for now)  raw reads
pigz -p "$threads" "${HPATH}"/"${code}"/*.fastq* | tee -a "${code}".log