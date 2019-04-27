#Alignment with STAR2
## STAR installation
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
sudo apt install rna-star

#1 chr22 indexing
cd ~/workdir/assignment/ngs2_assignment
mkdir $genomeDir
genomeDir=~/workdir/assignment/ngs2_assignment/chr22_with_ERCC92.fa
STAR --runMode genomeGenerate --genomeDir $genomeDir --chr22_with_ERCC92.fa\ --runThreadN 1

#2 alignment
runDir=/path/to/1pass
mkdir $runDir
cd $runDir
STAR --genomeDir $genomeDir --readFilesIn mate1.fq mate2.fq --runThreadN 1
