#!/usr/bin/env Rscript
args=commandArgs(trailingOnly = T)

# Declare input file 
tempFileIn = args[1]

# Read data in
tempData = utils::read.table(tempFileIn, sep = "\t", stringsAsFactors = F, header = T)
# tempData = utils::read.table(text = gsub(",", "\t", readLines(tempFileIn)), stringsAsFactors = F, header =  T)

# identify which columns in data frame are numeric
theseCols = sapply(tempData, is.numeric)
theseCols = names(theseCols)[unname(theseCols) == T]

# Create output data file
tempDataA = tempData

# Divide by the total number of reads for that condition that matched a construct barcode found in a reference file
tempDataA[,theseCols] <- lapply(tempData[, theseCols], function(x) x/sum(x))

# Multiply by a constant factor of 1 million
tempDataA[,theseCols] = tempDataA[,theseCols]*1000000

# Declare output file 
tempFileOut = args[2]

# Write to file
write.table(tempDataA, tempFileOut, sep = "\t", col.names = T, quote = F, row.names = F)
