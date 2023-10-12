#!/usr/bin/env Rscript
args=commandArgs(trailingOnly = T)

# Declare input file 
tempFileIn = args[1]

# Read data in
tempData = utils::read.table(tempFileIn, sep = "\t", stringsAsFactors = F, header = T)

# Identify targets that have more than the normal 4 guides per gene. Targets with a higher frequency of guides can produce unexpected STARS results.
freqCount = table(tempData[,2])
toRemove = names(freqCount)[freqCount>4]

# Remove rows with more guides than the normal 3-4 per-gene.
tempData = tempData[!tempData[,2] %in% toRemove,]

# Declare output file 
tempFileOut = args[2]

# Write to file
write.table(tempData, tempFileOut, sep = "\t", col.names = T, quote = F, row.names = F)
