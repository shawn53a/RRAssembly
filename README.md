# RRAssembly
Shawn Arreguin

## What this does:
This is a personal script that I use to download raw reads from the SRA and assemble them.

There are three main steps:
1. Download and preprocess reads
    * Reads are preprocessed using the Semblans preprocess tool
       * Reads are run through Rcorrector and Trimmomatic 
2. Separate contamination, chloroplast, mitochondrial, and nuclear reads
    * Preprocessed reads are run through kraken several times
        * First, bacterial reads are filtered out using the STD_PF database
        * Second, chloroplast reads are filtered out using a plastid database
        * Third, mitochondrial reads are filtered out using a mitochondiral database
        * The remaning reads are used as the nuclear reads
3. Assemble reads
    * Chloroplast, mitochondrial, and nuclear reads are each run through the Semblans assemble and postprocess functions
