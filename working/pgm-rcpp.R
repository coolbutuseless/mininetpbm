rm(list = ls())

library(Rcpp)

double_to_char <- NULL

cppFunction('
#include <fstream>

int write_pgm_rcpp(NumericMatrix x, std::string filename) {
  int nrow = x.nrow(), ncol = x.ncol();

  unsigned int buffer_size = 10 * ncol;
  unsigned char uc[buffer_size];

  double *v = x.begin();

  std::ofstream outfile;
  outfile.open(filename, std::ios::out | std::ios::binary);
  outfile << "P5" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;

  int out = 0;
  for (int row = 0; row < nrow; row++) {
    int j = row;
    for (int col = 0; col < ncol; col ++) {
      uc[out++] = (unsigned char)(v[j] * 255);
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

  return 1;
}')




N       <- 1024
int_vec <- rep.int(seq(N) - 1, N) %% 256L
int_mat <- matrix(int_vec, N, N, byrow = TRUE)
dbl_mat <- int_mat/255
dbl_vec <- as.vector(dbl_mat)

res <- write_pgm_rcpp(dbl_mat, here::here('working/images/grey-rcpp.pgm'))
# mat


grey_res <- NULL
grey_res <- bench::mark(
  bin     = writeBin(int_vec, here::here('working/images/grey-r.bin')),
  rds     = saveRDS(dbl_mat, here::here('working/images/grey-r.rds')),
  rcpp    = write_pgm_rcpp(dbl_mat, here::here('working/images/grey-rcpp.pgm')),
  netpbm1 = write_pgm(dbl_mat, here::here('working/images/grey-r.pgm')),
  png    = png::writePNG(  dbl_mat, target = here::here('working/images/grey.png')),
  jpeg   = jpeg::writeJPEG(dbl_mat, target = here::here('working/images/grey.jpg')),
  min_time = 1,
  check = FALSE
)



if (!is.null(grey_res)) {
  print(grey_res)

  library(ggplot2)
  plot(grey_res) + theme_bw(15)
}