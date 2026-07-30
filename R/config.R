#' gcamsdg_base_path
#'
#' Resolve the base working directory used by the local and HPC orchestration
#' scripts (where `prj_files/`, `output/` and the GCAM run itself live).
#' Defaults to the BC3 "DIPC" cluster path, but can be overridden either via
#' `options(gcamsdg.base_path = ...)` or the `GCAMSDG_BASE_PATH` environment
#' variable (e.g. for running locally, or on a different cluster).
#' @return character, the resolved base path
#' @export
gcamsdg_base_path <- function() {
  getOption("gcamsdg.base_path",
            default = Sys.getenv("GCAMSDG_BASE_PATH", unset = "/scratch/bc3lc/GCAM_v7p1_plus"))
}

#' gcamsdg_conda_env
#'
#' Resolve the conda environment used by reticulate to run Demeter for the
#' SDG15 land indicator. Defaults to the BC3 "DIPC" cluster environment, but
#' can be overridden via `options(gcamsdg.conda_env = ...)` or the
#' `GCAMSDG_CONDA_ENV` environment variable.
#' @return character, the resolved conda environment path
#' @export
gcamsdg_conda_env <- function() {
  getOption("gcamsdg.conda_env",
            default = Sys.getenv("GCAMSDG_CONDA_ENV", unset = "/scratch/bc3lc/conda-env/dem-env-3"))
}
