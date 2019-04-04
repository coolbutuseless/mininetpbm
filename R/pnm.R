

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write a PGM/PPM image from an array or matrix
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
#' @param image Integer values. Length must be nrow * ncol
#' @param filename Filename to write to.
#' @param nbytes Number of bytes per colour compoment. Default 1L. Otherwise 2
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pnm <- function(image, filename, nbytes = 1L) {


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Rearrange matrix and array values into the correct order
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (is.matrix(image)) {
    dims        <- dim(image)
    values      <- t(image)
    dim(values) <- NULL
    nrow        <- dims[1]
    ncol        <- dims[2]
    magic       <- 'P5'  # single-channel image
  } else if (is.array(image)) {
    dims <- dim(image)

    if (length(dims) == 3L && dims[3] == 3L) {
      values <- as.vector(aperm(image, c(3L, 2L, 1L)))
      magic  <- 'P6' # three-channel image
    } else if (length(dims) == 2L) {
      values      <- t(image)
      dim(values) <- NULL
      magic       <- 'P5' # single-channel image
    } else {
      stop("Array must be 2D or 3D only")
    }

    nrow <- dims[2]
    ncol <- dims[1]
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # More sanity checks
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (anyNA(values) || !is.numeric(values)) {
    stop("'values' must by numeric and not contain NAs")
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Use 'nbytes' to set the maximum value for the image
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (nbytes == 1) {
    max_value <- 255L
  } else if (nbytes == 2) {
    max_value <- 65535L
  } else {
    stop("Only supports nbytes = 1 or 2")
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Scale double values into the correct integer range
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (is.double(values)) {
    values <- as.integer(max_value * (values - min(values))/(max(values) - min(values)))
  } else if (!is.integer(values)) {
    stop("'image' must be of type integer or double")
  } else if (min(values) < 0L || max(values) > max_value) {
    stop("'values' must all be in range [0, ", max_value, "]")
  }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Open a connection and write the data
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  con <- file(filename, open = 'wb')
  on.exit(close(con))
  writeChar(paste0(magic, "\n", ncol, ' ', nrow, "\n", max_value, "\n"), con = con, eos = NULL)
  writeBin(values, con = con, size = nbytes)
}





if (interactive()) {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Setup a test matrix and array to output
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  N       <- 255
  int_vec <- rep.int(seq(N), N) %% 256
  int_mat <- matrix(int_vec, N, N, byrow = TRUE)
  dbl_mat <- int_mat/255

  r <- int_mat
  g <- t(int_mat)
  b <- int_mat[, rev(seq(ncol(int_mat)))]

  int_arr <- array(c(r, g, b), dim = c(N, N, 3))


  carr <- matrix_to_array(int_mat)
  # write_pnm(int_arr, "working/vir.ppm")
  png::writePNG(carr, "working/vir.png")



}





