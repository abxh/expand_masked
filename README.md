# expand_masked

## Benchmarks

Both benchmarks are carried out on the cuda backend.

On an Nvidia M2000M with `1000000` elements, `expand_masked` provides a ~1.6-1.8x speedup for
irregular segment sizes 8-64, compared to a naive implementation of expand-filter. The advantage disappears for segment
sizes >=128.
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

On an Nvidia A100 with `100000000` elements, `expand_masked` provides a ~2.5 speedup for
irregular segment sizes 8-32 and a 4.4x speedup for segment size 64 when using
a single integer as the bitmask. The advantage similarly 

```
bench.fut:bench_masked (no tuning file):
(8i64, gen 10000000i64 0i64 8i64):           2364μs (95% CI: [    2363.0,     2365.2])
(16i64, gen 10000000i64 0i64 16i64):         3955μs (95% CI: [    3953.5,     3956.1])
(32i64, gen 10000000i64 0i64 32i64):         7127μs (95% CI: [    7123.5,     7131.2])
(64i64, gen 10000000i64 0i64 64i64):         8211μs (95% CI: [    8206.9,     8214.5])
(128i64, gen 10000000i64 0i64 128i64):      71074μs (95% CI: [   71049.1,    71110.8])
(256i64, gen 10000000i64 0i64 256i64):   12780346μs (95% CI: [10948093.2, 14627245.8])

bench.fut:bench_filter (no tuning file):
(8i64, gen 10000000i64 0i64 8i64):           5417μs (95% CI: [    5414.9,     5420.1])
(16i64, gen 10000000i64 0i64 16i64):         9915μs (95% CI: [    9910.0,     9920.0])
(32i64, gen 10000000i64 0i64 32i64):        18932μs (95% CI: [   18922.3,    18940.1])
(64i64, gen 10000000i64 0i64 64i64):        36388μs (95% CI: [   36356.1,    36414.8])
(128i64, gen 10000000i64 0i64 128i64):      71083μs (95% CI: [   71047.9,    71126.5])
(256i64, gen 10000000i64 0i64 256i64):   12656761μs (95% CI: [10883302.5, 14432656.1])
```
