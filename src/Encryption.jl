module Encryption
export rustiefel, encrypt, make_blocksizes, data_blocks, generate_key

using LinearAlgebra

import Random

"""
    rustiefel(rows[, rng=GLOBAL_RNG])

Return a `rows`-by-`rows` square orthonormal matrix.

Optionally provide the RNG to use.
"""
function rustiefel(rows; rng=Random.GLOBAL_RNG)
    X = randn(rng, rows, rows)
    eig = eigen(transpose(X) * X)
    # use sqrt(abs) in case of extremely small negative values/rounding errors
    X * (eig.vectors * sqrt.(abs.(diagm(0 => 1 ./ eig.values))) * transpose(eig.vectors))
end

"""
    make_blocksizes(N, blocksize)

Return an array of block sizes for a dataset of `N` rows,
where all but possibly the last block size is `blocksize`.

If 0 < `blocksize` < `N` isn't the case, a single block
of size `N` is used.
"""
function make_blocksizes(N, blocksize)
    bsize = max(0, min(N, blocksize))
    reg_rows = bsize * div(N, bsize)
    reg_count = div(reg_rows, bsize)
    last_size = N - reg_rows

    blocksizes = fill(blocksize, reg_count)
    if last_size != 0
        push!(blocksizes, last_size)
    end

    blocksizes
end

"""
    generate_key(N, blocksize[, rng=GLOBAL_RNG])

Generate a list of encryption key blocks of size `blocksize` to use
with a dataset of `N` rows, see `make_blocksizes` and `rustiefel` for
details.

Optionally provide the RNG to use.
"""
function generate_key(N, blocksize; rng=Random.GLOBAL_RNG)
    map(r -> rustiefel(r, rng=rng), make_blocksizes(N, blocksize))
end


function get_blocksizes(key)
    map(x -> size(x)[1], key)
end

"""
    data_blocks(data, blocksizes)

Split `data` into several blocks using the provided `blocksizes`
array.
"""
function data_blocks(data, blocksizes)
    (N, _) = size(data)
    bs_start = 1
    ix = []
    for (bs, i) in zip(blocksizes, 1:length(blocksizes))
        push!(ix, (bs_start, bs+bs_start-1))
        bs_start += bs
    end

    map(iv -> data[iv[1]:iv[2],:], ix)
end

"""
    encrypt(data, key)

Encrypts the dataset `data` using `key`. See `generate_key`.

The output has the same shape as `data`.
"""
function encrypt(data, key)
    blocksizes = get_blocksizes(key)
    blocked_data = data_blocks(data, blocksizes)

    result = []
    for (d, k) in zip(blocked_data, key)
        push!(result, k*d)
    end

    vcat(result...)
end

end
