nextflow.preview.dsl=2

process render_rmd {
    conda 'envs/render_rmd.yml'

    input:
        file 'notebook.Rmd'

    output:
        file 'notebook.html'

    script:
        """
        # was necessary to circumvent incompatibilities
        # of Intel mkl with libgomp.
        export MKL_THREADING_LAYER=GNU
        export MKL_NUM_cpus=${task.cpus}
        export NUMEXPR_NUM_cpus=${task.cpus}
        export OMP_NUM_cpus=${task.cpus}
        export NUMBA_NUM_cpus=${task.cpus}
        # work around https://github.com/rstudio/rmarkdown/issues/1508
        cp -L notebook.Rmd notebook.copy.Rmd
        Rscript --vanilla -e " \
         rmarkdown::render('notebook.copy.Rmd', \
           output_file='notebook.html', \
           output_format=rmdformats::material(self_contained=TRUE))"
        """

}
