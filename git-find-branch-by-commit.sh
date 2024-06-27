#!/bin/bash

# Check if a commit hash is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <commit-hash>"
    exit 1
fi

# Get the full commit hash
commit_hash=$(git rev-parse "$1")

# Fetch the latest information from the remote
git fetch --all > /dev/null 2>&1

# Function to find branch
find_branch() {
    local branch_type=$1
    git for-each-ref $branch_type --format="%(refname:short) %(objectname)" | while read branch hash; do
        if [ "$hash" = "$commit_hash" ]; then
            echo $branch
            return 0
        fi
    done
    return 1
}

# Check local branches
local_branch=$(find_branch "refs/heads")
if [ -n "$local_branch" ]; then
    echo "The commit $commit_hash is the last commit on local branch: $local_branch"
    exit 0
fi

# Check remote branches
remote_branch=$(find_branch "refs/remotes")
if [ -n "$remote_branch" ]; then
    echo "The commit $commit_hash is the last commit on remote branch: $remote_branch"
    exit 0
fi

echo "No branch found with $commit_hash as the last commit."
