import os
import numpy as np
import onnxruntime as ort
from transformers import BertTokenizer

# Load tokenizer (make sure this matches your model)
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")

# Sentence to encode
sentence = "This is a great fashion piece"
tokens = tokenizer(sentence, return_tensors="np")

print("Tokens:", tokens)

# Load the ONNX model
model_path = "fashionbert.onnx"
session = ort.InferenceSession(model_path)

# Get input and output names
input_names = {inp.name for inp in session.get_inputs()}
output_name = session.get_outputs()[0].name

# Make sure attention_mask and input_ids are passed
inputs = {k: tokens[k] for k in input_names}

# Run inference
outputs = session.run([output_name], inputs)

# Extract [CLS] token embedding
embedding = outputs[0][:, 0, :]  # Shape: (1, 768)
print("CLS Embedding Shape:", embedding.shape)

# Save the embedding
np.save("fashion_sentence_embedding.npy", embedding)
print("Saved to fashion_sentence_embedding.npy")
