-- expand_masked vs naive expand-filter
--
-- ==
-- entry: bench_masked bench_filter
-- script input { (8i64,   gen 100000i64 0i64 8i64) }
-- script input { (16i64,  gen 100000i64 0i64 16i64) }
-- script input { (32i64,  gen 100000i64 0i64 32i64) }
-- script input { (64i64,  gen 100000i64 0i64 64i64) }
-- script input { (128i64, gen 100000i64 0i64 128i64) }
-- script input { (256i64, gen 100000i64 0i64 256i64) }

import "../lib/github.com/abxh/expand_masked/expand_masked"
import "./lib/github.com/diku-dk/cpprandom/random"

module dist = uniform_int_distribution i64 xorshift128plus

entry gen (n: i64) (lo: i64) (hi: i64) : []i64 =
  (loop (rng, out) =
          (xorshift128plus.rng_from_seed [42], replicate n 0)
   for i < n do
     let (rng, x) = dist.rand (lo, hi) rng
     in (rng, out with [i] = x)).1

def get (x: i64) (i: i64) : i64 =
  x + i

def pred (x: i64) (i: i64) : bool =
  (x * 31 + i * 17) % 100 < 50

entry bench_masked (max_segment_size: i64) (xs: []i64) : []i64 =
  expand_masked max_segment_size id get pred xs

entry bench_filter (_: i64) (xs: []i64) : []i64 =
  expand_filter id get pred xs
