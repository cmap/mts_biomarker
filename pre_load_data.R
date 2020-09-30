library(taigr)

# lists of required files
rf_data <- c("x-all", "x-ccle")
discrete_data <- c("lin", "mut")
linear_data <- c("ge", "xpr", "cna", "met", "mirna", "rep", "prot", "shrna")
lin_pcs <- c("linPCA")

# combined list
all_files <- Reduce(union, c(rf_data, discrete_data, linear_data, lin_pcs))

# load each from taiga (does not force pull so will alert if in cache)
errors = c()
for (data in all_files) {
  # try and retry once if error (tracking unsuccessful files)
  tryCatch(
    expr = {taigr::load.from.taiga(data.name="mts013-b75e", data.version=9,
                                   data.file=data, quiet=T)
    },
    error = function(e) {
      message(paste("Unable to load file:", data, "- will try again..."))
      message(e)
      tryCatch(
        expr = {taigr::load.from.taiga(data.name="mts013-b75e", data.version=9,
                                       data.file=data, quiet=T)
        },
        error = function(e2) {
          message("Failed on second attempt")
          message(e2)
          errors <- c(errors, data)
        }
      )
    })
}
if (length(errors) > 0) print(errors)
