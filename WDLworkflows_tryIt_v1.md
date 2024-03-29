# Notes

## set up first jobStore MariaDB database October 2022

Trying the original instructions for a [diy-cromwell-server](https://github.com/FredHutch/diy-cromwell-server).  As of Nov 2022, [newer (better?) instructions](https://hutchdatascience.org/FH_WDL101_Cromwell/introduction.html) exist - see [WDLworkflows_tryIt_v2.md](janets_NOTES_forMyself/WDLworkflows_tryIt_v2.md).

A one time only thing: I first create a database to store info from my cromwell server

I use the Hutch [DB4SCI interface](https://mydb.fredhutch.org/index) described [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb) and I select these:
  - create DB container (MariaDB 10.3)
  - backup frequency = never
  - database name = jayoungWDL
  - user name = jayoung
  - password  

Result:
```
Your MariaDB container has been created. Container name: jayoungWDL

Use mysql command line tools to access your new MariaDB.
mysql --host mydb --port 32281 --user jayoung --password

Leave the password argument blank. You will be prompted to enter the password.
```

```
cd ~/FH_fast_storage/cromwell-home
module purge
module load MariaDB/10.5.1-foss-2019b
mysql --host mydb --port 32281 --user jayoung --password
   # and from the MariaDB prompt:
create database jayoungWDL;
   # I think it worked?  I got this message:
   # Query OK, 1 row affected (0.001 sec)
```



## set up second jobStore MariaDB database March 16 2023

I was having some trouble running a workflow, and wondered if a new small MariaDB would be a good idea

I use the Hutch [DB4SCI interface](https://mydb.fredhutch.org/index) described [here](https://sciwiki.fredhutch.org/scicomputing/store_databases/#db4sci--previously-mydb) and I select these:
  - create DB container (MariaDB 10.3)
  - backup frequency = never
  - database name = jayoungWDL_v2
  - user name = jayoung
  - password (see cromUserConfig.txt)

Result:
```
Your MariaDB container has been created. Container name: jayoungWDL_v2

Use mysql command line tools to access your new MariaDB.
mysql --host mydb --port 32297 --user jayoung --password

Leave the password argument blank. You will be prompted to enter the password.
```

```
cd ~/FH_fast_storage/cromwell-home
module purge
module load MariaDB/10.5.1-foss-2019b
mysql --host mydb --port 32297 --user jayoung --password
   # and from the MariaDB prompt:
create database jayoungWDL_v2;
   #  got this message:
   # Query OK, 1 row affected (0.001 sec)
```

## setting up a cromwell server using that MariaDB jobStore database

(I have since deleted this git clone and made a new one)
```
cd ~/FH_fast_storage/cromwell-home

git clone --branch main https://github.com/FredHutch/diy-cromwell-server.git

# make a template config file:
cp ./diy-cromwell-server/cromUserConfig.txt .
    # and edit
```

Make sure cromUserConfig.txt points towards the correct database (`jayoungWDL` or `jayoungWDL_v2`) and has the corresponding port.

```
cd ~/FH_fast_storage/cromwell-home
cp ./diy-cromwell-server/cromwellv1.3.1.sh .
```

try it!
```
./cromwellv1.3.1.sh cromUserConfig.txt
```

it's doing something:
```
Your configuration details have been found...
Getting an updated copy of Cromwell configs from GitHub...
Note: checking out '2caab425f5204db17f354ec0b7caf7cd257eed91'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

Setting up all required directories...
Detecting existence of AWS credentials...
Credentials found, setting appropriate configuration...
Requesting resources from SLURM for your server...
Submitted batch job 66547493
Your Cromwell server is attempting to start up on node/port gizmoj17:33241.  If you encounter errors, you may want to check your server logs at /fh/fast/malik_h/user/jayoung/cromwell-home/server-logs to see if Cromwell was unable to start up.
Go have fun now.
```
and there's a slurm job running:
```
          66547493 campus-ne cromwell  jayoung  R       0:31      1 gizmoj17
```

Now I can use this [dashboard](https://cromwellapp.fredhutch.org) to monitor my jobs, clicking 'connect to server' and giving it this `gizmoj17:33241`

Then I go to the submit tab, and specify the WDL and json files.

I try running through the [tests here](https://github.com/FredHutch/diy-cromwell-server/tree/main/testWorkflows) - the WDL files are in the github repo I cloned and I submit each through that web server


# restarting my cromwell server

The next day, my cromwell server is no longer running. 

there is a file called `hs_err_pid32330.log` that tells me 'There is insufficient memory for the Java Runtime Environment to continue.'

there is also a file `server-logs/cromwell_66547493.out` that also hints at failure due to memory

start it up the cromwell server again:
```
./cromwellv1.3.1.sh cromUserConfig.txt
    # gizmok122:46707
    # sbatch id = 66598133
```


# test 1 - helloHostname/helloHostname.wdl

I think the output went here: `/fh/scratch/delete90/malik_h/jayoung/cromwell-executions/hello_hostname/906702e4-3864-4301-bbce-cf22f15977d2/call-hostname/execution/stdout`

# test 2 localBatchFileScatter/parseBatchFile.wdl

Again, submit via web interface. 

The first time I only gave it the WDL file (`parseBatchFile.wdl`) and it failed. 

The second time I also gave it the json file too (`parse.inputs.json`) and it worked. Spun off a couple of sbatch jobs, with 'cromwell' as the job name

Results?  a bunch of stuff appeared in `/fh/scratch/delete90/malik_h/jayoung/cromwell-executions/parseBatchFile/`
(subdir beb51552-99a5-49e8-b93b-d53e57ee8b2c/call-test/)

# test 3 tg-wdl-VariantCaller 

This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow.

xxx I can't get this one to work. shiny app says it fails, and I can't obviously see any output files at all, or log files.


# test 4 helloSingularityHostname 

This workflow does the same as above but does it with the ubuntu:latest docker container, via Singularity under the hood.

# test 5 tg-wdl-VariantCaller-docker 

This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers instead of environment modules.

# test 6 s3batchFileScatter 

This workflow will test access to a publicly available file in an S3 bucket available to all Fred Hutch users, the ability of the Cromwell server to parse that file and kick off a scatter of parallel jobs.

# test 7 tg-wdl-VariantCaller-S3 

This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using environment modules and also input files from S3.

# test 8 tg-wdl-VariantCaller-docker-S3 

This workflow tests whether a Cromwell server can do a multi-step, scientifically relevant mini-workflow using docker containers and also input files from S3.

