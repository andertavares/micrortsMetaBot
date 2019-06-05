#!/bin/bash

SCRIPT_PATH=rlexperiment.sh

DEFAULT_DIR="experiments"
DEFAULT_BIN_PREFIX="binWeights"
DEFAULT_HUMAN_PREFIX="humanWeights"

# Argument Parser
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--number-experiments)
    N_EXPERIMENTS="$2"
    shift # past argument
    shift # past value
    ;;
    -bs|--batch-size)
    BATCH_SIZE="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--directory)
    DIR="$2"
    shift # past argument
    ;;
    -c|--config)
    CONFIG="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--bin-prefix)
    BIN_PREFIX="$2"
    shift # past argument
    ;;
    -h|--humanprefix)
    HUMAN_PREFIX="$2"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Check if the number of repetitions was set
if [ -z "$N_EXPERIMENTS" ]
then
    echo "Error: Number of repetitions not set. Use -n to set the number of repetitions."
    exit 1
fi

# Check if the directory was set
if [ -z "$DIR" ]
then
    echo "Warning: Directory not set. Using default directory \"$DEFAULT_DIR\". Use -d to set the directory."
    DIR=$DEFAULT_DIR
fi

# Check if the batch size was set
if [ -z "$BATCH_SIZE" ]
then
    echo "Batch size not set. Experiments will be run serially."
    BATCH_SIZE=1
fi

# Check if the binprefix was set
if [ -z "$BIN_PREFIX" ]
then
    echo "Binary prefix not set. Using default value \"$DEFAULT_BIN_PREFIX\"."
    BIN_PREFIX=$DEFAULT_BIN_PREFIX
fi

# Check if the human was set
if [ -z "$HUMAN_PREFIX" ]
then
    echo "Human prefix not set. Using default value \"$DEFAULT_HUMAN_PREFIX\"."
    HUMAN_PREFIX=$DEFAULT_HUMAN_PREFIX
fi

echo "Creating directories..."
mkdir -p "$DIR"
for i in $(seq 0 $(("$N_EXPERIMENTS"-1))); do
    mkdir -p "$DIR"/rep_"$i"
done
echo "Done."

# Check if config file was passed
[ ! -z "$CONFIG" ] && CONFIG_PATH="-c $CONFIG"

echo "Lauching $N_EXPERIMENTS experiment(s)..."
for i in $(seq 0 $(($N_EXPERIMENTS-1))); do
    ((j=j%"$BATCH_SIZE")); ((j++==0)) && wait
    echo "Lauching experiment $i..."
    . "$SCRIPT_PATH" -s "$i" -b "$DIR"/rep_"$i"/"$BIN_PREFIX" -h "$DIR"/rep_"$i"/"$HUMAN_PREFIX" "$CONFIG_PATH" >> "$DIR"/rep_"$i"/rep_"$i".log &
done
wait
echo "Done."