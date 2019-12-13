#!/usr/bin/env nextflow
RES_DIR = params.resultsDir

//Step 1: create some data and pass it to Step 2.
//This is a jupyter notebook in Python
process generate_data {
    def id = "01_generate_data"
    conda "envs/run_notebook.yml"  //define a conda env for each step...
    publishDir "$RES_DIR/$id"

    input:
        file notebook from Channel.fromPath("analyses/${id}.ipynb")

    output:
        file "iris.csv" into generate_data_csv 
        file "${id}.html" into generate_data_html 


    """
    reportsrender ${notebook} \
        ${id}.html \
        --cpus=${task.cpus} \
        --params="output_file=iris.csv"
    """
}


//Step 2: render using Rmarkdown 
//This is a Rmd notebook in R 
process visualize_data {
    def id = "02_visualize_data"
    conda "envs/run_notebook.yml"  //...or use a generic env for multiple steps.
    publishDir "$RES_DIR/$id"

    input:
        file notebook from Channel.fromPath("analyses/${id}.Rmd")
        file 'iris.csv' from generate_data_csv 

    output:
        file "${id}.html" into visualize_data_html 


    """
    reportsrender ${notebook} \
        ${id}.html \
        --cpus=${task.cpus} \
        --params="input_file=iris.csv"
    """
}


// Deploy the data in the params.deployDir directory.
process deploy {
    conda "envs/run_notebook.yml"
    publishDir "${params.deployDir}", mode: "copy"

    input:
        file 'input/*' from Channel.from().mix(
            generate_data_html,
            visualize_data_html 
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
    reportsrender index *.html --index="index.md" --title="Examples"
    """

}
