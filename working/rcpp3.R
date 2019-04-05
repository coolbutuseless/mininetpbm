


library(Rcpp)

write_pgm_rcpp <- NULL

cppFunction('
#include <fstream>
#include <string>
#include <iostream>


int write_pgm_rcpp(NumericMatrix x) {
  int nrow = x.nrow(), ncol = x.ncol();

  unsigned char uc[nrow * ncol];

  //x = 255.0 * x;

  // x = Rcpp::transpose(x);

  double *z = x.begin();

  // std::cout << z[0] << std::endl;

  std::ofstream outfile;


  outfile.open("rcpp.pgm", std::ios::out | std::ios::binary);

  outfile << "P5" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;

  //for (int i = 0; i < 3; i++) {
  // # std::cout << (unsigned char)(z[i]) << std::endl;
  //  outfile.write((unsigned char)z[i], sizeof(unsigned char));
  //}

  outfile.write(reinterpret_cast<const char*>(z), sizeof(unsigned char) * nrow * ncol);
  outfile.close();


  return 1;
}')


N <- 1024
mat <- matrix(seq(N*N) %% 256, nrow = N)
# mat
res <- write_pgm_rcpp(mat)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
N       <- 1024
int_vec <- rep.int(seq(N), N) %% 256L
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255

dbl_mat[1:5]
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Integer matrix saved to image
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
grey_res <- NULL
grey_res <- bench::mark(
  rcpp    = write_pgm_rcpp(dbl_mat),
  netpbm1 = write_pgm(int_mat, "working/gray1.pgm"),
  png    = png::writePNG(  dbl_mat, target = 'working/grey.png'),
  jpeg   = jpeg::writeJPEG(dbl_mat, target = 'working/grey.jpg'),
  check = FALSE
)


dbl_mat[1:5]

if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}
