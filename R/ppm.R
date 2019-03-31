

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write vector as a colour PPM file without sanity checking data
#'
#' If \code{values} is of type \code{double}, then they will be scaled to
#' integers in the range [0,255]
#'
#' @param values Integer values. Length should be \code{3 * nrow * ncol} but
#' is not checked.  Values outside the range [0,255] will be written modulo 256
#' @param nrow,ncol Dimensions of image
#' @param filename Filename to write to. Will be silently overwriten if it already exists.
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_ppm <- function(values, nrow, ncol, filename) {
  if (is.double(values)) {
    values <- as.integer(255 * (values - min(values))/(max(values) - min(values)))
  }
  con <- file(filename, open = 'wb')
  on.exit(close(con))
  writeChar(paste("P6\n", ncol, nrow, "\n255\n"), con = con, eos = NULL)
  writeBin(values, con = con, size = 1L)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write a 3d numeric array as a colour PPM image
#'
#' @param arr 3d Array
#' @param filename Filename to write to. Will be silently overwriten if it already exists.
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_ppm_from_array <- function(arr, filename) {
  dims <- dim(arr)
  if (length(dims) != 3 || dims[3] != 3L) {
    stop("Must be 3D array with dims = c(x, y, 3)")
  }
  values <- as.vector(aperm(arr, c(3L, 2L, 1L)))
  write_ppm(values, nrow=dims[2], ncol=dims[1], filename)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write numeric values as a PPM file by first scaling into [0-255] and then
#' using a viridis palette for colour lookup
#'
#' @inheritParams write_pgm
#' @param pal Viridis palette. Valid = c('A', 'B', 'C', 'D', 'E') or
#' c('magma' , 'inverno', 'plasma', 'viridis', 'cividis')
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_ppm_with_viridis <- function(values, nrow, ncol, filename, pal='D') {
  values   <- as.integer(255 * (values - min(values))/(max(values) - min(values)))
  triplets <- vir[[pal]][,values + 1L]
  dim(triplets) <- NULL

  write_ppm(triplets, nrow, ncol, filename)
}

