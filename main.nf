#!/usr/bin/env nextflow

//use dsl2 to support modules.
nextflow.preview.dsl=2


//Step 1: create some data and pass it to Step 2.
//This is a notebook in R
process run_step01 {
    conda "envs/step01.yml"
    echo true

    input:
        file 'notebook.Rmd'

    output:
        file "iris.tsv"
        file "report.html"

    publishDir "results/01_generate_data"

    """
    render_rmd.py notebook.Rmd \
        report.html \
        --cpus=${task.cpus} \
        --params="out_file=iris.tsv"
    """
}


//Step 2a: render using Rmarkdown (include figures, hide input/output)
//This notebook is in python.


//Step 2b: render the same using papermill


workflow {
    run_step01(file('notebooks/01_generate_data.Rmd'))
}
