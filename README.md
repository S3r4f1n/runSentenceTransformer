---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

# runSentenceTransformer

An R package that provides access to sentence transformer models using Rust backend for high-performance text embeddings. The package enables users to download, load, and use BERT-based models from Hugging Face for generating text embeddings directly in R (through extendr/rextendr).

## Features

- Download BERT models directly from Hugging Face Hub
- Support for BERT-based models with mean pooling
- High-performance text processing using Rust backend
- Easy integration with R workflows
- Local model caching for faster subsequent access

## Installation

To install this package, you'll need:

- R (>= 4.2)
- Rust toolchain (cargo, rustc) for local compiling
- Internet connection for downloading models (first use)

```r
# Clone repo and then install from source
devtools::install()
```

*note* The debug flag in `tools/config.R` is turned off (hard coded) to get the faster rust `--release` builds. This ensures optimal performance for the Rust backend and is only needed due to rextendr.

## Quick Start

### 1. Download a Model

First, download a BERT-based sentence transformer model from Hugging Face:

```r
library(runSentenceTransformer)

# Download a popular sentence transformer model
download_model("sentence-transformers/all-MiniLM-L6-v2")
```

### 2. Generate Embeddings

Once the model is downloaded, you can generate embeddings for your text:

```r
# Generate embeddings directly
texts <- c("Hello world", "How are you?", "This is a sample sentence.")
embeddings <- embed(texts, "sentence-transformers/all-MiniLM-L6-v2")

# View the dimensions of the embeddings
dim(embeddings)
```

### 3. Create an Embedding Function

Alternatively, you can create a dedicated embedding function:

```r
# Create an embedding function for reuse
embed_func <- load_model_get_embed_function("sentence-transformers/all-MiniLM-L6-v2")

# Use the embedding function
my_texts <- c("Sample text 1", "Sample text 2")
results <- embed_func(my_texts)
```

## Main Functions

### `download_model(model, model_path)`
Downloads a model from Hugging Face Hub to the local cache directory. The function downloads necessary files such as `config.json`, `tokenizer.json`, and `model.safetensors`.

### `embed(data, model, model_path)`
Generates embeddings for character vectors using a specified model. This is the primary function for converting text to numerical embeddings.

### `load_model_get_embed_function(model, model_path)`
Loads a model from disk and returns a function that can be used to generate embeddings. Useful when you need to repeatedly embed text with the same model.

### `local_model_path(model_identifier, create_dir)`
Manages the local path where models are stored in the cache directory. Creates the path structure if it doesn't exist.

## Supported Models

Currently, the package supports BERT-based models that have the following files:
- `config.json` - Model configuration
- `tokenizer.json` - Tokenizer configuration and vocabulary
- `model.safetensors` - Model weights in safetensors format

Popular compatible models include:
- `sentence-transformers/all-MiniLM-L6-v2`
- `sentence-transformers/all-mpnet-base-v2`
- `sentence-transformers/bert-base-nli-mean-tokens`

## How It Works

The package leverages Rust for performance-critical operations:

1. **R Frontend**: R functions handle user interface, model downloading, and path management
2. **Rust Backend**: High-performance text processing and embedding generation using Candle (Rust ML framework)
3. **ExtendR**: Seamless integration between R and Rust via the extendr-api crate

The Rust backend handles the heavy lifting of tokenization and neural network inference, ensuring fast and efficient embedding generation.

## Model Architecture

The package currently supports BERT-based models with mean pooling for sentence embeddings:
- Input text is tokenized using the model's tokenizer
- BERT model processes the tokens to generate contextual embeddings
- Mean pooling is applied across the sequence dimension to create a fixed-size sentence embedding
- The final embedding represents the semantic meaning of the input text

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests on GitHub.

## License

GNU General Public License
