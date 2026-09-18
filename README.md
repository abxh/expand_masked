# expand_masked

See the considerations that went into this design [here](https://github.com/diku-dk/segmented/pull/13).

## Benchmarks

Both benchmarks are carried out on the cuda backend. Note, the implementation assumes
calls to `pred` is cheap, as it sequentially calls up to 64 `pred` at a time.

On an Nvidia M2000M with 10K elements, `expand_masked` provides a 2x speedup
over the naive expand-filter.
```
bench.fut:bench_masked (no tuning file):
gen 100000i64 0i64 8i64:          1159μs (95% CI: [    1141.7,     1177.5])
gen 100000i64 0i64 16i64:         1537μs (95% CI: [    1520.8,     1555.9])
gen 100000i64 0i64 32i64:         2450μs (95% CI: [    2422.9,     2479.5])
gen 100000i64 0i64 64i64:         4434μs (95% CI: [    4399.8,     4471.8])
gen 100000i64 0i64 128i64:        8003μs (95% CI: [    7950.0,     8066.8])
gen 100000i64 0i64 256i64:       14916μs (95% CI: [   14852.7,    15011.1])
gen 100000i64 0i64 512i64:       28711μs (95% CI: [   28638.8,    28781.7])
gen 100000i64 0i64 1024i64:      56202μs (95% CI: [   56069.1,    56345.8])

bench.fut:bench_filter (no tuning file):
gen 100000i64 0i64 8i64:          1399μs (95% CI: [    1383.3,     1417.4])
gen 100000i64 0i64 16i64:         2367μs (95% CI: [    2341.7,     2395.5])
gen 100000i64 0i64 32i64:         4205μs (95% CI: [    4163.0,     4254.6])
gen 100000i64 0i64 64i64:         7692μs (95% CI: [    7628.9,     7769.2])
gen 100000i64 0i64 128i64:       14597μs (95% CI: [   14486.7,    14735.1])
gen 100000i64 0i64 256i64:       28216μs (95% CI: [   27963.0,    28553.6])
gen 100000i64 0i64 512i64:       55491μs (95% CI: [   54913.2,    56524.3])
gen 100000i64 0i64 1024i64:     110022μs (95% CI: [  108826.3,   111762.0])
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
