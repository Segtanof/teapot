#!/bin/bash
#SBATCH --job-name=2
#SBATCH --nodes=1              # Keep 1 node
#SBATCH --ntasks=1             # Single task
#SBATCH --cpus-per-task=2     # Increase to 12 CPUs for better I/O and orchestration
#SBATCH --gres=gpu:1           # Keep 1 GPU (H100 is sufficient)
#SBATCH --mem=4G              # Increase to 32 GB RAM for model transitions
#SBATCH --time=04:00:00        # Increase to 3 hours for 2,580 inferences
#SBATCH --output=outputs/output_%j.log
#SBATCH --error=outputs/error_%j.log

# Load ollama module
module load cs/ollama

# Initialize Conda
source /opt/bwhpc/common/devel/miniconda/23.9.0-py3.9.15/etc/profile.d/conda.sh

# Activate the test environment
conda activate test

# Set Ollama environment variable to keep model loaded
export OLLAMA_DEBUG=true
export OLLAMA_KEEP_ALIVE="4h"
export OLLAMA_NUM_PARALLEL=12    # Max parallelism
export OLLAMA_MAX_QUEUE=512
export OLLAMA_CTX_SIZE=16384

# Start Ollama server in the background
ollama serve &
OLLAMA_PID=$!
sleep 5  # Wait for server to initialize

# Monitor GPU usage
nvidia-smi 
free -h
NVIDIA_PID=$!

# Run Python script
timeout 7200 python /pfs/work7/workspace/scratch/ma_ssiu-myspace/Teapot/2_optimized1.py
# Clean up
kill $NVIDIA_PID
kill $OLLAMA_PID