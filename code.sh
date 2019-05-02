#Alignment with STAR2
## STAR installation
sudo apt-get update
sudo apt-get install g++
sudo apt-get install make
sudo apt install rna-star

#1- generate indexed genome for 1st pass alignment:
mkdir ~/workdir/assignment/ngs2_assignment/genome && cd ~/workdir/assignment/ngs2_assignment/genome
mkdir idx/
STAR --runThreadN 1 --runMode genomeGenerate --genomeDir idx/ --genomeFastaFiles ~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
# Alignment jobs were executed as follows:
cd ~/workdir2/assignment/ngs2_assignment
mkdir runDir && cd runDir
STAR --runThreadN 1 --genomeDir ~/workdir/assignment/ngs2_assignment/genome/idx --readFilesIn ~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_1.part_001.part_001.fastq ~/workdir2/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_2.part_001.part_001.fastq
# generate indexed genome for 2nd pass alignment:
mkdir ~/workdir/assignment/ngs2_assignment/genome2 && cd ~/workdir/assignment/ngs2_assignment/genome2
mkdir idy/
STAR --runMode genomeGenerate --genomeDir idy/ --genomeFastaFiles ~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa --sjdbFileChrStartEnd ~/workdir/assignment/ngs2_assignment/runDir/SJ.out.tab --sjdbOverhang 75 --runThreadN 1
# final alignment
cd ~/workdir/assignment/ngs2_assignment
mkdir runDir2 && cd runDir2
STAR --runThreadN 1 --genomeDir ~/workdir/assignment/ngs2_assignment/genome2/idy --readFilesIn ~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_1.part_001.part_001.fastq ~/workdir/assignment/ngs2_assignment/sample_data/ngs2-assignment-data/SRR8797509_2.part_001.part_001.fastq

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

cd ~/workdir/assignment/ngs2_assignment/runDir2
picard-tools AddOrReplaceReadGroups I=Aligned.out.sam O=rg_added_sorted.bam SO=coordinate RGID=4 RGLB=lib1 RGPL=illumina RGPU=unit1 RGSM=20
picard-tools MarkDuplicates I=rg_added_sorted.bam O=dedupped.bam  CREATE_INDEX=true VALIDATION_STRINGENCY=SILENT M=output.metrics  

#Install GATK
conda install -c bioconda gatk4
#5 Split'N'Trim and reassign mapping qualities
cd ~/workdir/assignment/ngs2_assignment/sample_data
samtools fqidx chr22_with_ERCC92.fa
gatk CreateSequenceDictionary -R chr22_with_ERCC92.fa -O chr22_with_ERCC92.dict
cd ~/workdir/assignment/ngs2_assignment
mkdir split && cd split 
GenomeFasta=~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
gatk SplitNCigarReads -R $GenomeFasta -I ~/workdir/assignment/ngs2_assignment/runDir2/dedupped.bam -O split.bam

#6 Downloading known variants
cd ~/workdir/assignment/ngs2_assignment/sample_data
wget ftp://ftp.ensembl.org/pub/release-96/variation/vcf/homo_sapiens/homo_sapiens-chr22.vcf.gz
gunzip homo_sapiens-chr22.vcf.gz

grep "^#" homo_sapiens-chr22.vcf > homo_sapiens-chr22_fam.vcf
grep "^22" homo_sapiens-chr22.vcf | sed 's/^22/chr22/' >> homo_sapiens-chr22_fam.vcf
gatk IndexFeatureFile -F homo_sapiens-chr22_fam.vcf

#7 Base Recalibration by GATK  
cd ~/workdir/assignment/ngs2_assignment
mkdir BaseRecalibrate && cd BaseRecalibrate
GenomeFasta=~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
gatk --java-options "-Xmx2G" BaseRecalibrator -R $GenomeFasta -I ~/workdir/assignment/ngs2_assignment/runDir2/dedupped.bam -knownSites ~/workdir/assignment/ngs2_assignment/sample_data/homo_sapiens-chr22_fam.vcf -O recal_data.table

#8 Variant calling
cd ~/workdir/assignment/ngs2_assignment
mkdir Vcall && Vcall 
GATK=~/miniconda3/envs/ngs1/share/gatk4-4.1.2.0-0/gatk-package-4.1.2.0-local.jar
GenomeFasta=~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
java -jar $GATK -T HaplotypeCaller -R $GenomeFasta -I input.bam -dontUseSoftClippedBases -stand_call_conf 20.0 -o output.vcf 


#9 Variant filtering
cd ~/workdir/assignment/ngs2_assignment
mkdir Vcall && Vcall 
GATK=~/miniconda3/envs/ngs1/share/gatk4-4.1.2.0-0/gatk-package-4.1.2.0-local.jar
GenomeFasta= ~/workdir/assignment/ngs2_assignment/sample_data/chr22_with_ERCC92.fa
java -jar $GATK -T VariantFiltration -R $GenomeFasta -V input.vcf -window 35 -cluster 3 -filterName FS -filter "FS > 30.0" -filterName QD -filter "QD < 2.0" -o output.vcf                  
