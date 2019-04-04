

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Remap a matrix with the given palette
#'
#' @param mat numeric matrix
#' @param pal RGB palette.  256x3 numeric values in the range [0, 1]
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
remap_with_pal <- function(mat, pal) {
  stopifnot(identical(dim(pal), c(256L, 3L)))
  stopifnot(is.matrix(mat))

  int_values <- as.integer(mat/max(mat) * 255)
  colour_mat <- pal[int_values,]
  colour_arr <- array(colour_mat, dim = c(dim(mat), 3))

  colour_arr
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Remap a matrix with the named viridis palette
#'
#' @param mat numeric matrix
#' @param pal_name viridis palette name. c('A', 'B', 'C', 'D', 'E') or
#' c('magma' , 'inverno', 'plasma', 'viridis', 'cividis')
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
remap_with_viridis <- function(mat, pal_name = 'B') {
  stopifnot(pal_name %in% names(vir))
  stopifnot(is.matrix(mat))

  remap_with_pal(mat, vir[[pal_name]])
}




if (interactive()) {
  N       <- 255
  int_vec <- rep.int(seq(N), N) %% 256
  int_mat <- matrix(int_vec, N, N, byrow = TRUE)

  colour_arr <- remap_with_viridis(int_mat)

  png::writePNG(colour_arr, "working/vir.png")
}


