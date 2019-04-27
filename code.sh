#Alignment with STAR2
## STAR installation
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
sudo apt install rna-star

#1 chr22 indexing
mkdir ~/workdir/assignment/ngs2_assignment/genome && cd ~/workdir/assignment/ngs2_assignment/genome
mkdir idx/
#STAR --runThreadN 1 --runMode genomeGenerate --genomeDir idx/ --genomeFastaFiles GRCh38.primary_assembly.genome.fa ##core dumped
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir idx/ --genomeFastaFiles chr22_with_ERCC92.fa

#2 data preparation
mkdir ~/workdir/assignment/ngs2_assignment/sample_data && cd ~/workdir/assignment/ngs2_assignment/sample_data
wget https://ufile.io/kc0qqbvd #download it directly from the website
unzip ngs2-assignment-data.zip|ls
cd ngs2-assignment-data/
ls
gunzip SRR8797509*.fastq.gz
ls
cd ..
#mate1=~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_1.part_001.part_001.fastq.
#mate2=~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_2.part_001.part_001.fastq.

#3 alignment
cd ..
mkdir runDir && cd runDir
STAR --runThreadN 1 --genomeDir ~/workdir/assignment/ngs2_assignment/genome/idx --readFilesIn ~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_1.part_001.part_001.fastq ~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_2.part_001.part_001.fastq

#4 Add read groups, sort, mark duplicates, and create index
java -jar picard.jar AddOrReplaceReadGroups I=star_output.sam O=rg_added_sorted.bam SO=coordinate RGID=id RGLB=library RGPL=platform RGPU=machine RGSM=sample 

java -jar picard.jar MarkDuplicates I=rg_added_sorted.bam O=dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics
