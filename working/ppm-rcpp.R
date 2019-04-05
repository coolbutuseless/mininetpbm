rm(list = ls())

library(Rcpp)

double_to_char <- NULL



cppFunction('
#include <fstream>

int write_ppm_rcpp(NumericVector x, int nrow, int ncol) {

  //std::cout << x.size() << std::endl;

  unsigned char uc[nrow * ncol * 3];

  double *v = x.begin();

  int out = 0;
  for (int row = 0; row < nrow; row++) {
    int r = row;
    int g = row + nrow * ncol;
    int b = row + nrow * ncol * 2;
    for (int col = 0; col < ncol; col ++) {
      uc[out++] = (unsigned char)(v[r] * 255);
      uc[out++] = (unsigned char)(v[g] * 255);
      uc[out++] = (unsigned char)(v[b] * 255);
      r += nrow;
      g += nrow;
      b += nrow;
    }
  }

  std::ofstream outfile;
  outfile.open("rcpp.ppm", std::ios::out | std::ios::binary);
  outfile << "P6" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;
  outfile.write((char *)uc, sizeof(unsigned char) * nrow * ncol * 3);
  outfile.close();

  return 1;
}')


N       <- 1024
int_vec <- rep.int(seq(N), N) %% 256
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255

r <- dbl_mat
g <- t(dbl_mat)
b <- dbl_mat[, rev(seq(ncol(dbl_mat)))]

dbl_arr <- array(c(r, g, b), dim = c(N, N, 3))



rcpp    = write_ppm_rcpp(dbl_arr, N, N)



grey_res <- NULL
grey_res <- bench::mark(
  rcpp    = write_ppm_rcpp(dbl_arr, N, N),
  png    = png::writePNG(  dbl_arr, target = './col.png'),
  jpeg   = jpeg::writeJPEG(dbl_arr, target = './col.jpg'),
  min_time = 1,
  check = FALSE
)



if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}