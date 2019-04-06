#include <fstream>
#include "Rcpp.h"

using namespace Rcpp;

// [[Rcpp::export]]
void write_pgm_rcpp(NumericMatrix x, std::string filename) {
  int nrow = x.nrow(), ncol = x.ncol();

  // Set up buffer to write only 10 rows a time
  // Reduces memory usage. May help with IO.
  // Negligible overall speed impact on my machine
  unsigned int buffer_size = 10 * ncol;
  unsigned char uc[buffer_size];

  // Get a pointer to the actual data in the supplied matrix
  double *v = x.begin();

  // Open the output and write a PGM header
  std::ofstream outfile;
  outfile.open(filename, std::ios::out | std::ios::binary);
  outfile << "P5" << std::endl << ncol << " " << nrow << std::endl << 255 << std::endl;

  // Write pixels in the correct order - remember that R is column-major
  // but image output is in row-major ordering
  unsigned int out = 0;
  for (unsigned int row = 0; row < nrow; row++) {
    unsigned int j = row;
    for (unsigned int col = 0; col < ncol; col ++) {
      uc[out++] = (unsigned char)(v[j] * 255);
      j += nrow;
    }

    // Flush the buffer to disk
    if (out >= buffer_size) {
      outfile.write((char *)uc, sizeof(unsigned char) * out);
      out = 0;
    }

  }

  if (out > 0) {
    outfile.write((char *)uc, sizeof(unsigned char) * out);
  }


  outfile.close();
}