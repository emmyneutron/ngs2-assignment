#Alignment with STAR2
## STAR installation
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
sudo apt install rna-star

#1 chr22 indexing
cd ~/workdir/assignment/ngs2_assignment
mkdir $genomeDir
genomeDir=~/workdir/assignment/ngs2_assignment/genomeDir/GRCh38.primary_assembly.genome.fa
STAR --runMode genomeGenerate --genomeDir $genomeDir --genomeFastaFiles GRCh38.primary_assembly.genome.fa\ --runThreadN 1

#2 alignment

