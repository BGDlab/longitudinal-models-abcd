load_data <- function(names = c("data"), ...){
  # Determine the number of arguments
  num_files <- length(as.list(...))
  num_names <- length(names)
  if (num_files != num_names){
    stop(paste0("You provided ", num_files, " files but only ", num_names, " names. There should be a name matching each file to be loaded"))
  }
  # Initialize an empty list to store the results
  out <- vector("list", length = num_files)
  names(out) <- names
  # Iterate through each argument
  for (i in seq_along(as.list(...))) {
    #get file type
    file_ext <- tools::file_ext(as.list(...)[[i]])
    if (file_ext %in% c("csv", "txt")) {
      # Read data from .csv or .txt file
      table <- read.csv(as.list(...)[[i]], header = TRUE, sep = ",")
    } else if (file_ext %in% c("tsv")) {
      # Read data from .csv or .txt file
      table <- read.csv(as.list(...)[[i]], header = TRUE, sep = "\t")
    }
    else {
      # Unsupported file type
      stop(paste0(as.list(...)[[i]]," is an unsupported file type. Only .csv, .txt are supported."))
    }
    # Store the result in the list
    out[[i]] <- table
  }
  return(out)
}