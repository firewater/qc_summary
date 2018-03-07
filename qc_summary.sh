#!/usr/bin/env bash



################
# About
################
# Create a summary of FastQC's results.
# FastQC: www.bioinformatics.babraham.ac.uk/projects/fastqc/
# The summary will look like:
# Base# Sample1 Sample2 Etc...
# 1		123.456	654.321 123...



################
# Variables
################

# Prefix of input file.
input_prefix='CB'

# Suffix of input file.
input_suffix='.zip'

# Filename containing data to extract.
input_data_file='fastqc_data.txt'

# After input files are found, the list is sorted alphanumerically.
# This variable the start and stop position of the key to use for sorting.
# Example: input file CB1_blah_R1_001_val_1_fastqc.zip
# Here, the sort key would be 1.3: 1(the start) = C, 3(the stop) = 1
# In other words, we're sorting by CBn (n being a single number).
# This ultimately effects the ordering of the samples in the output file.
input_sort_key='1.3'

# Extract lines between these two lines.
search_start='#Base\tMean'
search_end='>>END_MODULE'

# Temp file to write to.
temp_file='qc_sum_tmp.txt'

# Write summary to this file.
output='qc_summary.tsv'



################
# Script
################

echo -e "\n*** qc_summary_pre_trim.sh ***\n"

# If output file exists, prompt to delete it.
# -f file is a regular file (not a directory or device file).
if [ -f "${output}" ] ; then
	echo "${output} exists. Type y or n to delete it:"
	read rm_output
	if [ "${rm_output}" = 'y' ] ; then
		echo -e "Deleting..."
		rm "${output}"
	else
		echo -e "Exiting..."
		exit
	fi
fi

# Get list of input files.
input_files=("${input_prefix}"*"${input_suffix}")
num_files_found="${#input_files[@]}"
echo "Files found: ${num_files_found}"

# Sort input files alphanumerically.
IFS=$'\n' input_files=($(sort -n -k"${input_sort_key}" <<<"${input_files[*]}"))
unset IFS

# The first row in the output file. Contains sample names.
header="Base\t"

first_input_file="${input_files[0]}"
# The directory name inside the zip file.
zip_dir=$(basename "${first_input_file}" "${input_suffix}")
# Get the first column (base numbers) from the first file.
unzip -p "${first_input_file}" "${zip_dir}"/"${input_data_file}" | # Read input_data_file within the ZIP file without extracting it.
awk "/${search_start}/{f=1;next} /${search_end}/{f=0} f" | # Get lines between start and end.
cut -f1 > "${output}" # Get the first column then write to output.

# Process each input file.
num_files_processed=0
for file in "${input_files[@]}" ; do
	# Get the sample name.
	sample="$(echo "${file}" | cut -d'_' -f1 -)"

	# Determine if it's sample R1 or R2.
	if [[ "${file}" == *"_R1_"* ]] ; then
		sample="${sample}_1"
		#echo "${sample}"
	elif [[ "${file}" == *"_R2_"* ]] ; then
		sample="${sample}_2"
		#echo "${sample}"
	fi

	# Add sample to header.
	header="${header}${sample}\t"

	# The directory name inside the zip file.
	zip_dir=$(basename "${file}" "${input_suffix}")

	unzip -p "${file}" "${zip_dir}"/"${input_data_file}" | # Read input_data_file from the ZIP file without extracting it.
	awk "/${search_start}/{f=1;next} /${search_end}/{f=0} f" | # Get lines between start and end.
	cut -f2 | # Get the second column (the mean).
	paste "${output}" - > "${temp_file}" && mv "${temp_file}" "${output}" # Combine output file and second column.
	# Write to temp file.
	# Rename temp file to output file (overwrites output file).

	((num_files_processed++))
	# Progress bar:
	# -n do not output the trailing newline.
	# -e enable interpretation of backslash escapes.
	# \r goes back to the beginning of the line.
	echo -ne "Files processed: ${num_files_processed} of ${num_files_found}\r"
done

# Finish progress bar.
echo -ne '\n'

# Write header to top of output.
# Remove trailing whitespace.
header="$(echo -e "${header}" | sed -e 's/[[:space:]]*$//')"
# -i edit file in place.
sed -i "1s/^/${header}\n/" "${output}"

echo "Output file: ${output}"
echo "Column count: $(head -n 1 ${output} | tr '\t' '\n' | wc -l)"
echo -e "\n*** Done! ***\n"
