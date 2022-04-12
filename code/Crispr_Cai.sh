#!/bin/bash

function usage() {
  echo "Usage: $0 [-d directory] [-drs directory-R-scripts] [-dss directory-STARS-script] [-prrea row-reads] [-pcrea col-reads] [-prref row-reference] [-pcref col-reference] [-prbp row-barcode-policy] [-pcbp col-barcode-policy] [-prm row-matcher] [-pcm col-matcher] [-scf chip-file] [-st thr] [-sni num-ite] [-sufp use-first-pert]"
  echo "  -d|--directory                 main output directory"
  echo "  -drs|--directory-R-scripts     directory with R scripts"
  echo "  -dss|--directory-STARS-scripts directory with STARS scripts"
  echo "  -prrea|--row-reads             fastq.gz R1 file with CRISPR sequencing data"
  echo "  -pcrea|--col-reads             fastq.gz I1 file with sample barcode data"
  echo "  -prref|--row-reference         CRISPR reference sequences. Usually barcodes matching an indexed gene name (ie TP53_1, TP53_2)"
  echo "  -pcref|--col-reference         sample reference sequences" 
  echo "  -prbp|--row-barcode-policy     poolQ row barcode policy"
  echo "  -pcbp|--col-barcode-policy     poolQ column barcode policy"
  echo "  -prm|--row-matcher             poolQ allow for a mismatch or perfect match only, for row barcodes. exact or mismatch"
  echo "  -pcm|--col-matcher             poolQ allow for a mismatch or perfect match only, for column barcodes. exact or mismatch"
  echo "  -scf|--chip-file               path to file with sg sequences annotated with gene names. Usually 4 sequences matching 1 gene"
  echo "  -st|--thr                      top percent of perturbations that a STARS score will be calculated"
  echo "  -sni|--num-ite                 number of iterations to generate the null distribution"
  echo "  -sufp|--use-first-pert         whether if to use the top (a single) perturbation can represent a gene. Otherwise, use at least two. Y or N"
  echo ""
  echo "Example: $0 --number-of-people 2 --section-id 1 --cache-file last-known-date.txt"
}

while [[ "$#" -gt 0 ]]; do
  case $1 in
    -d|--directory) MAINDIR="$2"; shift ;;
    -drs|--directory-R-scripts) RSCRIPTDIR="$2"; shift ;;
    -dss|--directory-STARS-scripts) STARSSCRIPTDIR="$2"; shift ;;
    -prrea|--row-reads) R1FQFILE="$2"; shift ;;
    -pcrea|--col-reads) I1FQFILE="$2"; shift ;;
    -prref|--row-reference) SGMETA="$2"; shift ;;
    -pcref|--col-reference) SAMPLEMETA="$2"; shift ;;
    -prbp|--row-barcode-policy) ROWBARCODEPOLICY="$2"; shift ;;
    -pcbp|--col-barcode-policy) COLBARCODEPOLICY="$2"; shift ;;
    -prm|--row-matcher) ROWMATCHER="$2"; shift ;;
    -pcm|--col-matcher) COLMATCHER="$2"; shift ;;
    -scf|--chip-file) SCHIPFILE="$2"; shift ;;
    -st|--thr) THRESHOLDPCT="$2"; shift ;;
    -sni|--num-ite) ITERATIONS="$2"; shift ;;
    -sufp|--use-first-pert) USEFIRSTPERT="$2"; shift ;;
    *) echo "Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done


# Create string with current date and time
DATESTR="`date '+%Y%m%d.%H%M%S'`"

mkdir -p $MAINDIR/$DATESTR/

# Run log
LOGFILE=$MAINDIR/$DATESTR/"CRISPR_Screen_$DATESTR.log"

# Create empty log file
:> $LOGFILE

# Add inputs to log file
echo "MAINDIR=$MAINDIR" >> $LOGFILE
echo "RSCRIPTDIR=$RSCRIPTDIR" >> $LOGFILE
echo "STARSSCRIPTDIR=$STARSSCRIPTDIR" >> $LOGFILE
echo "R1FQFILE=$R1FQFILE" >> $LOGFILE
echo "I1FQFILE=$I1FQFILE" >> $LOGFILE
echo "SGMETA=$SGMETA" >> $LOGFILE
echo "SAMPLEMETA=$SAMPLEMETA" >> $LOGFILE
echo "ROWBARCODEPOLICY=$ROWBARCODEPOLICY" >> $LOGFILE
echo "COLBARCODEPOLICY=$COLBARCODEPOLICY" >> $LOGFILE
echo "ROWMATCHER=$ROWMATCHER" >> $LOGFILE
echo "COLMATCHER=$COLMATCHER" >> $LOGFILE
echo "SCHIPFILE=$SCHIPFILE" >> $LOGFILE
echo "THRESHOLDPCT=$THRESHOLDPCT" >> $LOGFILE
echo "ITERATIONS=$ITERATIONS" >> $LOGFILE
echo "USEFIRSTPERT=$USEFIRSTPERT" >> $LOGFILE

# Set output PoolQ directory
POOLQDIR=$MAINDIR/$DATESTR/PoolQ
mkdir -p $POOLQDIR


# Out file names and etc
QUALITYOUTFILE=$POOLQDIR/qual.txt
SCORESOUTFILE=$POOLQDIR/scores.txt
LOG2NORMALIZEDSCORESOUTFILE=$POOLQDIR/log2normalizedScores.txt
BARCODESSCORESOUTFILE=$POOLQDIR/barcodeScores.txt
CORRELATIONOUTFILE=$POOLQDIR/correlation.txt
UNEXPECTEDSEQOUTFILE=$POOLQDIR/unexpectedSequences.txt
UNEXPECTEDSEQOUTDIR=$POOLQDIR/unexpectedSequencesDir

NORMALIZEDSCORESOUTFILE=$POOLQDIR/normalizedScores_CPM.txt

TEMPNOCONTROLGUIDES=$POOLQDIR/scores.noControlGuides.txt
NORMSCORESNOCTRLGUIDESOUTFILE=$POOLQDIR/scores_noControlGuides_CPM.txt


cd $POOLQDIR

poolq3.sh --row-reads $R1FQFILE --col-reads $I1FQFILE --row-reference $SGMETA --col-reference $SAMPLEMETA --row-barcode-policy $ROWBARCODEPOLICY --col-barcode-policy $COLBARCODEPOLICY --row-matcher $ROWMATCHER --col-matcher $COLMATCHER --quality $QUALITYOUTFILE --scores $SCORESOUTFILE --normalized-scores $LOG2NORMALIZEDSCORESOUTFILE --barcode-scores $BARCODESSCORESOUTFILE --correlation $CORRELATIONOUTFILE --unexpected-sequence-cache $UNEXPECTEDSEQOUTDIR --unexpected-sequences $UNEXPECTEDSEQOUTFILE

# Log stuff
echo "ROWBARCODEPOLICY = $ROWBARCODEPOLICY" >> $LOGFILE
echo "COLBARCODEPOLICY = $COLBARCODEPOLICY" >> $LOGFILE

echo "poolq3.sh --row-reads $R1FQFILE --col-reads $I1FQFILE --row-reference $SGMETA --col-reference $SAMPLEMETA --row-barcode-policy $ROWBARCODEPOLICY --col-barcode-policy $COLBARCODEPOLICY --row-matcher $ROWMATCHER --col-matcher $COLMATCHER --quality $QUALITYOUTFILE --scores $SCORESOUTFILE --normalized-scores $LOG2NORMALIZEDSCORESOUTFILE --barcode-scores $BARCODESSCORESOUTFILE --correlation $CORRELATIONOUTFILE --unexpected-sequence-cache $UNEXPECTEDSEQOUTDIR --unexpected-sequences $UNEXPECTEDSEQOUTFILE" >> $LOGFILE

# Add PoolQ's log file to script's log file
cat $POOLQDIR/poolq3.log >> $LOGFILE

echo " " >> $LOGFILE

echo " " >> $LOGFILE
echo "Normalize scores with control guides" >> $LOGFILE
# Create linear normalized counts data (counts per million) file
Rscript $RSCRIPTDIR/normalize_Poolq.R $SCORESOUTFILE $NORMALIZEDSCORESOUTFILE

# echo "Scores CPM-normalized. Includes control guides." >> $LOGFILE
echo "Rscript $RSCRIPTDIR/normalize_Poolq.R $SCORESOUTFILE $NORMALIZEDSCORESOUTFILE" >> $LOGFILE
echo " " >> $LOGFILE


echo " " >> $LOGFILE
echo "Normalize scores after removing control guides" >> $LOGFILE

# Remove control guides prior to normalizing
Rscript $RSCRIPTDIR/remove_Control_Guides.R $SCORESOUTFILE $TEMPNOCONTROLGUIDES

# Create linear normalized counts data (counts per million) file
Rscript $RSCRIPTDIR/normalize_Poolq.R $TEMPNOCONTROLGUIDES $NORMSCORESNOCTRLGUIDESOUTFILE

rm -f $TEMPNOCONTROLGUIDES

# echo "Remove control guides, then normalize scores to CPM." >> $LOGFILE
echo "Rscript $RSCRIPTDIR/remove_Control_Guides.R $SCORESOUTFILE $TEMPNOCONTROLGUIDES" >> $LOGFILE
echo "Rscript $RSCRIPTDIR/normalize_Poolq.R $TEMPNOCONTROLGUIDES $NORMSCORESNOCTRLGUIDESOUTFILE" >> $LOGFILE
echo " " >> $LOGFILE



# STARS
echo " " >> $LOGFILE
echo "STARS : version 1.3" >> $LOGFILE

# PoolQ output file with normalized score values (without dir path)
TEMPSCORESFILE=scores_noControlGuides_CPM.txt


# New STARS output directory
STARSDIR=$MAINDIR/$DATESTR/STARS

# Make directory and set to current directory, since no input option available to set the results output directory
mkdir -p $STARSDIR
# cd $STARSDIR

# Make STARS-specific input file
SCORESFILE2=$STARSDIR/pre_STARSinput.$TEMPSCORESFILE
SCORESFILE=$STARSDIR/STARSinput.$TEMPSCORESFILE

# Remove the second column from the PoolQ output
awk -F'[\t]' -v OFS="\t" '{$2=""; print $0}' $POOLQDIR/$TEMPSCORESFILE > $SCORESFILE2
sed 's/\t\t/\t/g' $SCORESFILE2 > $SCORESFILE

rm -f $SCORESFILE2

# Create chip file without control guides
CHIPFILE="$(dirname $SCHIPFILE)/STARS_chip_noControlGuides.txt"
Rscript $RSCRIPTDIR/remove_Control_Guides.R $SCHIPFILE $CHIPFILE


echo " " >> $LOGFILE
# Add info to log file
echo "STARSDIR = $STARSDIR" >> $LOGFILE
echo "SCORESFILE = $SCORESFILE" >> $LOGFILE
echo "CHIPFILE = $CHIPFILE" >> $LOGFILE
echo "SCHIPFILE = $SCHIPFILE" >> $LOGFILE

echo "THRESHOLDPCT = $THRESHOLDPCT"  >> $LOGFILE
echo "ITERATIONS = $ITERATIONS" >> $LOGFILE
echo "USEFIRSTPERT = $USEFIRSTPERT" >> $LOGFILE

echo " " >> $LOGFILE
echo "Remove control guides from chip file" >> $LOGFILE
echo "Rscript ~/data/crispr_weijia/remove_Control_Guides.R $SCHIPFILE $CHIPFILE" >> $LOGFILE

# STARSNULL=$STARSSCRIPTDIR/stars_null_v1.3.py
# STARSRUN=$STARSSCRIPTDIR/stars_v1.3.py

# 2to3 -n -w $STARSSCRIPTDIR/stars_null_v1.3.py -o $STARSSCRIPTDIR/py3
# 2to3 -n -w $STARSSCRIPTDIR/stars_v1.3.py -o $STARSSCRIPTDIR/py3
STARSNULL3=$STARSSCRIPTDIR/stars_null_v1.3.py
STARSRUN3=$STARSSCRIPTDIR/stars_v1.3.py

# No option for output directory of STARS files, so make STARS output directory the current directory 
cd $STARSDIR

# Generate null dist file for negatively enriched genes
python $STARSNULL3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --num-ite $ITERATIONS --use-first-pert $USEFIRSTPERT --dir N


# rename null dist file to have directional info 
mv -T $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'.txt' $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'N.txt'

# Generate null dist file for positively enriched genes
python $STARSNULL3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --num-ite $ITERATIONS --use-first-pert $USEFIRSTPERT --dir P

# rename null dist file to have directional info 
mv -T $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'.txt' $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'P.txt'


# Run STARS for each direction
# python $STARSRUN --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir N --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'N.txt' --use-first-pert $USEFIRSTPERT
# python $STARSRUN --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir P --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'P.txt' --use-first-pert $USEFIRSTPERT

python $STARSRUN3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir N --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'N.txt' --use-first-pert $USEFIRSTPERT
python $STARSRUN3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir P --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'P.txt' --use-first-pert $USEFIRSTPERT


# Add info to log file

echo " " >> $LOGFILE
echo "python $STARSNULL3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --num-ite $ITERATIONS --use-first-pert $USEFIRSTPERT --dir N" >> $LOGFILE
echo "python $STARSNULL3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --num-ite $ITERATIONS --use-first-pert $USEFIRSTPERT --dir P" >> $LOGFILE

echo "python $STARSRUN3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir N --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'N.txt' --use-first-pert $USEFIRSTPERT" >> $LOGFILE
echo "python $STARSRUN3 --input-file $SCORESFILE --chip-file $CHIPFILE --thr $THRESHOLDPCT --dir P --null $STARSDIR/Null_STARSOutput8_$THRESHOLDPCT'P.txt' --use-first-pert $USEFIRSTPERT" >> $LOGFILE
echo " " >> $LOGFILE


# RIGER 
echo " " >> $LOGFILE
echo "RIGER :" >> $LOGFILE

# Directory with stars_null_v1.3.Dir.py and stars_v1.3.py
RIGERDIR=$MAINDIR/$DATESTR/RIGER

# Make directory and set to current directory, since no input option available to set the results output directory
mkdir -p $RIGERDIR
cd $RIGERDIR

# Declare RIGER out file
RIGERFILE=$RIGERDIR/normalizedScores_noControlGuides_CPM_RIGER.txt

# Create RIGER out file
Rscript $RSCRIPTDIR/RIGER_transform.R $NORMSCORESNOCTRLGUIDESOUTFILE $CHIPFILE $RIGERFILE


# Add info to file
echo "RIGERFILE = $RIGERDIR/normalizedScores_CPM_RIGER.txt" >> $LOGFILE
echo "Rscript $RSCRIPTDIR/RIGER_transform.R $NORMSCORESNOCTRLGUIDESOUTFILE $CHIPFILE $RIGERFILE" >> $LOGFILE
