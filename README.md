# Crispr_Cai

Code that takes CRISPR sgRNA (or other screening) fastq files and:
1) Gets counts per condition using PoolQ v3
2) Normalizes the data to counts per million
3) Performs STARS v1.3 for each sample
4) Generate RIGER-ready normalized data files

The control guides are removed before normalizing and running STARS, but are present in the intermediate files. Intermediate files are kept for users to perform quality control checks. 

PoolQ can be downloaded from:
https://portals.broadinstitute.org/gpp/public/software/poolq <br/>
PoolQ v3 Requires JRE version 8 or higher

STARS can be downloaded from:
https://portals.broadinstitute.org/gpp/public/software/STARS 

RIGER is an extension of GENE-E, and can be downloaded from:
https://software.broadinstitute.org/GENE-E/extensions.html

STARS was written in python 2.7 but works for python 3.x after converting it via python's "built-in automated 2 to 3 code translator" (python 2to3 filename.py). <br/>
python 2to3 /path/to/STARS/stars_null_v1.3.py <br/>
python 2to3 /path/to/STARS/stars_v1.3.py
