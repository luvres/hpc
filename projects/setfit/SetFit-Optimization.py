import os
import time
import argparse
import numpy as np
from pandas import read_parquet
from datasets import Dataset, DatasetDict
from setfit import SetFitModel, SetFitTrainer
from sentence_transformers.losses import CosineSimilarityLoss


# Environment variable
USER = os.environ['USER']

parser = argparse.ArgumentParser(description="Prepared Adapter")
parser.add_argument('--dataframe_path', type=str, default='/scratch/luvres')
parser.add_argument('--dataframe_name', type=str, default='decisoes-ohe-root-text-explode-clean-10w-samples1000.parquet')
parser.add_argument('--model_path', type=str, default='Sentence_Similarity')
parser.add_argument('--model_name', type=str, default='paraphrase-multilingual-mpnet-base-v2')
parser.add_argument('--num_samples', type=int, default=8)
parser.add_argument('--n_trials', type=int, default=2)
parser.add_argument('--inference', type=str, nargs='+', default="O filho do meu vizinho quebrou a minha janela")
args = parser.parse_args()

dataframe_path = args.dataframe_path
dataframe_name = args.dataframe_name
model_name = args.model_name
model_path = args.model_path
num_samples = args.num_samples
n_trials = args.n_trials
inference = args.inference

# Functions
def make_model(params=None):
    multi_target_strategy = params['multi_target_strategy'] if params else 'one-vs-rest'
    return SetFitModel.from_pretrained(
        model_id, multi_target_strategy=multi_target_strategy
    )

def hyperparameter_search_function(trial):
    return {
        'learning_rate': trial.suggest_float('learning_rate', 1e-5, 1e-3, log=True),
        'batch_size': trial.suggest_categorical('batch_size', [4, 8, 16, 32, 64]),
        'num_epochs': trial.suggest_int('num_epochs', 1, 5),
        'num_iterations': trial.suggest_categorical('num_iterations', [5, 10, 20]),
        'multi_target_strategy': trial.suggest_categorical('multi_target_strategy', ['one-vs-rest','multi-output','classifier-chain']),
    }

def format_time(time_seconds):
    days, remainder = divmod(time_seconds, 86400)  # 86400 seconds in a day
    hours, remainder = divmod(remainder, 3600)
    minutes, seconds = divmod(remainder, 60)
    result = ""
    if days > 0:
        result += f'{int(days)}d '
    if hours > 0:
        result += f'{int(hours)}h '
    if minutes > 0 or hours > 0 or days > 0:
        result += f'{int(minutes)}min '
    result += f'{int(seconds)}s'
    return result


# << Start time >>
start_time = time.time()

# 1) Load dataset
dataframe = read_parquet(f'{dataframe_path}/{dataframe_name}')

dataset = DatasetDict({
    'train': Dataset.from_pandas(dataframe)
})

features = dataset['train'].column_names[:-1]
features.remove('text')

samples = np.concatenate([np.random.choice(np.where(dataset['train'][f])[0], num_samples) for f in features])

train_dataset = dataset['train'].select(samples)
eval_dataset = dataset['train'].select(np.setdiff1d(np.arange(len(dataset['train'])), samples))

# 2) Load model
model_id = f"/scratch/LLM/{model_path}/{model_name}"

trainer = SetFitTrainer(
    model_init=make_model,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    loss_class=CosineSimilarityLoss,
    # num_epochs=1,
    # num_iterations=5,
    column_mapping={'text': 'text', 'labels': 'label'},
)

best = trainer.hyperparameter_search(hyperparameter_search_function, n_trials=n_trials)

# 3) Train model
trainer.apply_hyperparameters(best.hyperparameters, final_model=True)
trainer.train()

# Metrics
metrics = trainer.evaluate()

# Prediction
preds = trainer.model(inference)
classifiers = [[f for f,p in zip(features, ps) if p] for ps in preds]

# >> End time <<
end_time = time.time()
execution_time = (end_time - start_time)
formatted_time = format_time(execution_time)

# Shows
print(f'\nBest Hyperparameters: \n{best}')
print(f'\nMetrics: \n{best.objective} {metrics}')
print(f'\nPrediction: \n{preds}')
print(f'\nClass: \n{classifiers}')
print(f"\nExecution time: {formatted_time}")


# # Save model
# import joblib

# save_model_path = '/scratch/luvres'
# joblib.dump(trainer, f'{path}/setfit_opt.joblib')

# # Reload model
# load_model = joblib.load(f'{path}/setfit_opt.joblib')

# inference = [
#     "O filho do meu vizinho quebrou a minha janela",
#     "Como se aplica uma ação de desapropriação"
# ]

# preds = load_model.model.predict(inference)

# classifiers = [[f for f,p in zip(features, ps) if p] for ps in preds]

