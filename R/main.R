local_model_path <- function(model_identifier, create_dir = FALSE) {
  # Determine if the input is a path (contains separators) or a model name
  if (!(is.character(model_identifier) && length(model_identifier) == 1))
    stop("model must be a single string.")

  cache_dir <- file.path(Sys.getenv("HOME", unset = "~"), ".cache", "runSentenceTransformer")
  path <- file.path(cache_dir, model_identifier)

  if (!dir.exists(path) && !create_dir) stop(paste("Model path does not exist:", path))
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)

  normalizePath(path)
}

download_model <- function(model, model_path = local_model_path(model, create_dir = TRUE)) {
  # Create the target directory if it doesn't exist
  if (!dir.exists(model_path)) {
    dir.create(model_path, recursive = TRUE)
  }

  base = "https://huggingface.co/"
  # model
  ext = "/resolve/main/"
  needed_files <- c(
    "config.json",
    "tokenizer.json",
    "model.safetensors"
  )

  # Download essential files first
  successful_downloads <- c()
  for (file in needed_files) {
    file_url <- paste0(base, model, ext, file)
    target_file <- file.path(model_path, file)
    download_success <- tryCatch({
      download.file(file_url, target_file, mode = "wb", quiet = TRUE)
      TRUE
    }, warning = function(w) {
      print(w)
      FALSE
    }, error = function(e) {
      print(e)
      FALSE
    })

    if (download_success) {
      message(paste("Downloaded:", file))
      successful_downloads <- c(successful_downloads, file)
    } else {
      message(paste("Could not download (optional):", file))
    }
  }

  if (!all(needed_files == successful_downloads)) stop(
    paste("not all files have been downloaded succesfully, arthefacts are in: ", model_path)
  )
}

load_model_get_embed_function <- function(model, model_path = local_model_path(model)) {
  if (!dir.exists(model_path)) stop(
    paste("The provided model path does not exist.", model_path)
  )

  function(data) string_embedding(data, model_path) # Rust backend
}

embed <- function(data, model, model_path = local_model_path(model)) {
  if (!dir.exists(model_path)) stop(
    paste("The provided model path does not exist.", model_path)
  )
  if (!is.character(data)) stop(
    paste(
      "Provided data must be a vector of character/strings but is: ",
      paste(class(data), collapse = ", ")
    )
  )

  string_embedding(data, model_path) # Rust backend
}
