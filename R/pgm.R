

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Write a matrix as a grayscale PGM file without sanity checking the data
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
#' @param image Integer values preferably, but numeric values allowed.
#'               Length should be nrow * ncol, but it is up to the caller to check.
#'               Values are not checked for the presence of NAs.
#' @param filename Filename to write to. Will be silently overwriten if it already exists.
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
write_pgm_r <- function(image, filename) {

  # values <- t(image)
  values <- t(image)
  dim(values) <- NULL # convert matrix to a vector

  if (is.double(values)) {
    values <- as.integer(255 * (values - min(values))/(max(values) - min(values)))
  }

  con <- file(filename, open = 'wb')
  on.exit(close(con))
  writeChar(paste0("P5\n", nrow(image), ' ', ncol(image), "\n255\n"), con = con, eos = NULL)
  writeBin(values, con = con, size = 1L)
}


if (interactive()) {
  N       <- 255
  int_vec <- rep.int(seq(N), N) %% 256L
  int_mat <- matrix(int_vec, N, N, byrow = TRUE)
  dbl_mat <- int_mat/255

  dbl_arr <- remap_with_viridis(dbl_mat)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Integer matrix saved to image
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  grey_res <- bench::mark(
    netpbm1 = write_pgm(int_mat, "working/gray1.pgm"),
    netpbm2 = write_pgm(dbl_mat, "working/gray2.pgm"),
    netpbm2 = write_pnm(      dbl_mat,          'working/grey.pgm'),
    png    = png::writePNG(  dbl_mat, target = 'working/grey.png'),
    jpeg   = jpeg::writeJPEG(dbl_mat, target = 'working/grey.jpg'),
    check = FALSE
  )

  grey_res

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}


