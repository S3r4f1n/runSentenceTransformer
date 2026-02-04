mod models;

use std::path::{Path};
use extendr_api::prelude::*;

use crate::models::bert::BertModelWrapper;

#[extendr]
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
/// only Bert models a currently supported and the following files are expected:
/// - config.json
/// - tokenizer.json
/// - model.safetensors
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


