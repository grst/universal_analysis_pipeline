#!/usr/bin/env nextflow
RES_DIR = params.resultsDir

//Step 1: create some data and pass it to Step 2.
//This is a notebook in R
process run_step01 {
    def id = "01_generate_data"
    conda "envs/step01.yml"  //define a conda env for each step...
    publishDir "$RES_DIR/$id"

    input:
        file 'notebook.Rmd' from Channel.fromPath("analyses/${id}.Rmd")

    output:
        file "iris.tsv" into iris_dataset1, iris_dataset2
        file "${id}.html" into report_step01


    """
    reportsrender notebook.Rmd \
        ${id}.html \
        --cpus=${task.cpus} \
        --params="out_file=iris.tsv"
    """
}


//Step 2a: render using Rmarkdown (include figures, hide input/output)
//This notebook is in python.
process run_step02_rmd {
    def id = "02_analyze_data_rmd"
    conda "envs/render.yml"  //...or use a generic env for multiple steps.
    publishDir "$RES_DIR/$id"
    cpus 2

    input:
        file 'notebook.Rmd' from Channel.fromPath('analyses/02_analyze_data.Rmd')
        file 'iris.tsv' from iris_dataset1

    output:
        file "${id}.html" into report_step02_rmd


    """
    reportsrender notebook.Rmd \
        ${id}.html \
        --cpus=${task.cpus} \
        --params="input_file=iris.tsv"
    """
}


//Step 2b: render using Papermill (include figures, hide input/output)
//This notebook is in python.
process run_step02_papermill {
    def id = "02_analyze_data_papermill"
    conda "envs/render.yml"  //...or use a generic env for multiple steps.
    publishDir "$RES_DIR/$id"
    cpus 2

    input:
        file 'notebook.Rmd' from Channel.fromPath('analyses/02_analyze_data.Rmd')
        file 'iris.tsv' from iris_dataset2

    output:
        file "${id}.html" into report_step02_papermill

    """
    reportsrender notebook.Rmd \
        ${id}.html \
        --engine=papermill \
        --cpus=${task.cpus} \
        --params="input_file=iris.tsv"
    """
}

process deploy {
    conda "envs/render.yml"
    publishDir "${params.deployDir}", mode: "copy"

    input:
        file 'input/*' from Channel.from().mix(
            report_step01, report_step02_rmd, report_step02_papermill
        ).collect()

    output:
        file "*.html"
        // use markdown for github-pages. Change extension to
        // ".html" to get an HTML index.
        file "index.md"

    // need to duplicate input files, because input files are not
    // matched as output files.
    // See https://www.nextflow.io/docs/latest/process.html#output-values
    """
    cp input/*.html .
    reportsrender index *.html --index="index.md"
    """

}
