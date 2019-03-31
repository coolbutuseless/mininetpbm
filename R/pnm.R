

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write values as a PGM/PPM file (includes checking of input data for sanity)
#'
#' Write values as a PGM/PPM file (includes checking of input data for sanity)
#'
#' If values are double, then scaled to [0,255] or [0,65535] depending upon \code{nbytes}
#'
#' \itemize{
#' \item{\code{write_pnm}} - write a vector of values to either a PGM or PPM file.  If
#' the number of values supplied exactly matches the dimensions of the image, a PGM file
#' is written, otherwise a PPM file is written.
#' \item{\code{write_pnm_matrix}} - write a 2D matrix of values as a PGM file.
#' \item{\code{write_pnm_array}} - write a 3D array of values as a PPM file
#' }
#'
#' @param values Integer values. Length must be nrow * ncol
#' @param nrow,ncol Dimensions of output image
#' @param filename Filename to write to.
#' @param nbytes Number of bytes per colour compoment. Default 1L. Otherwise 2
#' @param overwrite Overwrite the output file if it already exists? default: FALSE
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pnm <- function(values, nrow, ncol, filename, nbytes = 1L, overwrite = FALSE) {

  if (!is.atomic(values)) {
    stop("'values' must a vector")
  } else if (file.exists(filename) && !overwrite) {
    stop("Output file '", filename, "' already exists and 'overwrite = FALSE'")
  } else if (anyNA(values) || !is.numeric(values)) {
    stop("'values' must by numeric and not contain NAs")
  } else if (length(values) == nrow * ncol) {
    size  <- 1L
    magic <- "P5\n"
  } else if (length(values) == nrow * ncol * 3) {
    size  <- 3L
    magic <- "P6\n"
  } else {
    stop("Size must be either 1x or 3x nrow * ncol")
  }

  max_value <- 255L
  if (nbytes != 1L) {
    max_value <- 65535L
  }

  if (is.double(values)) {
    values <- as.integer(max_value * (values - min(values))/(max(values) - min(values)))
  } else if (!is.integer(values)) {
    stop("'values' must be of type integer")
  } else if (min(values) < 0L || max(values) > max_value) {
    stop("'values' must all be in range [0, ", max_value, "]")
  }

  con <- file(filename, open = 'wb')
  on.exit(close(con))
  writeChar(paste(magic, ncol, nrow, "\n", max_value, "\n"), con = con, eos = NULL)
  writeBin(values, con = con, size = 1L)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname write_pnm
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pnm_from_matrix <- function(values, filename, nbytes = 1L) {
  if (!is.matrix(values)) {
    stop("Input 'obj' must be a matrix")
  }
  dims        <- dim(values)
  values      <- t(values)
  dim(values) <- NULL
  write_pnm(values, dims[1], dims[2], filename, nbytes = nbytes)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @rdname write_pnm
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pnm_from_array <- function(values, filename, nbytes = 1L) {
  dims <- dim(values)

  if (!is.matrix(values)) {
    stop("Input 'values' must be an array")
  } else if (length(dims) == 3L & dims[3] == 3L) {
    values <- as.vector(aperm(values, c(3L, 2L, 1L)))
  } else if (length(dims) == 2L) {
    values <- t(values)
    dim(values) <- NULL
  } else {
    stop("Array must be 2D or 3D")
  }

  write_pnm(values, dims[2], dims[1], filename, nbytes = nbytes)
}

