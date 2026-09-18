-- expand_masked vs naive expand-filter
--
-- ==
-- entry: bench_masked bench_filter
-- script input { gen 100000i64 0i64  8i64 }
-- script input { gen 100000i64 0i64 16i64 }
-- script input { gen 100000i64 0i64 32i64 }
-- script input { gen 100000i64 0i64 64i64 }
-- script input { gen 100000i64 0i64 128i64 }
-- script input { gen 100000i64 0i64 256i64 }
-- script input { gen 100000i64 0i64 512i64 }
-- script input { gen 100000i64 0i64 1024i64 }

import "lib/github.com/abxh/expand_masked/expand_masked"

local
def hash (x: i32) : i32 =
  let x = u32.i32 x
  let x = ((x >> 16) ^ x) * 0x45d9f3b
  let x = ((x >> 16) ^ x) * 0x45d9f3b
  let x = ((x >> 16) ^ x)
  in i32.u32 x

entry gen (n: i64) (lo: i64) (hi: i64) : []i64 =
  let xs = iota n
  in map (\i ->
            let h = hash (i32.i64 i)
            let r = u32.i32 h
            in lo + i64.u32 r % (hi - lo + 1))
         xs

def get (x: i64) (i: i64) : i64 =
  x + i

def pred (x: i64) (i: i64) : bool =
  (x * 31 + i * 17) % 100 < 50

entry bench_masked (xs: []i64) : []i64 =
  expand_masked id get pred xs

entry bench_filter (xs: []i64) : []i64 =
  expand_filter id get pred xs
