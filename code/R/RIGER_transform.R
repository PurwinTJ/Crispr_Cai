#!/usr/bin/env Rscript
args=commandArgs(trailingOnly = T)

# Declare input data file 
tempFileIn = args[1]

# Declare input chip file
tempFileIn2 = args[2]

# Read data in
tempData = utils::read.table(tempFileIn, sep = "\t", stringsAsFactors = F, header =  T)
rownames(tempData) = tempData[,1]

tempDataA = utils::read.table(tempFileIn2, sep = "\t", stringsAsFactors = F, header =  T)
rownames(tempDataA) = tempDataA[,1]

# Identify which columns in tempData are not present in tempDataA
namesAdd = colnames(tempData)[!colnames(tempData) %in% colnames(tempDataA)]

# Add columns data to tempDataA
tempDataA[,namesAdd] = tempData[rownames(tempDataA), namesAdd]

# Declare output file 
tempFileOut = args[3]

# Write to file
write.table(tempDataA, tempFileOut, sep = "\t", col.names = T, quote = F, row.names = F)
