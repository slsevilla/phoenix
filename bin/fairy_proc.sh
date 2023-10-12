#!/bin/bash -l
#set +e
#
# Description: script to check for file integrity and log errors 
#
# Usage: ./fairy_proc.sh -r reads_file -p $meta.id
#
# v.1.0.0 (07/13/2023)
#
# Created by Maria Diaz (lex0@cdc.gov), additions by Jill Hagey (qpk9@cdc.gov) on 10/13/2023
#
#  Function to print out help blurb


show_help () {
  echo "Usage: fairy_proc.sh args(* are required)
    -r* fastq file
    -p* meta.id
    "
}

# Parse command line options
options_found=0
while getopts ":1?r:p:" option; do
	options_found=$(( options_found + 1 ))
	case "${option}" in
		\?)
			echo "Invalid option found: ${OPTARG}"
      show_help
      exit 0
      ;;
    r)
      echo "Option -r triggered, argument = ${OPTARG}"
      fname=${OPTARG};;
    p)
      echo "Option -p triggered, argument = ${OPTARG}"
      prefix=${OPTARG};;
    :)
      echo "Option -${OPTARG} requires as argument";;
    1)
      show_help
      exit 0
      ;;
	esac
done

sfx=".fastq.gz"
#fname="${1}"
#prefix=${fname%"$sfx"}
gzip -t $fname 2>> ${prefix}.txt

full_name=$(basename "${fname}" .fastq.gz)
#meta_id=$(basename "${fname}" .fastq.gz | cut -f1 -d"_")
read=$(echo "${full_name}" | grep -oP "_R\d_" | cut -f2 -d"_")

if grep -q -e "error" -e "unexpected" ${prefix}.txt; then
	#prefix=${prefix%%_*}
	echo "FAILED CORRUPTION CHECK! CANNOT UNZIP FASTQ FILE. CHECK FASTQ FILE ${prefix}_${read} FOR CORRUPTION!" >> ${prefix}_results.txt
	
	#error warning for line_summary channel
	echo "ID	Auto_QC_Outcome	Warning_Count	Estimated_Coverage	Genome_Length	Assembly_Ratio_(STDev)	#_of_Scaffolds_>500bp	GC_%	Species	Taxa_Confidence	Taxa_Coverage	Taxa_Source	Kraken2_Trimd	Kraken2_Weighted	MLST_Scheme_1	MLST_1	MLST_Scheme_2	MLST_2	GAMMA_Beta_Lactam_Resistance_Genes	GAMMA_Other_AR_Genes	AMRFinder_Point_Mutations	Hypervirulence_Genes	Plasmid_Incompatibility_Replicons	Auto_QC_Failure_Reason" > ${prefix}_summaryline_failure.tsv
	#file contents
	echo "${prefix}	FAIL	0	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	Unknown	CANNOT UNZIP FASTQ FILE. CHECK FASTQ FILE(S) FOR CORRUPTION!" | tr -d '\n' >> ${prefix}_summaryline_failure.tsv
	#create synopsis file
	sample_name=${prefix}
	# Creates and prints header info for the sample being processed
	today=$(date)
	echo "----------Checking ${sample_name} for successful completion on ----------"  > "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "Summarized" "SUCCESS" "${today}"  >> "${sample_name}.synopsis"

	#Write out QC counts as failures
    printf "%-30s: %-8s : %s\\n" "FASTQs" "FAILED" "${sample_name}_raw_read_counts reads QC file does not exist -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
    printf "%-30s: %-8s : %s\\n" "RAW_READ_COUNTS" "FAILED" "${sample_name}_raw_read_counts reads QC file does not exist -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "RAW_Q30_R1%" "FAILED" "${sample_name}_raw_read_counts.txt not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
    printf "%-30s: %-8s : %s\\n" "RAW_Q30_R2%" "FAILED" "${sample_name}_raw_read_counts.txt not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	
	printf "%-30s: %-8s : %s\\n" "TRIMMED_R1" "FAILED" "No trimming performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "TRIMMED_R2" "FAILED" "No trimming performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

    printf "%-30s: %-8s : %s\\n" "TRIMMED_FASTQs" "FAILED" "Trimmed reads QC file does not exist -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
    printf "%-30s: %-8s : %s\\n" "TRIMMED_READ_COUNTS" "FAILED" "Trimmed reads QC file does not exist -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	
	printf "%-30s: %-8s : %s\\n" "TRIMMED_Q30_R1%" "FAILED" "No trimming performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
    printf "%-30s: %-8s : %s\\n" "TRIMMED_Q30_R2%" "FAILED" "No trimming performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "KRAKEN2_READS" "FAILED" "${sample_name}.kraken2_trimd.report.txt not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "KRONA_READS" "FAILED" "kraken2 reads do not exist -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	status="FAILED"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_CLASSIFY_READS" "FAILED" "There are no classified reads -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "QC_COUNTS" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "Q30_STATS" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "BBDUK" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "TRIMMING" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_READS" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KROFAILED_READS" "FAILED" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	
	printf "%-30s: %-8s : %s\\n" "ASSEMBLY" "FAILED" "${sample_name}.scaffolds.fa.gz not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "SRST2" "FAILED" "SPAdes not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "SCAFFOLD_TRIM" "FAILED" "${sample_name}.filtered.scaffolds.fa.gz not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_ASMBLD" "FAILED" "${sample_name}.kraken2_asmbld.report.txt not found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRONA_ASMBLD" "FAILED" "kraken2 unweighted not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_CLASSIFY_ASMBLD" "FAILED" "kraken2 assembly not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_ASMBLD_CONTAM" "FAILED" "kraken2 assembly not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_WEIGHTED" "FAILED" "kraken2 weighted not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRONA_WEIGHTED" "FAILED" "kraken2 weighted not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_CLASSIFY_WEIGHTED" "FAILED" "kraken2 weighted not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "KRAKEN2_WEIGHTED_CONTAM" "FAILED" "kraken2 weighted not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "QUAST" "FAILED" "QUAST not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "TAXA-${tax_source}" "FAILED" "No Taxa File found -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "ASSEMBLY_RATIO(SD)" "FAILED" "No Ratio File exists -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "COVERAGE" "FAILED" "No trimmed reads to review for coverage -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "BUSCO" "FAILED" "BUSCO was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "FASTANI_REFSEQ" "FAILED" "FASTANI was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "MLST" "FAILED" "MLST was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "GAMMA_AR" "FAILED" "GAMMA_AR was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "PLASMID_REPLICONS" "FAILED" "GAMMA was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	printf "%-30s: %-8s : %s\\n" "HYPERVIRULENCE" "FAILED" "GAMMA was not performed -- FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"

	printf "%-30s: %-8s : %s\\n" "Auto PASS/FAIL" "FAIL" "FASTQs couldn't be unzipped!"  >> "${sample_name}.synopsis"
	
	echo "---------- ${sample_name} completed as ${status} ----------"  >> "${sample_name}.synopsis"
	echo "File corruption detected in one or more isolate FASTQs. Please check the FAIry result folder for details."  >> "${sample_name}.synopsis"
	echo "PHoeNIx will only analyze FASTQ files that can be unzipped without error."  >> "${sample_name}.synopsis"
	echo "\n"  >> "${sample_name}.synopsis"
	echo "WARNINGS: out of line with what is expected and MAY cause problems downstream."  >> "${sample_name}.synopsis"
	echo "ALERT: something to note, does not mean it is a poor-quality assembly."  >> "${sample_name}.synopsis"
else
	echo "PASSED: File ${prefix}_${read} is not corrupt." >> ${prefix}_results.txt
fi
