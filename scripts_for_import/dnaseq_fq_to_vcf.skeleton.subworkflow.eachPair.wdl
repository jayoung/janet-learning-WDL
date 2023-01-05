version 1.0

struct commonInputsStruct {
  File fastqcContaminants
  Int fastqcThreads
  Int bwaThreads
  Int deeptoolsThreads
  String refGenomeBWA_dir
  String refGenomeBWA_fasta
  String refGenomeBWA_amb
  String refGenomeBWA_ann
  String refGenomeBWA_bwt
  String refGenomeBWA_pac
  String refGenomeBWA_sa
  File refGenome_lengths
}

workflow eachPair {
    input {
        Array[String] pairs
        Map[String, Map[String,File]] pairsToFq
        commonInputsStruct commonInputs
        ### add file path to the ref genome files
        String ref_fasta_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_fasta
        String ref_amb_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_amb
        String ref_ann_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_ann
        String ref_bwt_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_bwt
        String ref_pac_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_pac
        String ref_sa_path = commonInputs.refGenomeBWA_dir + "/" + commonInputs.refGenomeBWA_sa
    }
    #### scatter over each fastq pair
    scatter (thisPair in pairs) {

      ## fastqc - the task runs fastqc on R1 and R2 separately
      Array[String] bothDirections = ["R1","R2"]
      scatter(thisDirection in bothDirections) {
        call runFastqc {
          input: 
            pairName = thisPair,
            directionName = thisDirection,
            fastqFile = pairsToFq[thisPair][thisDirection],
            contam = commonInputs.fastqcContaminants,
            threads = commonInputs.fastqcThreads
        }
      } # end of scatter over bothDirections

      ## bwa using the pair
      call runBWA {
        input:
          pairName = thisPair,
          fastqFile_R1 = pairsToFq[thisPair]["R1"],
          fastqFile_R2 = pairsToFq[thisPair]["R2"],
          threads = commonInputs.bwaThreads,
          ref_fasta = ref_fasta_path,
          ref_amb = ref_amb_path,
          ref_ann = ref_ann_path,
          ref_bwt = ref_bwt_path,
          ref_pac = ref_pac_path,
          ref_sa = ref_sa_path
      }
      
    } # end of scatter over fastq pairs
    output {
        # fastqc output
        #Array[File] fastqcDirs = flatten(flatten(runFastqc.fastqcOutputDir))
        Array[File] fastqcDirs = flatten(runFastqc.fastqcOutputDir)

        # bam files each sample after merging pairs
        Array[File] bams = runBWA.bam
        Array[File] bamIndices = runBWA.bamIndex
        Array[File] bamFlagstats = runBWA.flagstats
    }
}


########### tasks:

task runFastqc {
  input {
    String pairName
    String directionName
    File fastqFile
    File contam
    Int threads
    String outDir = "~{pairName}.~{directionName}.fastqc_output"
  }
  command <<<
    mkdir ~{outDir}
    # fastqc --outdir ~{outDir} --format fastq --threads ~{threads} --contaminants ~{contam} ~{fastqFile}
    echo "fastqc command: fastqc --outdir ~{outDir} --format fastq --threads ~{threads} --contaminants ~{contam} ~{fastqFile}" > ~{outDir}/fastqc_out.txt

  >>>
  # runtime {
  #   modules: "FastQC/0.11.9-Java-11"
  #   cpu: threads
  # }
  output {
    File fastqcOutputDir = outDir
  }
}



task runBWA {
  input {
    String pairName
    File fastqFile_R1
    File fastqFile_R2
    Int threads
    File ref_fasta
    File ref_amb
    File ref_ann
    File ref_bwt
    File ref_pac
    File ref_sa   
  }
  command <<<
    echo "(bwa mem -t ~{threads} ~{ref_fasta} ~{fastqFile_R1} ~{fastqFile_R2} | samtools view -@ ~{threads} -Sb - | samtools sort -@ 4 -O bam > ~{pairName}.bwa.bam ) 2>> ~{pairName}.bwa.log.txt" > ~{pairName}.bwa.bam
    echo "(bwa mem -t ~{threads} ~{ref_fasta} ~{fastqFile_R1} ~{fastqFile_R2} | samtools view -@ ~{threads} -Sb - | samtools sort -@ 4 -O bam > ~{pairName}.bwa.bam ) 2>> ~{pairName}.bwa.log.txt" > ~{pairName}.bwa.log.txt
    #echo "samtools index ~{pairName}.bwa.bam" > 
    echo "samtools flagstat ~{pairName}.bwa.bam > ~{pairName}.bwa.bam.flagstats" > ~{pairName}.bwa.bam.flagstats
  >>>
  runtime {
    #modules: "SAMtools/1.11-GCC-10.2.0 BWA/0.7.17-GCC-10.2.0"
    cpu: threads
  }
  output {
    File bam = "~{pairName}.bwa.bam"
    File bamIndex = "~{pairName}.bwa.bai"
    File bwaLogFile = "~{pairName}.bwa.log.txt"
    File flagstats = "~{pairName}.bwa.bam.flagstats"
  }
}
