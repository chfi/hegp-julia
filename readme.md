# Julia implementation of homomorphic encryption of genotypes and phenotypes (HEGP)

## Usage

Include the `src/HEGP.jl` module, and use the `generate_key` and `encrypt` functions to encrypt your data.

Data can be any numerical vector or matrix with the same number of rows as the key.

Example usage:
```julia
include("src/HEGP.jl")

# Randomly generated plaintext, a 10000x500 matrix of numbers
plaintext = randn(10000, 500)

# Generate a key for a dataset consisting of 10000 rows, in blocks of 2500 rows:
key = HEGP.generate_key(10000, 2500)
# Encrypt
ciphertext = HEGP.encrypt(key, plaintext)

```

When encrypting genotype and phenotype data, use the same key for both.
