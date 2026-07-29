#' gcam_sdg_base_path
#'
#' Resolve the base working directory used by the local and HPC orchestration
#' scripts (where `prj_files/`, `output/` and the GCAM run itself live).
#' Defaults to the BC3 "DIPC" cluster path, but can be overridden either via
#' `options(gcam_sdg.base_path = ...)` or the `GCAM_SDG_BASE_PATH` environment
#' variable (e.g. for running locally, or on a different cluster).
#' @return character, the resolved base path
#' @export
gcam_sdg_base_path <- function() {
  getOption("gcam_sdg.base_path",
            default = Sys.getenv("GCAM_SDG_BASE_PATH", unset = "/scratch/bc3lc/GCAM_v7p1_plus"))
}

#' gcam_sdg_conda_env
#'
#' Resolve the conda environment used by reticulate to run Demeter for the
#' SDG15 land indicator. Defaults to the BC3 "DIPC" cluster environment, but
#' can be overridden via `options(gcam_sdg.conda_env = ...)` or the
#' `GCAM_SDG_CONDA_ENV` environment variable.
#' @return character, the resolved conda environment path
#' @export
gcam_sdg_conda_env <- function() {
  getOption("gcam_sdg.conda_env",
            default = Sys.getenv("GCAM_SDG_CONDA_ENV", unset = "/scratch/bc3lc/conda-env/dem-env-3"))
}
