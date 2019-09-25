#!/usr/bin/env python3
"""render_papermill.py

Execute and render a jupyter/jupytext notebook using papermill.

Usage:
  render_papermill.py <notebook> <out_file> [options]
  render_papermill.py (-h | --help)

Options:
  -h --help             Show this screen.
  --cpus=<cpus>         Number of CPUs to use for Numba/Numpy. [default: 1]
  --params=<params>     space-separated list of key-value pairs. E.g.
                        "input_file=dir/foo.txt output_file=dir2/bar.html"

"""

import papermill as pm
import jupytext as jtx
import os
from os.path import splitext
import nbformat
from tempfile import NamedTemporaryFile
from nbconvert import HTMLExporter
from docopt import docopt
from util import set_cpus, parse_params
from shutil import copyfile


def jupytext_convert(nb_path, out_file):
    """Convert one jupytext format to another. Formats
    are inferred from the file extensions.
    """
    nb = jtx.read(nb_path)
    jtx.writef(nb, out_file)


def run_papermill(nb_path, out_file, params):
    """execute .ipynb file using papermill and write
    results to out_file in ipynb format.
    """
    # excplicitly specify the Python 3 kernel to override the notebook-metadata.
    pm.execute_notebook(
        nb_path, out_file, parameters=params, log_output=True, kernel_name="python3"
    )


def convert_to_html(nb_path, out_file):
    """convert executed ipynb file to html document. """
    with open(nb_path) as f:
        nb = nbformat.read(f, as_version=4)

    html_exporter = HTMLExporter()
    html_exporter.template_file = "full"

    html, resources = html_exporter.from_notebook_node(nb)

    with open(out_file, "w") as f:
        f.write(html)


def render_papermill(input_file, output_file, params=None):
    """
    Wrapper function to render a jupytext/jupyter notebook
    with papermill and nbconvert.

    Args:
        input_file: path to input (.py/.Rmd/.md/.../.ipynb) file
        output_file: path to output (html) file.
        params: dictionary that will be passed to papermill.
    """
    tmp_nb_converted = NamedTemporaryFile(suffix=".ipynb")
    if splitext(input_file)[-1] != ".ipynb":
        jupytext_convert(input_file, tmp_nb_converted.name)
    else:
        copyfile(input_file, tmp_nb_converted.name)

    tmp_nb_executed = NamedTemporaryFile(suffix=".ipynb")
    run_papermill(tmp_nb_converted.name, tmp_nb_executed.name, params)

    tmp_nb_converted.close()
    convert_to_html(tmp_nb_executed.name, output_file)

    tmp_nb_executed.close()


if __name__ == "__main__":
    arguments = docopt(__doc__)
    params = parse_params(arguments["--params"])

    set_cpus(arguments["--cpus"])

    render_papermill(arguments["<notebook>"], arguments["<out_file>"], params)
