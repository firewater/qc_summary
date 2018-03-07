# qc_summary
Report the mean quality score per base from the output of FastQC.

[FastQC](www.bioinformatics.babraham.ac.uk/projects/fastqc/) is used in bioinformatics as a quality control tool for high throughput sequence data. qc_summary.sh takes FastQC's output and reports the mean quality score per base.

## Input

FastQC creates an HTML file and a ZIP file per sample, for example sample1_fastqc.zip. qc_summary.sh takes the ZIP files, looks for a file named fastqc_data.txt inside, then extracts the information in the section labeled "Per base sequence quality pass":

```
...
>>Per base sequence quality	pass
#Base	Mean	Median	Lower Quartile	Upper Quartile	10th Percentile	90th Percentile
1	32.94	34.0	34.0	34.0	32.0	34.0
...
```

##Output

qc_summary.sh creates a tab-separated value (TSV) file named qc_summary.tsv. Here is an example of its contents:

```
Base	sample1_1	sample1_2	sample2_1	sample2_2
1	32.94	32.90	33.01	33.25
```

## Variables

Prior to running qc_summary.sh, several variables require editing:

input_prefix='CB'

For example, let's say our inputs are named like:

CB9_KO_b-min_S9_R1_fastqc.zip
CB9_KO_b-min_S9_R2_fastqc.zip
CB10_KO_b-pos_S10_R1_fastqc.zip
CB10_KO_b-pos_S10_R2_fastqc.zip
CB11_PA01_a_S11_R1_fastqc.zip
CB11_PA01_a_S11_R2_fastqc.zip

In this case, CB is the correct prefix to use.

input_sort_key='1.3'

This ultimately effects the ordering of the samples in the output file. In our example above, we want to sort by the first three characters: CB followed by a number.
