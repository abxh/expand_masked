# expand_masked

See the considerations that went into this design [here](https://github.com/diku-dk/segmented/pull/13).

## Benchmarks

Both benchmarks are carried out on the cuda backend. Note, the implementation assumes
calls to `pred` is cheap, as it sequentially calls up to 64 `pred` at a time.

On an Nvidia M2000M with `1000000` elements, `expand_masked` provides a 2x speedup
over the naive expand-filter.
```
bench.fut:bench_masked (no tuning file):
(8i64, gen 100000i64 0i64 8i64):            727μs (95% CI: [     717.5,      737.4])
(16i64, gen 100000i64 0i64 16i64):         1158μs (95% CI: [    1143.9,     1173.6])
(32i64, gen 100000i64 0i64 32i64):         2073μs (95% CI: [    2053.1,     2095.4])
(64i64, gen 100000i64 0i64 64i64):         4283μs (95% CI: [    4250.8,     4321.1])
(128i64, gen 100000i64 0i64 128i64):      13297μs (95% CI: [   13228.4,    13367.6])
(256i64, gen 100000i64 0i64 256i64):      25641μs (95% CI: [   25570.6,    25742.0])

bench.fut:bench_filter (no tuning file):
(8i64, gen 100000i64 0i64 8i64):           1331μs (95% CI: [    1314.2,     1349.9])
(16i64, gen 100000i64 0i64 16i64):         2212μs (95% CI: [    2185.3,     2241.9])
(32i64, gen 100000i64 0i64 32i64):         3859μs (95% CI: [    3826.1,     3895.8])
(64i64, gen 100000i64 0i64 64i64):         7051μs (95% CI: [    7002.0,     7108.3])
(128i64, gen 100000i64 0i64 128i64):      14144μs (95% CI: [   14050.6,    14246.2])
(256i64, gen 100000i64 0i64 256i64):      25574μs (95% CI: [   25514.2,    25634.4])
```

On an Nvidia A100 with 1M elements, `expand_masked` shows an increasingly large
speedup as segment size increases, reaching 17.8x speedup at segment size 1024.

```
`bench.fut:bench_masked (no tuning file):
gen 1000000i64 0i64 8i64:           444μs (95% CI: [     443.5,      444.2])
gen 1000000i64 0i64 16i64:          623μs (95% CI: [     623.2,      623.8])
gen 1000000i64 0i64 32i64:          952μs (95% CI: [     952.1,      952.9])
gen 1000000i64 0i64 64i64:         1057μs (95% CI: [    1056.9,     1057.7])
gen 1000000i64 0i64 128i64:        1259μs (95% CI: [    1257.7,     1263.1])
gen 1000000i64 0i64 256i64:        1615μs (95% CI: [    1614.8,     1615.9])
gen 1000000i64 0i64 512i64:        2350μs (95% CI: [    2349.6,     2351.2])
gen 1000000i64 0i64 1024i64:       3701μs (95% CI: [    3700.5,     3702.4])

bench.fut:bench_filter (no tuning file):
gen 1000000i64 0i64 8i64:           734μs (95% CI: [     733.8,      734.5])
gen 1000000i64 0i64 16i64:         1295μs (95% CI: [    1293.0,     1299.6])
gen 1000000i64 0i64 32i64:         2336μs (95% CI: [    2335.3,     2337.5])
gen 1000000i64 0i64 64i64:         4405μs (95% CI: [    4404.1,     4406.7])
gen 1000000i64 0i64 128i64:        8517μs (95% CI: [    8514.6,     8520.5])
gen 1000000i64 0i64 256i64:       16727μs (95% CI: [   16720.6,    16732.6])
gen 1000000i64 0i64 512i64:       33183μs (95% CI: [   33171.3,    33196.5])
gen 1000000i64 0i64 1024i64:      66125μs (95% CI: [   66075.4,    66179.9])
```
