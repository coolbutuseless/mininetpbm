rm(list = ls())

library(Rcpp)


Rcpp::sourceCpp("pgm.cpp")



N       <- 1024
int_vec <- rep.int(seq(N) - 1, N) %% 256L
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255
dbl_vec <- as.vector(dbl_mat)

res <- write_pgm_rcpp(dbl_mat, here::here('working/images/grey-rcpp.pgm'))
# mat

dbl_df <- as.data.frame(dbl_mat)

grey_res <- NULL
grey_res <- bench::mark(
  rcpp    = write_pgm_rcpp       (dbl_mat, here::here('working/images/grey-rcpp.pgm')),
  netpbm1 = mininetpbm::write_pgm(dbl_mat, here::here('working/images/grey-r.pgm')),
  png    = png::writePNG         (dbl_mat, here::here('working/images/grey.png')),
  jpeg   = jpeg::writeJPEG       (dbl_mat, here::here('working/images/grey.jpg')),
  min_time = 0.5,
  check = FALSE
)



if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}