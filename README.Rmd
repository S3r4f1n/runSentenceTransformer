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
