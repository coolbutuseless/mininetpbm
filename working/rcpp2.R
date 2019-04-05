


library(Rcpp)

write_pgm_rcpp <- NULL

cppFunction('

#include <fstream>
#include <string>
#include <iostream>

#define HELLO 1

int write_pgm_rcpp(NumericMatrix x) {
  int nrow = x.nrow(), ncol = x.ncol();
  // double max_val = max(x);
  // double min_val = min(x);

  x = 255.0 * x;

  x = Rcpp::transpose(x);

  std::vector<double> z = as< std::vector<double> >(x);

  std::ofstream outfile;

  outfile.open("rcpp.pgm", std::ios::out | std::ios::binary);

  outfile << "P5" << std::endl << ncol << std::endl << nrow << std::endl << 255 << std::endl;

  outfile.write(reinterpret_cast<const char*>(z.data()), sizeof(unsigned char) * z.size());
  outfile.close();


  return 1;
}')


N <- 100
mat <- matrix(seq(N*N) %% 256, nrow = N)
# mat
res <- write_pgm_rcpp(mat)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N       <- 255
int_vec <- rep.int(seq(N), N) %% 256L
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Integer matrix saved to image
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
grey_res <- NULL
grey_res <- bench::mark(
  rcpp    = write_pgm_rcpp(int_mat),
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