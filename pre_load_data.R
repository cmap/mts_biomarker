library(taigr)
# pass data version as argument
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop("Please pass a data version to load", call.=FALSE)
}
ver <- as.numeric(args[1])

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
    expr = {taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
                                   data.file=data, quiet=T)
    },
    error = function(e) {
      message(paste("Unable to load file:", data, "- will try again..."))
      message(e)
      tryCatch(
        expr = {taigr::load.from.taiga(data.name="mts013-b75e", data.version=ver,
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

# primary repurposing meta data (separate taiga directory, version is stable)
# try and retry once if error (tracking unsuccessful files)
tryCatch(
  expr = {load.from.taiga(data.name='primary-screen-e5c7', data.version=10,
                          data.file='primary-replicate-collapsed-treatment-info',
                          quiet = T)
  },
  error = function(e) {
    message("Unable to load file: rep-meta - will try again...")
    message(e)
    tryCatch(
      expr = {load.from.taiga(data.name='primary-screen-e5c7', data.version=10,
                              data.file='primary-replicate-collapsed-treatment-info',
                              quiet = T)
      },
      error = function(e2) {
        message("Failed on second attempt")
        message(e2)
        errors <- c(errors, "rep-meta")
      }
    )
  })

if (length(errors) > 0) print(errors)
