cairo-compile contracts/verify.cairo --output artifacts/verify.json &&
    cairo-run --program=artifacts/verify.json \
        --print_output --layout=small
