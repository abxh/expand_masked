# expand_masked

See the considerations that went into this design [here](https://github.com/diku-dk/segmented/pull/13).

## Benchmarks

Both benchmarks are carried out on the cuda backend. Note, the implementation assumes
calls to `pred` is cheap, as it sequentially calls up to 64 `pred` at a time.

On an Nvidia A100 with 1M elements, `expand_masked` shows an increasingly large
speedup as segment size increases, reaching 2x speedup at segment size 1024.

```
bench.fut:bench_masked (no tuning file):
gen 1000000i64 0i64 8i64:           641μs (95% CI: [     640.8,      641.8])
gen 1000000i64 0i64 16i64:          791μs (95% CI: [     790.3,      791.0])
gen 1000000i64 0i64 32i64:         1035μs (95% CI: [    1031.0,     1051.3])
gen 1000000i64 0i64 64i64:         1548μs (95% CI: [    1547.3,     1549.0])
gen 1000000i64 0i64 128i64:        2807μs (95% CI: [    2803.6,     2816.6])
gen 1000000i64 0i64 256i64:        5292μs (95% CI: [    5282.2,     5328.5])
gen 1000000i64 0i64 512i64:       10203μs (95% CI: [   10190.3,    10221.6])
gen 1000000i64 0i64 1024i64:      20008μs (95% CI: [   19992.5,    20034.4])

bench.fut:bench_filter (no tuning file):
gen 1000000i64 0i64 8i64:           653μs (95% CI: [     649.3,      663.0])
gen 1000000i64 0i64 16i64:         1081μs (95% CI: [    1080.1,     1082.5])
gen 1000000i64 0i64 32i64:         1844μs (95% CI: [    1842.8,     1844.7])
gen 1000000i64 0i64 64i64:         3412μs (95% CI: [    3410.2,     3412.9])
gen 1000000i64 0i64 128i64:        6443μs (95% CI: [    6440.1,     6446.6])
gen 1000000i64 0i64 256i64:       12462μs (95% CI: [   12456.8,    12467.0])
gen 1000000i64 0i64 512i64:       24474μs (95% CI: [   24464.5,    24483.0])
gen 1000000i64 0i64 1024i64:      48549μs (95% CI: [   48531.6,    48564.2])
```
