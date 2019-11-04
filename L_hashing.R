pacman::p_load(tidyverse, magrittr, tictoc, stringr, glue, R.matlab, filenamer)

tic("Entirety")
hash_filenames = "{getwd()}/hash/keys_vals/" %>% glue() %>%
   list.files(full.names = TRUE, recursive = TRUE) %>% str_subset("2_nodes", negate = TRUE)
hash_filenames_trimmed = "{getwd()}/hash/keys_vals/" %>% glue() %>%
   list.files(full.names = FALSE, recursive = TRUE) %>% str_subset("2_nodes", negate = TRUE)

for (i in 1:length(hash_filenames)) {
   hash_filenames_trimmed[i] %>% tic()
   hash_file <- hash_filenames[i] %>% readMat()
   hash_keys <- hash_file$L.keys
   hash_values <- hash_file$L.vals
   L_hash <- new.env(hash = TRUE)
   for (j in 1:length(hash_keys)) {
      L_hash[[hash_keys[j]]] <- hash_file$L.vals[, , j]
   }
   RDS_filename <- hash_filenames[i] %>%
      trim_ext() %>% set_fext("rds") %>%
      str_replace("keys_vals", "hashes")
   RDS_filename %>% make_path()
   saveRDS(L_hash, RDS_filename)
   # hash_filenames_trimmed[i] %>%
   #    trim_ext() %>% set_fext("rds") %>%
   #    str_replace("keys_vals", "hashes") %>%
   #    print()
   toc()
}
rm(i, j)
toc()