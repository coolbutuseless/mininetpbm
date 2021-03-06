rm(list = ls())

library(Rcpp)




cppFunction('
#include <fstream>

int write_ppm_from_matrix_with_palette(NumericMatrix mat, IntegerMatrix pal, std::string filename) {

  int nrow = mat.nrow(), ncol = mat.ncol();

  int buffer_size = 10 * ncol * 3;
  unsigned char uc[buffer_size];

  double *v = mat.begin();

  std::ofstream outfile;
  outfile.open(filename, std::ios::out | std::ios::binary);
  outfile << "P6" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;


  int out = 0;
  for (int row = 0; row < nrow; row++) {
    int j = row;
    for (int col = 0; col < ncol; col ++) {
      unsigned char val = (unsigned char)(v[j] * 255);
      uc[out++] = pal(val, 0);
      uc[out++] = pal(val, 1);
      uc[out++] = pal(val, 2);
      j += nrow;
    }

    if (out >= buffer_size) {
      outfile.write((char *)uc, sizeof(unsigned char) * out);
      out = 0;
    }

  }

  if (out > 0) {
    outfile.write((char *)uc, sizeof(unsigned char) * out);
  }

  outfile.close();

  return 2;
}')


N       <- 1024
int_vec <- rep.int(seq(N) - 1, N) %% 256
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255

r <- dbl_mat
g <- t(dbl_mat)
b <- dbl_mat[, rev(seq(ncol(dbl_mat)))]

dbl_arr <- array(c(r, g, b), dim = c(N, N, 3))

pal <- readRDS("~/pal.rds")

rcpp    = write_ppm_from_matrix_with_palette(dbl_mat, pal, here::here("working/images/col-rcpp-from-matrices.ppm"))



grey_res <- NULL
grey_res <- bench::mark(
rcpp_pal    = write_ppm_from_matrix_with_palette(dbl_mat, pal, here::here("working/images/col-rcpp-from-matrices.ppm")),
  rcpp    = foist::write_ppm_rcpp(dbl_arr, N, N, here::here("working/images/col-rcpp.ppm")),
  png    = png::writePNG(  dbl_arr, target = here::here("working/images/col-png.png")),
  jpeg   = jpeg::writeJPEG(dbl_arr, target = here::here("working/images/col-jpeg.jpg")),
  min_time = 1,
  check = FALSE
)



if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}