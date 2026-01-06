#Shawn Arreguin - 12/31/25
#Assembles nuclear, mito, and chloro reads

#Nuclear Assembly
mkdir "${HPATH}/${code}/nuclear"
"$SPATH"/bin/semblans assemble -1 "${HPATH}/${code}"/nuclear_1.fq -2 "${HPATH}/${code}"/nuclear_2.fq -p "${code}" -rp "${refPro}" -t "$threads" -r "$ram"  -o "${HPATH}/${code}"/nuclear | tee -a "${HPATH}/${code}/${code}.log"
"$SPATH"/bin/semblans postprocess -1 "${HPATH}/${code}"/nuclear_1.fq -2 "${HPATH}/${code}"/nuclear_2.fq -p "${code}" -rp "${refPro}" -t "$threads" -r "$ram" -o "${HPATH}/${code}"/nuclear -a "${HPATH}/${code}"/nuclear/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${HPATH}/${code}/${code}.log"

#gzip nuclear reads
pigz -v -p "$threads" "${HPATH}/${code}"/nuclear_* | tee -a "${HPATH}/${code}/${code}.log"
rm -r "${HPATH}/${code}"/nuclear/postprocess/01-Filter_chimera/

#Mito Assembly
mkdir "${HPATH}/${code}/mitochondrial"
"$SPATH"/bin/semblans assemble -1 "${HPATH}/${code}"/mito_1.fq -2 "${HPATH}/${code}"/mito_2.fq -p Mito_"${code}" -rp "${refPro}" -t "$threads" -r "$ram" -o "${HPATH}/${code}"/mitochondrial | tee -a "${HPATH}/${code}/${code}.log"
"$SPATH"/bin/semblans postprocess -1 "${HPATH}/${code}"/mito_1.fq -2 "${HPATH}/${code}"/mito_2.fq -p Mito_"${code}" -rp "${refPro}" -t "$threads" -r "$ram" -o "${HPATH}/${code}"/mitochondrial -a "${HPATH}/${code}"/mitochondrial/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${HPATH}/${code}/${code}.log"

#gzip mito reads
pigz -v -p "$threads" "${HPATH}/${code}"/mito_* | tee -a "${HPATH}/${code}/${code}.log"
rm -r "${HPATH}/${code}"/mitochondrial/postprocess/01-Filter_chimera/

#Chloro Assembly
mkdir "${HPATH}/${code}/chloroplast"	
"$SPATH"/bin/semblans assemble -1 "${HPATH}/${code}"/chloro_1.fq -2 "${HPATH}"/"${code}"/chloro_2.fq -p Chloro_"${code}" -rp "${refPro}" -t "$threads" -r "$ram" -o "${HPATH}/${code}"/chloroplast | tee -a "${HPATH}/${code}/${code}.log"
"$SPATH"/bin/semblans postprocess -1 "${HPATH}"/"${code}"/chloro_1.fq -2 "${HPATH}"/"${code}"/chloro_2.fq -p Chloro_"${code}" -rp "${refPro}" -t "$threads" -r "$ram" -o "${HPATH}/${code}"/chloroplast -a "${HPATH}/${code}"/chloroplast/assembly/01-Transcript_assembly/*.Trinity.fasta | tee -a "${HPATH}/${code}/${code}.log"

#gzip chloro reads
pigz -v -p "$threads" "${HPATH}/${code}"/chloro_* | tee -a "${HPATH}/${code}/${code}.log"
rm -r "${HPATH}/${code}"/chloroplast/postprocess/01-Filter_chimera/
