
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Viridis palettes in a more useful form for palette lookups,
# and to avoid pulling in the 'viridis' package as a dependency
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vir <- list()
for (palname in c('A', 'B', 'C', 'D', 'E')) {
  tmp <- viridis::viridis.map
  tmp <- as.matrix(tmp[tmp$opt == palname, c('R', 'G', 'B')]) * 255
  storage.mode(tmp) <- 'raw'
  vir[[palname]] <- t(tmp)
}


vir[['magma'  ]] <- vir[['A']]
vir[['inferno']] <- vir[['B']]
vir[['plasma' ]] <- vir[['C']]
vir[['viridis']] <- vir[['D']]
vir[['cividis']] <- vir[['E']]


usethis::use_data(vir, internal = TRUE, compress = 'xz', overwrite = TRUE)


