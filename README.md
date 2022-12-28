# janet-learning-WDL
notes on learning WDL/Cromwell

# Useful links

## Tutorials, documentation

[OpenWDL](https://openwdl.org) has links to tutorials

[Cromwell docs](https://cromwell.readthedocs.io/en/stable/) - Amy says some stuff there is out of date

Learning WDL [readthedocs](https://wdl-docs.readthedocs.io/en/stable/) (recommended by Amy Dec 2022)

[JSON format](https://en.wikipedia.org/wiki/JSON#Syntax)

More tutorials listed (here)(https://sciwiki.fredhutch.org/compdemos/Cromwell/#additional-wdl-resources)

## Hutch WDL tutorials (and other repos)

Starting a Cromwell server, using Shiny app, etc: [FH_WDL101](https://hutchdatascience.org/FH_WDL101_Cromwell/introduction.html) 

Hutch [Cromwell server configuration repo](https://github.com/FredHutch/diy-cromwell-server) (NOT intended for me to mess with). Used in cromwell.sh for server setup.

Amy's [example/test workflows](https://github.com/FredHutch/wdl-test-workflows/).  I have a clone that I edited for clarity, in `~/FH_fast_storage/cromwell-home/janet-learning-WDL/wdl-test-workflows`

## Hutch WDL-related links/locations

Shiny job submission/monitoring [dashboard](https://cromwellapp.fredhutch.org) 

My cromwell home dir: `~/FH_fast_storage/cromwell-home`

Cromwell scratch dir: `/fh/scratch/delete90/malik_h/jayoung`

My current Cromwell server details will be here: `~/FH_fast_storage/cromwell-home/README.md`


## Things to check out

[pipeline-builder](https://github.com/epam/pipeline-builder)  visualizes pipelines, maybe even creates WDL?

# My learning progress

I think I undertand how to run WDLs on our cluster: I worked through the [Hutch WDL101 course](https://hutchdatascience.org/FH_WDL101_Cromwell/index.html) in detail, providing lots of feedback

Next I need to learn WDL.  I got up to [here](https://wdl-docs.readthedocs.io/en/stable/WDL/Linear_chaining/) in the readthedocs tutorial

I'm starting to create my first real WDL (`~/FH_fast_storage/bat_reproduction/wdl_scripts/dnaseq_fq_to_vcf.wdl`)

# WDL-related habits I want to think about

How to handle copying output files out of scratch, given that directory structure is not what I'm used to. See how it looks once I get my bat-Orr-batch2 WDL running

Where to keep the wdl+jsons - I think IN the project repo.  One JSON per analysis batch?

How to split work - one giant WDL script, or break it up into separate ones?

Naming workflows - the name used in the WDL file's workflow block is used elsewhere too, e.g. it's what the output dir in /fh/scratch is called, and is found in the JSON input files. To me it makes sense to use the same name for the wdl script file, too. I probably want to try NOT to reuse the workflow block name in different projects, as the output dirs will get muddled up and they'll try to reuse each others' results.


# WDL syntax questions
- indents don't matter: is that correct?  is that true for WDL files AND json files?
- what's the syntax for the command block?  in places I see
```
command <<<

>>>
```
and in places I see 
```
command {

}
```

# Misc notes

VScode extensions: (installed these on my laptop but maybe not desktop)
- WDL DevTools 
- WDL syntax highlighter 
- Prettify Json 
- JSON Tools 

Inputs can be specified using JSON, but there's also a way to do it using tab-delim files - see [this example](https://github.com/FredHutch/wdl-test-workflows/tree/main/localBatchFileScatter)

Scattering over a map can be done - it is described [here](https://bioinformatics.stackexchange.com/questions/16100/extracting-wdl-map-keys-as-a-task) and [here](https://github.com/openwdl/wdl/issues/106#issuecomment-356047538). It may or may not be possible in v1.0 of WDL - there were some changes in v1.1.

Nested map structures might be possible, or might not - see [here](https://bioinformatics.stackexchange.com/questions/14673/reading-nested-map-data-structures-in-wdl)

JSON inputs: by testing, I THINK I figured out that it's OK to include a variable in the JSON file that's not used in the `struct` that I might use to declare the format of each input variable.  However, if I try to USE that variable it's not found, so I probably want to include it in struct. The variable names in `struct` DO need to match the names in the JSON, but they do NOT need to be in the same order.

JSON:  actual comments are not allowed, but we can use something like this to put in sneaky comments:`  "##_COMMENT1": "INPUT BAM",`

Merging two json files from the command line:
```
jq -s '.[0] * .[1]' file1 file2
```

Using source files that are links:  it seems like Cromwell follows the link through to its source and uses that filename instead. So my trick of using a link to make a SHORTER file alias is not useful

[Basename](https://wdl-docs.readthedocs.io/en/stable/WDL/basename/) function:
```
File input_file = "/Users/chris/input.bam"
String base = basename(input_file)
```
This produces `input.bam`
```
File input_file = "/Users/chris/input.bam"
String stripped = basename(input_file, ".bam") 
```
This produces the string `input`, which can then be combined with a new suffix 

For getting output files properly listed, if I don't know what they're called ahead of time, I may at some point need to use a trick involving glob - see [example](https://github.com/FredHutch/tg-wdl-cellRanger/blob/main/cellRanger.wdl): `Array[File] outputDir = glob("./countrun/outs/*")`


# Notes on conversations, tutorials, etc

## Video "Deciphering a mystery workflow written in WDL" (Broad)

[youtube video](https://terra.bio/deciphering-a-mystery-workflow-written-in-wdl/)

look for two things in the code: 
- workflow block (links the tasks)
- task block - contains 'command block'

womtools (a java script) can analyze a WDL and make a DOT file, and graphviz (online tool, or can install it) can visualize DOT files. In those graphs:
- ovals = call a task
- hexagon = operater (modify/control execution of task)
- boxes = scope of control/operator
- dashed lines = conditional (we don't always do it)
- arrows = input-to-output relationstip

can nest wdl files (workflows within workflows) and the graph can handle that.  Makes double-walled ovals for steps that are entire workflows


## Conversation with Amy Oct 14 2022

This was motivated by me trying to understand how to run the example workflows, and failing.

The Shiny app's 'validate workflow': useful!  Can validate with or without the input json files (use `cat` if there's >1 input json)

When submitting jobs via the Shiny app: order of input json files does not matter.

On the 'track jobs' tab of the shiny app, when a job is selected, the 'workflow specific job information' are shows the jobs spun off by the workflow.  

If the workflow entirely failed to run, then copy the workflow ID, go back to the 'submit jobs' tab, and put that ID into the 'troubleshoot workflow' box.  Work from the bottom up of that output to see where the errors were.

If the workflow did start running but did not complete, there may be some helpful info on which steps failed in that 'track jobs' tab, or it might be easier to go to the workflow output dir and look at the stderr etc files there

Broad uses the google cloud - some of their WDL files have a few google-specific things in them

If some tasks of a workflow fail, resubmit it and Cromwell SHOULD figure out which things to rerun and which to copy from before. Default we think is to make soft links? Cache or not?  

Hutch github - Amy's workflows all have 'wdl' in their name.  Amy also made a bunch of docker containers that are set up for common tasks - useful for reproducibility or for when I transition to using AWS.

Workflow options - see examples folder. E.g. caching or not.

Vocab:  when we scatter, each job is a 'shard'

In WDL code:   
`~{variable}` is a WDL variable (as opposed to a shell variable)

see 'Output copying' in [Cromwell docs](https://cromwell.readthedocs.io/en/stable/) for how to copy the files we want as final output from /fh/scratch to a specified place in /fh/fast

The workflow block has an `output` section at the end that specifies which files are final output.  Each task also has an `output` section.

## Conversation with Amy Dec 14 2022

### Rerunning tasks
When does cromwell decide to re-run a task?  
- it checks the last modified time and file path of any input files - if those have changed it will re-run.
- it checks the shell script that would be produced to run a task: if this differs at all from the previous run, we rerun it (even if the only difference is number of cores)
- if any upstream tasks changed, ALL downstream tasks will be rerun too.

It does NOT usually look at md5 checksums to really really make sure a file is identical.  There is a way to make it do that, but it makes everything very slow.


### Places to copy WDLs/tasks from:

Broad's [WARP repository](https://github.com/broadinstitute/warp): WDL Analysis Research Pipelines (WARP) repository is a collection of cloud-optimized pipelines for processing biological data from the Broad Institute Data Sciences Platform and collaborators.

[Dockstore](https://www.dockstore.org/search?descriptorType=WDL&entryType=workflows&searchMode=files)

Search the Hutch github repo with 'wdl'

### How to move/copy output files to a more sensible place. 

Several options: 
- Add a 'cp' task at the very end of the workflow
- Use the table of output file names I can get from the Shiny app (or via the fh.wdlR package) as input for a shell/perl/R script to copy files locally.
- Use the [workflow options json](https://cromwell.readthedocs.io/en/stable/wf_options/Overview/).   One of the many things I can do with this file is to specify a place to copy the final output files to.The usual behavior is to copy the whole crazy nested structure of the workflow directory - this guarantees we never overwrite files if they have the same names as one another.  There is some sort of option to un-nest, but you have to be very careful about file naming.  


### Tips for developing WDL code

Can run a task the first time without any output block. This is especially useful if we're running a program and we can't remember all the names of the output files.

WDL uses error codes returned by each task to determine completion.  Knowing that could help me figure out how to use error codes in my perl (etc) scripts to make the whole pipeline stop if there was an error.

Inputs:  Amy's wdl scripts tend to specify every single input file needed for a task, even if the command-line for the task only takes one of them. Example:  to map reads using `bwa`, we only need to specify the reference genome fasta file name, but bwa expects a bunch of index files to be present too.  If we are only ever running on /fh/fast it is unnecessary to specify all of those files, because cromwell does not need to copy the input files anywhere in order to get the task to run.  However, if we are running using docker and/or AWS, the files DO need to be copied over, so we DO need to specify every single one.

### Scattering tasks

Should be able to do a nested scatter (e.g. scatter over samples, then scatter each sample over regions)

In my case (bat SNP calling) I will want to hard-code the ~100 bed file names into a json file to specify them as inputs. Amy says it's unlikely I can use their sequential numbering to help me.

### Modularizing code

See example [here](https://github.com/theiagen/terra_utilities/blob/main/workflows/wf_cat_column.wdl)

Can put task code blocks in a separate file for reuse, and import. e.g.
```
import "../tasks/task_file_handling.wdl" as file_handling
```
after which a task called `cat_files` (found in `task_file_handling.wdl`) is available in the importing workflow via the name `file_handling.cat_files`
