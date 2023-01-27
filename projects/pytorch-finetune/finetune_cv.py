from __future__ import annotations
import logging
import re
import sys
import collections
from typing import Optional
from datasets import load_dataset
from huggingsound import TrainingArguments, ModelArguments, SpeechRecognitionModel, TokenSet

import os
###########################################################################################################

# Leo, precisa rodar a instalação dessas dependências:
# pip install huggingsound
# pip install torchaudio

# ... E precisa modificar o path desses diretorios para um lugar onde o container possa armazenar alguns gigas de dados

SCRATCH_DIR = "/scratch/" + os.environ['USER']
DATASET_CACHE_DIR = SCRATCH_DIR + "/pytorch-finetune/cache"
MODEL_OUTPUT_DIR = SCRATCH_DIR + "/pytorch-finetune/output"

# Se tudo der certo vai legar algum tempo o treinamento do modelo e no final vai aparecer uma mensagem "Fine-tuning Finished!" no console

###########################################################################################################


TRAIN_STEPS = 4000
MIN_SAMPLE_SIZE_IN_SECONDS = 1
MAX_SAMPLE_SIZE_IN_SECONDS = 12
MAX_TRAIN_SIZE = 1000
TRAIN_BATCH_SIZE = 16
DEVICE = "cuda"
PRETRAINED_MODEL = "facebook/wav2vec2-xls-r-300m"


logging.basicConfig(
    format="%(asctime)s - %(levelname)s - %(name)s -   %(message)s",
    datefmt="%m/%d/%Y %H:%M:%S",
    handlers=[logging.StreamHandler(sys.stdout)],
)
LOGGER = logging.getLogger(__name__)
LOGGER.setLevel(logging.INFO)


def get_token_set(sentences: list[str], min_char_occurrence_ratio: Optional[float] = 0.00001,
                   nonalpha_chars_to_keep: Optional[list[str]] = None, letter_case: Optional[str] = "lowercase") -> TokenSet:

    if nonalpha_chars_to_keep is None:
        nonalpha_chars_to_keep = []

    corpus = re.sub("\s", "", " ".join(sentences))
    if letter_case == "lowercase":
        corpus = corpus.lower()
    elif letter_case == "uppercase":
        corpus = corpus.upper()

    min_char_occurrence = int(min_char_occurrence_ratio * len(corpus)) if min_char_occurrence_ratio is not None else 1

    if min_char_occurrence > 1:
        character_counter = collections.Counter(corpus)
        tokens = [character for character, count in character_counter.items() if count >= min_char_occurrence]
    else:
        tokens = list(set(corpus))

    tokens = sorted(filter(lambda x: x.isalpha() or x in nonalpha_chars_to_keep, tokens))
    tokens = ["<pad>", "<s>", "</s>", "<unk>", "|"] + tokens

    return TokenSet(tokens, letter_case=letter_case)


def get_filtered_data(dataset):

    filtered_data = []
    total_duration = 0

    for item in dataset.shuffle():

        duration = len(item["audio"]["array"]) / item["audio"]["sampling_rate"]

        if duration < MIN_SAMPLE_SIZE_IN_SECONDS or duration > MAX_SAMPLE_SIZE_IN_SECONDS:
            continue

        filtered_data.append({"path": item["path"], "transcription": item["sentence"]})
        total_duration += duration

        if total_duration >= MAX_TRAIN_SIZE:
            break

    return filtered_data


LOGGER.info("Loading data")

dataset = load_dataset("common_voice", "pt", cache_dir=DATASET_CACHE_DIR)

token_set = get_token_set(dataset["train"]["sentence"])

filtered_data = get_filtered_data(dataset["train"])

LOGGER.info("Setting configs")

training_args = TrainingArguments(
    max_steps=TRAIN_STEPS,
    per_device_train_batch_size=TRAIN_BATCH_SIZE,
    pad_to_multiple_of=8,
    show_dataset_stats=False,
)
model_args = ModelArguments(
    freeze_feature_extractor = True,
    ctc_zero_infinity = True,
    ctc_loss_reduction = "mean",
)

LOGGER.info("Loading model")

model = SpeechRecognitionModel(PRETRAINED_MODEL, device=DEVICE)

LOGGER.info("Fine-tuning")

model.finetune(
    MODEL_OUTPUT_DIR,
    train_data=filtered_data,
    token_set=token_set,
    training_args=training_args,
    model_args=model_args,
    num_workers=4
)

LOGGER.info("Fine-tuning Finished!")
