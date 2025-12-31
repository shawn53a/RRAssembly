#Shawn Arreguin - 12/31/25
#Read assembly, but more controlled

# To run we need the following:
#   ram
#   SRRs
#   cores
#   reference proteome
#   kraken DBs
#   Semblans
#   Home

usage() { echo -e "\n$0 \n\n[-r] amount of ram <number> \n[-t] number of threads <number> \n[-a] <tsv with SRR accesions> \n[-k] <path to Kraken DBs> \n[-s] <path to Semblans> \n[-p] <path to reference proteome> \n[-b] <path of working directory>" >&2; }

while getopts ":hr:t:a:p:k:s:b:" OPTION; do
        case "$OPTION" in
                r)
                        ram=${OPTARG}
                        ;;
                t)      
                        threads=${OPTARG}
                        ;;
                a)
                        SRR=${OPTARG}
                        ;;

                p)      refPro=${OPTARG}
                        ;;

                k)      KdbPATH=${OPTARG}
                        ;;

                s)      SPATH=${OPTARG}
                        ;;

                b)      HPATH=${OPTARG}
                        ;;

                :)      
                        echo "Option -${OPTARG} requires an argument" >&2
                        usage
                        exit 1
                        ;;
                h)
                        usage
                        exit 0
                        ;;
                ?)
                        echo "Invalid option: -${OPTARG}" >&2
                        usage
                        exit 1
                        ;;
        esac
done    

if [ -z "${ram}" ] || [ -z "${threads}" ] || [ -z "${SRR}" ] || [ -z "${refPro}" ] || [ -z "${KdbPATH}" ] || [ -z "${SPATH}" ] || [ -z "${HPATH}" ] ];then
        usage
        exit 1
fi

echo $ram
echo $threads


