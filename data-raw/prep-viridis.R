
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Viridis palettes in a more useful form for palette lookups,
# and to avoid pulling in the 'viridis' package as a dependency
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vir <- list()
for (palname in c('A', 'B', 'C', 'D', 'E')) {
  tmp            <- viridis::viridis.map
  vir[[palname]] <- as.matrix(tmp[tmp$opt == palname, 1:3])
}


vir[['magma'  ]] <- vir[['A']]
vir[['inferno']] <- vir[['B']]
vir[['plasma' ]] <- vir[['C']]
vir[['viridis']] <- vir[['D']]
vir[['cividis']] <- vir[['E']]


usethis::use_data(vir, internal = TRUE, compress = 'xz', overwrite = TRUE)



#
# N       <- 255
# int_vec <- rep.int(seq(N), N) %% 256
# int_mat <- matrix(int_vec, N, N, byrow = TRUE)
# dbl_mat <- int_mat/max(int_mat)
#
# dbl_arr <- array(c(dbl_mat, dbl_mat, dbl_mat), dim = c(N, N, 3))
#
# png::writePNG(dbl_mat, target="working/01.png")
# png::writePNG(dbl_arr, target="working/02.png")
#
# jpeg::writeJPEG(dbl_mat, target = "working/01.jpg")
# jpeg::writeJPEG(dbl_mat, target = "working/02.jpg")
#
#
# dbl_arr <- array(dbl_mat, dim = c(N, N, 1))
# png::writePNG(dbl_arr, target="working/03.png")
#
#
# pal        <- vir[['B']]
# int_values <- as.integer(dbl_mat/max(dbl_mat) * 255)
# colour_mat <- pal[int_values,]
# colour_arr <- array(colour_mat, dim = c(dim(dbl_mat), 3))
#
#
# png::writePNG(colour_arr, target="working/03.png")
#
#
#
#
#
# arr <- remap_with_viridis(int_mat)
# png::writePNG(arr, target="working/04.png")









