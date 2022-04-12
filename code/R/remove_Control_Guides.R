#!/usr/bin/env Rscript
args=commandArgs(trailingOnly = T)

# Declare input file 
tempFileIn = args[1]

# Read data in
tempData = utils::read.table(tempFileIn, sep = "\t", stringsAsFactors = F, header = T)
# tempData = utils::read.table(text = gsub(",", "\t", readLines(tempFileIn)), stringsAsFactors = F, header =  T)

# Remove rows with control guides
tempData = tempData[!grepl("Neg_Control", tempData[,2]),]
tempData = tempData[!grepl("sgINTRON", tempData[,2]),]
tempData = tempData[!grepl("NegCtrl", tempData[,2]),]

# Declare output file 
tempFileOut = args[2]

# Write to file
write.table(tempData, tempFileOut, sep = "\t", col.names = T, quote = F, row.names = F)
