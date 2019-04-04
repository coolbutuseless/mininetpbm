

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write a vector as a grayscale PGM file without sanity checking the data
#'
#' First pixel is at the top-left of the image, subsequent pixels are filled
#' along a row.
#'
#' If \code{values} is of type \code{double}, then they will be scaled to
#' integers in the range [0,255]
#'
#' For \code{write_pgm()} the caller is expected to have done all sanity
#' checking as the input is not checked for correctness, i.e.
#' \itemize{
#' \item{Not checked that \code{is.numeric(values)}}
#' \item{Not checked that \code{length(values) = nrow * ncol}}
#' \item{Not checked that all integer values in range [0, 255] - Values outside the range [0,255] will be written modulo 256}
#' \item{Not checked that there are no NA values}
#' }
#'
#' @param values Integer values preferably, but numeric values allowed.
#'               Length should be nrow * ncol, but it is up to the caller to check.
#'               Values are not checked for the presence of NAs.
#' @param nrow,ncol Dimensions of image to output
#' @param filename Filename to write to. Will be silently overwriten if it already exists.
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pgm <- function(values, nrow, ncol, filename) {
  if (is.double(values)) {
    values <- as.integer(255 * (values - min(values))/(max(values) - min(values)))
  }
  con <- file(filename, open = 'wb')
  on.exit(close(con))
  writeChar(paste("P5\n", ncol, nrow, "\n255\n"), con = con, eos = NULL)
  writeBin(values, con = con, size = 1L)
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write a 2d numeric matrix as a grayscale PGM without sanity checking the data
#'
#' @param mat numeric matrix. No NAs allowed
#' @param filename Filename to write to. Will be silently overwriten if it already exists.
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pgm_from_matrix <- function(mat, filename) {
  values <- t(mat)
  # values <- values[rev(seq(nrow(values))),]
  dim(values) <- NULL # convert matrix to a vector
  write_pgm(values, nrow(mat), ncol(mat), filename)
}

