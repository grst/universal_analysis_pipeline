#!/usr/bin/env nextflow

//use dsl2 to support modules.
nextflow.preview.dsl=2

include './nextflow/render_rmd'


render_rmd (file('notebooks/01_first_step.Rmd'))
