rm(list = ls())

library(Rcpp)

double_to_char <- NULL

cppFunction('
#include <fstream>

int write_pgm_rcpp(NumericMatrix x) {
  int nrow = x.nrow(), ncol = x.ncol();
  unsigned char uc[nrow * ncol];

  double *v = x.begin();

  for (int i = 0; i < nrow * ncol; i++) {
    uc[i] = (unsigned char)(v[i] * 255);
  }

  std::ofstream outfile;
  outfile.open("rcpp.pgm", std::ios::out | std::ios::binary);
  outfile << "P5" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;
  outfile.write((char *)uc, sizeof(unsigned char) * nrow * ncol);
  outfile.close();

  return 1;
}')


N       <- 1024
int_vec <- rep.int(seq(N), N) %% 256L
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255

res <- write_pgm_rcpp(dbl_mat)
# mat

res


grey_res <- NULL
grey_res <- bench::mark(
  rcpp    = write_pgm_rcpp(dbl_mat),
  netpbm1 = write_pgm(int_mat, "./gray1.pgm"),
  png    = png::writePNG(  dbl_mat, target = './grey.png'),
  jpeg   = jpeg::writeJPEG(dbl_mat, target = './grey.jpg'),
  check = FALSE
)


dbl_mat[1:5]

if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}