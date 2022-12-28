I want to dig in to understand Amy's example better

```
cd ~/FH_fast_storage/cromwell-home/janet-learning-WDL
git clone https://github.com/FredHutch/wdl-test-workflows
```

# WDL 1 helloHostname

SUPER simple.  One task, self-contained, doesn't even take inputs or make any files.

# WDL 2 hellloSingularityHostname

Same as above but adds instructions to use a container within the task. Again, super-simple.

# WDL 3 localBatchFileScatter

`sample.batchfile.tsv` is a TSV file with two rows (and a header). Each row contains 
- sample name
- bam file location (on /fh/fast)
- bed file location (on /fh/fast)

`parse.inputs.json` is a JSON file that simply defines `parseBatchFile.batchFile` to be the location of a tsv file (`/fh/fast/paguirigan_a/pub/ReferenceDataSets/workflow_testing_data/WDL/batchFileScatter/sample.batchfile.tsv`). It's actually a slightly different TSV file than the one included in the repo, as it points to S3 files not /fh/fast files.

`parseBatchFile.wdl` contains a workflow block named `parseBatchFile`. It uses a function to read the TSV file, scatter over each row to run a task (simple echo commands) and puts the output in stdout

# WDL 4 tg-wdl-VariantCaller

`variantCalling-batch.json` - defines `Panel_BWA_GATK4_Annovar.sampleBatch`. Sets up an array (using `[]`) of two items. Each of the two items contains three things: sample_name (a string), and two paths:  bamFile and bedFile.  This appears as `sampleBatch` in the WDL's workflow block: `Array[sampleInputs] sampleBatch`.   sampleInputs is defined further up in the WDL as a `struct` object - a data structure:
```
struct sampleInputs {
  String sample_name
  File bamFile
  File bedFile
}
```

`variantCalling-parameters.json` - defines `Panel_BWA_GATK4_Annovar.referenceGenome`. Lots of things including reference genome, SNP files, annovar files.

`variantCalling-workflow.wdl` - a complex workflow. 
Workflow block is named `Panel_BWA_GATK4_Annovar`


