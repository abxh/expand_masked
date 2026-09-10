# expand_masked

## Benchmarks

The benchmarks are done with `1000000` elements with a irregular filtering pattern.

On an Nvidia M2000M, `expand_masked` provides a ~2x speedup for irregular segment sizes 8-32, and 
a 1.7x speedup at size 64, compared to a naive implementation of expand-filter. The advantage disappears
for segment sizes >=128.
```
expand_masked_bench.fut:bench_masked (no tuning file):
irregular_8:         5464μs (95% CI: [    5420.8,     5512.7])
irregular_16:        9273μs (95% CI: [    9221.0,     9329.4])
irregular_32:       17786μs (95% CI: [   17714.7,    17885.4])
irregular_64:       39560μs (95% CI: [   39443.3,    39676.6])
irregular_128:     130483μs (95% CI: [  128889.9,   132826.8])
irregular_256:     255178μs (95% CI: [  252158.5,   259635.8])

expand_masked_bench.fut:bench_filter (no tuning file):
irregular_8:        11087μs (95% CI: [   10993.0,    11188.6])
irregular_16:       18942μs (95% CI: [   18802.5,    19139.5])
irregular_32:       35165μs (95% CI: [   34825.3,    35618.0])
irregular_64:       67653μs (95% CI: [   66846.7,    68881.4])
irregular_128:     130642μs (95% CI: [  129040.0,   133094.3])
irregular_256:     255390μs (95% CI: [  252466.3,   259591.1])
```
