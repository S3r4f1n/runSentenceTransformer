---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->
[![R-CMD-check](https://github.com/S3r4f1n/runSentenceTransformer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/S3r4f1n/runSentenceTransformer/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# runSentenceTransformer

An R package that provides access to sentence transformer models using Rust backend. The package does load, and run BERT-based models locally. Useful for generating text embeddings directly in R.

## Features

- Download BERT models directly from Hugging Face Hub
- Run BERT sentence embedding locally

## Installation

- R (>= 4.2)
- Rust toolchain (cargo, rustc) for local compiling

```r
# Clone repo and then install from source
install.packages("./", repo = NULL, type = "source")
# or use
devtools::install()
```

*note* The debug flag in `tools/config.R` is turned off (hard coded) to get the faster rust `--release` builds. This ensures optimal performance for the Rust backend.

## Quick Start

### 1. Get a Model

Any bert based Model with the following files is supported:
- config.json
- tokenizer.json
- model.safetensor

You can download these from the Hugging Face Hub with the convenience function `download_model()`. By default the model will be downloaded to home/.chache/runSentenceTransformer/..., you can provide a different path if you want to `(model_path = ...)`.:

```r
library(runSentenceTransformer)

# Download a popular sentence transformer model
download_model("sentence-transformers/all-MiniLM-L6-v2")
```
Tested models are:
- sentence-transformers/all-MiniLM-L6-v2

### 2. Generate Embeddings

Once the model is downloaded, you can generate embeddings for your text:

```r
# Generate embeddings directly
texts <- c("Hello world", "How are you?", "This is a sample sentence.")
embeddings <- embed(texts, "sentence-transformers/all-MiniLM-L6-v2")

# View the dimensions of the embeddings
dim(embeddings)
```
## How It Works

The package leverages Rust for performance-critical operations:

1. **R Frontend**: R functions handle user interface, model downloading, and path management
2. **Rust Backend**: Text processing (tokenization) and embedding (neral network inference) generation using Candle (Rust ML framework).
3. **ExtendR**: Integration between R and Rust via the extendr-api crate and rextendr R-package

## Limitations

The package only supports BERT-based models with all of these three files:
- config.json
- tokenizer.json
- model.safetensor

Running other models seems to be feasible but outside the scope of this project. Steps needed are:
- Updating rust backend to handle different models.
- Updating the R-download function to handle different files.

## License

GNU General Public License
