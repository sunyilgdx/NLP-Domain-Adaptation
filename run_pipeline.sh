#!/bin/zsh
FINE_TUNE_DATASET="linnaeus"
PCT=2
MOD="similar"

CORPUS="data/biology/corpus/subsets/pubmed_corpus_${MOD}_jensen-shannon_${FINE_TUNE_DATASET}_train_0.02pct.txt"
FINE_TUNE_TEXT="data/biology/corpus/${FINE_TUNE_DATASET}_train.txt"
EVAL_CORPUS="data/biology/corpus/${FINE_TUNE_DATASET}_dev.txt"
TASK_DIR="data/biology/tasks/$FINE_TUNE_DATASET"
OUTPUT_DIR="results/$FINE_TUNE_DATASET/pubmed_${PCT}pct_${MOD}"
MAX_STEPS="128194"

# NER fine tuning args
export MAX_LENGTH=128
export NUM_EPOCHS_NER=25

# Run domain adaptation
./domain_adaptation_pipeline.sh \
    --corpus $CORPUS \
    --eval-corpus $EVAL_CORPUS \
    -o $OUTPUT_DIR \
    --overwrite-output-dir \
    --fine-tune-data-dir $TASK_DIR \
    --max-steps $MAX_STEPS \
    --batch-size 8 \
    --save-steps 2500 \
    --skip-augment-vocab \
    --skip-domain-pre-train \
    -v
./scripts/sync_tb_logs.sh $OUTPUT_DIR

# Run end-of-training sync
aws s3 sync $OUTPUT_DIR/fine-tuned \
    "s3://nlp-domain-adaptation/runs/$FINE_TUNE_DATASET/$(basename $OUTPUT_DIR)/fine-tuned"
