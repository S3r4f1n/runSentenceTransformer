mod models;

use std::path::{Path};
use extendr_api::prelude::*;

use crate::models::bert::BertModelWrapper;

#[extendr]
/// Resolve Full Path
///
/// This function resolves a relative path to its canonical absolute representation.
///
/// @param path A character string representing a file path to resolve
/// @return A character string with the canonical absolute path
/// @keywords internal
fn rust_pwd(path: Vec<String>) -> Strings {
    let path = path.get(0).unwrap();
    let path = if path == "" {"."} else {path};
    let full_path = Path::new(path)
        .canonicalize()
        .expect(&format!("Failed to resolve path"));

    // Return as Strings
    full_path.to_string_lossy().into()
}

#[extendr]
/// Generate String Embeddings Using BERT Model
///
/// This function generates embeddings for strings using a pre-loaded BERT model.
/// It expects the model files (config.json, tokenizer.json, and model.safetensors) to be available at the specified path.
///
/// @param x A character vector containing the text data to embed
/// @param path A character string specifying the path to the BERT model directory containing config.json, tokenizer.json, and model.safetensors
/// @return A list of numerical vectors representing the embeddings for each input string
/// @details
/// Only BERT models are currently supported and the following files are expected:
/// \itemize{
///   \item config.json
///   \item tokenizer.json
///   \item model.safetensors
/// }
/// @keywords internal
fn string_embedding(x: Strings, path: Vec<String>) -> List{
    let path = path.get(0).unwrap();
    let bert = BertModelWrapper::load(path).unwrap();
    x.into_iter()
        .map(|xi| match xi.is_na() {
            true => Doubles::new(0),
            false => {
                let text = xi.as_str();
                let embedding = bert.embed(text).unwrap();
                let embedding_as_f64 = embedding.iter().map(|i| *i as f64);
                Doubles::from_iter(embedding_as_f64)
            },
        })
        .collect::<List>()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod runSentenceTransformer;
    fn string_embedding;
    fn rust_pwd;
}


