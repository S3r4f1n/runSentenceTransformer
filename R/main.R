#' Get Local Model Path
#'
#' Creates and returns the local path for storing a model in the cache directory.
#'
#' @param model_identifier A character string identifying the model (either Hugging Face model name or local path)
#' @param create_dir Logical indicating whether to create the directory if it doesn't exist. Default is FALSE.
#'
#' @return Character string with the normalized path to the model.
#'
#' @examples
#' \dontrun{
#' model_path <- local_model_path("sentence-transformers/all-MiniLM-L6-v2")
#' }
#'
#' @export
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

#' Download Model from Hugging Face
#'
#' Downloads a model from Hugging Face Hub, specifically the required files for BERT models.
#' The function downloads config.json, tokenizer.json, and model.safetensors from the specified model repository.
#'
#' @param model A character string with the Hugging Face model identifier (e.g. "sentence-transformers/all-MiniLM-L6-v2")
#' @param model_path A character string specifying the local path to store the model. Defaults to the path returned by local_model_path().
#'
#' @return Invisible NULL. The function produces side effects by downloading files to the specified directory.
#'
#' @examples
#' \dontrun{
#' download_model("sentence-transformers/all-MiniLM-L6-v2")
#' }
#'
#' @export
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
      utils::download.file(file_url, target_file, mode = "wb", quiet = TRUE)
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

#' Load Model and Get Embedding Function
#'
#' Loads a model from the specified path and returns a function that can be used to generate embeddings.
#' This function verifies that the model path exists and returns a partially applied embedding function.
#'
#' @param model A character string identifying the model (used to determine the model path)
#' @param model_path A character string specifying the local path to the model. Defaults to the path returned by local_model_path().
#'
#' @return A function that takes data as input and returns embeddings using the loaded model.
#'
#' @examples
#' \dontrun{
#' embed_func <- load_model_get_embed_function("sentence-transformers/all-MiniLM-L6-v2")
#' embeddings <- embed_func(c("Hello world", "How are you?"))
#' }
#'
#' @export
load_model_get_embed_function <- function(model, model_path = local_model_path(model)) {
  if (!dir.exists(model_path)) stop(
    paste("The provided model path does not exist.", model_path)
  )

  function(data) string_embedding(data, model_path) # Rust backend
}

#' Generate Embeddings for Text Data
#'
#' Generates embeddings for the provided text data using a specified model.
#' This function takes character vectors as input and returns numerical embeddings using the loaded model.
#'
#' @param data A character vector containing the text data to embed
#' @param model A character string identifying the model (used to determine the model path)
#' @param model_path A character string specifying the local path to the model. Defaults to the path returned by local_model_path().
#'
#' @return A matrix or list of numerical embeddings corresponding to the input text data.
#'
#' @examples
#' \dontrun{
#' embeddings <- embed(c("Hello world", "How are you?"), "sentence-transformers/all-MiniLM-L6-v2")
#' }
#'
#' @export
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
