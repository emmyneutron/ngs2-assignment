#Alignment with STAR2
## STAR installation
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
sudo apt install rna-star

#1- generate indexed genome for 1st pass alignment:
mkdir ~/workdir2/assignment/ngs2_assignment/genome && cd ~/workdir2/assignment/ngs2_assignment/genome
mkdir idx/
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir idx/ --genomeFastaFiles ~/workdir2/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
#2- Alignment jobs were executed as follows:
cd ~/workdir2/assignment/ngs2_assignment
mkdir runDir && cd runDir
STAR --runThreadN 1 --genomeDir ~/workdir2/assignment/ngs2_assignment/genome/idx --readFilesIn ~/workdir2/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_1.part_001.part_001.fastq ~/workdir2/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_2.part_001.part_001.fastq
#3- generate indexed genome for 2nd pass alignment:
mkdir ~/workdir2/assignment/ngs2_assignment/genome2 && cd ~/workdir2/assignment/ngs2_assignment/genome2
mkdir idy/
STAR --runMode genomeGenerate --genomeDir idy/ --genomeFastaFiles ~/workdir2/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa --sjdbFileChrStartEnd ~/workdir2/assignment/ngs2_assignment/runDir/SJ.out.tab --sjdbOverhang 75 --runThreadN 1

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


#4 Add read groups, sort, mark duplicates, and create index
# Install Picard tools
conda install -c bioconda picard 
picard_path=$CONDA_PREFIX/share/picard-2.19.0-0
sudo apt install picard-tools

java -jar picard.jar AddOrReplaceReadGroups I=star_output.sam O=rg_added_sorted.bam SO=coordinate RGID=id RGLB=library RGPL=platform RGPU=machine RGSM=sample 

java -jar picard.jar MarkDuplicates I=rg_added_sorted.bam O=dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics
