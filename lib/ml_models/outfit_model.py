from easytransfer import base_model, model_zoo, preprocessors

class OutfitMatchingModel(base_model):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.pretrained_model_name = "fashion_bert"

    def build_logits(self, features, mode=None):
        preprocessor = preprocessors.get_preprocessor(self.pretrained_model_name)
        model = model_zoo.get_pretrained_model(self.pretrained_model_name)
        input_ids, input_mask, segment_ids, image_patches = preprocessor(features)
        _, pooled_output = model(
            [input_ids, input_mask, segment_ids, image_patches], mode=mode
        )
        return pooled_output  # vector embedding
