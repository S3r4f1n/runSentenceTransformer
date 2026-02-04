use anyhow::Result;
use anyhow::bail;
use std::path::Path;
use candle_core::{Device, Tensor, DType};
use candle_nn::VarBuilder;
use candle_transformers::models::bert::{BertModel, Config};
use tokenizers::Tokenizer;
use std::path::PathBuf;

pub struct BertModelWrapper {
    model: BertModel,
    tokenizer: Tokenizer,
    device: Device,
}

impl BertModelWrapper {
    pub fn load(model_id: &str) -> Result<Self> {
        let device = Device::Cpu;

        let (config_path, tokenizer_path, weights_path) = load_bert_model(model_id)?;

        // config
        let config: Config = serde_json::from_slice(&std::fs::read(&config_path)?)?;

        // tokenizer
        let tokenizer =
            Tokenizer::from_file(&tokenizer_path).map_err(candle_core::Error::wrap)?;

        // weights
        let weights = candle_core::safetensors::load(&weights_path, &device)?;
        let vb = VarBuilder::from_tensors(weights, DType::F32, &device);

        let model = BertModel::load(vb, &config)?;

        Ok(Self {
            model,
            tokenizer,
            device,
        })
    }
}

impl BertModelWrapper {
    pub fn embed(&self, text: &str) -> anyhow::Result<Vec<f32>> {
        let tokens = self
            .tokenizer
            .encode(text, true)
            .map_err(|e| candle_core::Error::Msg(e.to_string()))?;

        let input_ids: Vec<u32> =
            tokens.get_ids().iter().map(|&x| x as u32).collect();
        let attention_mask: Vec<u32> =
            tokens.get_attention_mask().iter().map(|&x| x as u32).collect();

        let input_ids =
            Tensor::new(&input_ids[..], &self.device)?.unsqueeze(0)?;
        let attention_mask =
            Tensor::new(&attention_mask[..], &self.device)?.unsqueeze(0)?;

        let token_embeddings =
            self.model.forward(&input_ids, &attention_mask, None)?;

        // mean pooling
        let mask = attention_mask
            .to_dtype(DType::F32)?
            .unsqueeze(2)?;

        let (_b, seq_len, hidden_size) = token_embeddings.dims3()?;
        let mask = mask.broadcast_as((1, seq_len, hidden_size))?;

        let masked = (&token_embeddings * &mask)?;
        let sum_embeddings = masked.sum(1)?;
        let mask_sum = mask.sum(1)?;

        let ones =
            Tensor::ones((1, hidden_size), DType::F32, &self.device)?;
        let mask_sum = mask_sum.maximum(&ones)?;

        let sentence_embeddings =
            sum_embeddings.broadcast_div(&mask_sum)?;

        Ok(sentence_embeddings.squeeze(0)?.to_vec1()?)
    }
}

pub fn load_bert_model(model_id: &str) -> Result<(PathBuf, PathBuf, PathBuf)> {
    let path = Path::new(model_id);

    if !path.exists() {
        bail!("The path {:?} does not exist", path);
    }
    if !path.is_dir() {
        bail!("The path {:?} exists but is not a directory", path);
    }

    let config_path = path.join("config.json");
    let tokenizer_path = path.join("tokenizer.json");
    let weights_path = path.join("model.safetensors");

    // Check that the files actually exist
    for (file, name) in [
        (&config_path, "config.json"),
        (&tokenizer_path, "tokenizer.json"),
        (&weights_path, "model.safetensors"),
    ] {
        if !file.exists() {
            bail!("Expected file {:?} ({}) does not exist", file, name);
        }
    }

    Ok((config_path, tokenizer_path, weights_path))
}

