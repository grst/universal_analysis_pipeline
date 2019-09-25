#!/usr/bin/env nextflow

//use dsl2 to support modules.
nextflow.preview.dsl=2


//Step 1: create some data and pass it to Step 2.
//This is a notebook in R
process run_step01 {
    conda "envs/step01.yml"  //define a conda env for each step...
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
process run_step02_rmd {
    conda "envs/render.yml"  //...or use a generic env for multiple steps.
    echo true
    cpus 2

    input:
        file 'notebook.Rmd'
        file 'iris.tsv'

    output:
        file "report.html"

    publishDir "results/02_analyze_data_rmd"

    """
    render_rmd.py notebook.Rmd \
        report.html \
        --cpus=${task.cpus} \
        --params="input_file=iris.tsv"
    """
}


//Step 2b: render using Papermill (include figures, hide input/output)
//This notebook is in python.
process run_step02_papermill {
    conda "envs/render.yml"  //...or use a generic env for multiple steps.
    echo true
    cpus 2

    input:
        file 'notebook.Rmd'
        file 'iris.tsv'

    output:
        file "report.html"

    publishDir "results/02_analyze_data_rmd"

    """
    render_papermill.py notebook.Rmd \
        report.html \
        --cpus=${task.cpus} \
        --params="input_file=iris.tsv"
    """
}

workflow {
    run_step01(file('notebooks/01_generate_data.Rmd'))
    run_step02_rmd(file('notebooks/02_analyze_data.Rmd'),
               run_step01.out.first)
    run_step02_papermill(file('notebooks/02_analyze_data.Rmd'),
               run_step01.out.first)
}
