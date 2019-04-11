#!/bin/bash
# Copyright 2017 Beijing Shell Shell Tech. Co. Ltd. (Authors: Hui Bu)
#           2017 Jiayu Du
#           2017 Chao Li
#           2017 Xingyu Na
#           2017 Bengu Wu
#           2017 Hao Zheng
# Apache 2.0

# This is a shell script that we demonstrate speech recognition using AIShell-1 data.
# it's recommended that you run the commands one by one by copying and pasting into the shell.
# See README.txt for more info on data required.
# Results (EER) are inline in comments below

. ./cmd.sh
. ./path.sh

guss_num=512
ivector_dim=200
lda_dim=50
nj=10
exp=exp/ivector_gauss${guss_num}_dim${ivector_dim}

set -e # exit on error

####### Bookmark: scp prep #######

local/timit_data_prep.sh ~/data/timit_sre/wav

###### Bookmark: MFCC extraction ######

mfccdir=mfcc
for x in train test; do
  steps/make_mfcc.sh --cmd "$train_cmd" --nj $nj data/$x exp/make_mfcc/$x $mfccdir
  sid/compute_vad_decision.sh --nj $nj --cmd "$train_cmd" data/$x exp/make_mfcc/$x $mfccdir
  utils/fix_data_dir.sh data/$x
done

###### Bookmark: split the test to enroll and eval ######
mkdir -p data/test/enroll data/test/eval
cp data/test/{spk2utt,feats.scp,vad.scp} data/test/enroll
cp data/test/{spk2utt,feats.scp,vad.scp} data/test/eval
local/split_data_enroll_eval.py data/test/utt2spk  data/test/enroll/utt2spk  data/test/eval/utt2spk
trials=data/test/test.trials
local/produce_trials.py data/test/eval/utt2spk $trials
utils/fix_data_dir.sh data/test/enroll
utils/fix_data_dir.sh data/test/eval

###### Bookmark: i-vector train ######
# train diag ubm
sid/train_diag_ubm.sh --nj $nj --cmd "$train_cmd" --num-threads 16 \
  data/train $guss_num $exp/diag_ubm
#train full ubm
sid/train_full_ubm.sh --nj $nj --cmd "$train_cmd" data/train \
  $exp/diag_ubm $exp/full_ubm

#train ivector
sid/train_ivector_extractor.sh --cmd "$train_cmd" \
  --ivector-dim $ivector_dim --num-iters 5 $exp/full_ubm/final.ubm data/train \
  $exp/extractor

###### Bookmark: i-vector extraction ######
#extract train ivector
sid/extract_ivectors.sh --cmd "$train_cmd" --nj $nj \
  $exp/extractor data/train $exp/ivector_train
#extract enroll ivector
sid/extract_ivectors.sh --cmd "$train_cmd" --nj $nj \
  $exp/extractor data/test/enroll  $exp/ivector_enroll
#extract eval ivector
sid/extract_ivectors.sh --cmd "$train_cmd" --nj $nj \
  $exp/extractor data/test/eval  $exp/ivector_eval

###### Bookmark: scoring ######

# basic cosine scoring on i-vectors
local/cosine_scoring.sh data/test/enroll data/test/eval \
  $exp/ivector_enroll $exp/ivector_eval $trials $exp/scores

# cosine scoring after reducing the i-vector dim with LDA
local/lda_scoring.sh data/train data/test/enroll data/test/eval \
  $exp/ivector_train $exp/ivector_enroll $exp/ivector_eval $trials $exp/scores $lda_dim

# cosine scoring after reducing the i-vector dim with PLDA
local/plda_scoring.sh data/train data/test/enroll data/test/eval \
  $exp/ivector_train $exp/ivector_enroll $exp/ivector_eval $trials $exp/scores

# print eer
for i in cosine lda plda; do
  eer=`compute-eer <(python local/prepare_for_eer.py $trials $exp/scores/${i}_scores) 2> /dev/null`
  printf "%15s %5.2f \n" "$i eer:" $eer
done > $exp/scores/results.txt

cat $exp/scores/results.txt

exit 0
