nextflow.preview.dsl=2

process render_rmd {

    input:
        file notebook.Rmd

    output:
        file notebook.html

    script:
        """
        # was necessary to circumvent incompatibilities
        # of Intel mkl with libgomp.
        export MKL_THREADING_LAYER=GNU
        export MKL_NUM_THREADS={threads}
        export NUMEXPR_NUM_THREADS={threads}
        export OMP_NUM_THREADS={threads}
        export NUMBA_NUM_THREADS={threads}
        Rscript --vanilla -e "
         rmarkdown::render('notebook.Rmd',
           output_file='notebook.html',
           output_format=rmdformats::material(self_contained=TRUE))"
        """

}
