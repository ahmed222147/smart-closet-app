from outfit_model import OutfitMatchingModel
import json

def run_prediction(features):
    model = OutfitMatchingModel()
    model.setup()
    result = model.predict(features)
    print(result)

if __name__ == "__main__":
    # Sample input
    features = {
        "text_a": "White blouse with floral pattern",
        "image_url": "path_or_url_to_image.jpg"
    }
    run_prediction(features)
