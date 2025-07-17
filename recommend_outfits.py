import numpy as np
import onnxruntime as ort
from transformers import BertTokenizer
from sklearn.metrics.pairwise import cosine_similarity

# === Load outfit database ===
outfits = [
    "This red dress is elegant and trendy.",
    "Comfortable cotton t-shirt for summer.",
    "High-waisted jeans are back in style.",
    "These leather boots are great for winter.",
    "Casual outfits are perfect for daily wear."
]

# === Load saved embeddings for these outfits ===
outfit_embeddings = np.load("fashion_embeddings.npy")

# === Load tokenizer and model ===
tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
session = ort.InferenceSession("fashionbert.onnx")
input_names = {inp.name: inp.name for inp in session.get_inputs()}
output_name = session.get_outputs()[0].name

# === Ask user for a styling query ===
user_input = input("👤 What kind of outfit are you looking for? ")

# === Tokenize the user input ===
tokens = tokenizer(
    user_input,
    padding='max_length',
    max_length=16,
    truncation=True,
    return_tensors='np'
)

# === Get embedding for the query ===
output = session.run([output_name], {
    input_names['input_ids']: tokens['input_ids'],
    input_names['attention_mask']: tokens['attention_mask']
})

query_embedding = output[0][:, 0, :]  # [CLS] token

# === Calculate cosine similarity with outfit embeddings ===
similarities = cosine_similarity(query_embedding, outfit_embeddings)[0]  # shape (5,)

# === Recommend top 3 outfits ===
top_indices = similarities.argsort()[::-1][:3]

print("\n👗 Recommended outfits for you:")
for i in top_indices:
    print(f"- {outfits[i]} (score: {similarities[i]:.2f})")
