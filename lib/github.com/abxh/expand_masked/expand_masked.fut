-- | Implementation of flattening by expansion with filtering

import "../../diku-dk/segmented/segmented"

-- | Expansion function with an additional predicate function ``pred`` that takes
-- the segment source element and segment index to pre-filter them before obtaining
-- the corresponding target element with ``get``.
--
-- This can be used to replace use cases where the source element is transformed to
-- the form #some value | #none with ``get``, by pre-filtering the #none cases with
-- ``pred`` and just outputting the value with ``get`` instead, thereby avoid wasting
-- memory on values that would otherwise be discarded.
def expand_filter 'a 'b
                  (sz: a -> i64)
                  (get: a -> i64 -> b)
                  (pred: a -> i64 -> bool)
                  (arr: []a) : []b =
  let szs = map sz arr
  let (idxs, iotas) = repl_segm_iota szs
  in zip idxs iotas
     |> filter (\(i, j) -> pred arr[i] j)
     |> map (\(i, j) -> get arr[i] j)

local
-- | Helper function to find the position of the k'th set bit in an u8
#[inline]
def select_u8 (b: u8) (k: i32) : i32 =
  let f b = b & (b - 1)
  let s0 = b
  let s1 = f s0
  let s2 = f s1
  let s3 = f s2
  let s4 = f s3
  let s5 = f s4
  let s6 = f s5
  let s7 = f s6
  let w =
    match k
    case 0 -> s0
    case 1 -> s1
    case 2 -> s2
    case 3 -> s3
    case 4 -> s4
    case 5 -> s5
    case 6 -> s6
    case 7 -> s7
    case _ -> 0u8
  in u8.ctz w

local
-- | Helper function to find the position of the k'th set bit in an u16
#[inline]
def select_u16 (b: u16) (k: i32) : i32 =
  let lower = u8.u16 b
  let upper = b >> 8 |> u8.u16
  let low_count = u8.popc lower
  in if k < low_count
     then select_u8 lower k
     else select_u8 upper (k - low_count) + 8

local
-- | Helper function to find the position of the k'th set bit in an u32
#[inline]
def select_u32 (b: u32) (k: i32) : i32 =
  let lower = u16.u32 b
  let upper = b >> 16 |> u16.u32
  let low_count = u16.popc lower
  in if k < low_count
     then select_u16 lower k
     else select_u16 upper (k - low_count) + 16

local
-- | Helper function to find the position of the k'th set bit in an u64
#[inline]
def select_u64 (b: u64) (k: i32) : i32 =
  let lower = u32.u64 b
  let upper = b >> 32 |> u32.u64
  let low_count = u32.popc lower
  in if k < low_count
     then select_u32 lower k
     else select_u32 upper (k - low_count) + 32

-- | Alternative implementation to expand-filter
--
-- Can be more efficient than a naive expand-filter when ``pred`` is cheap, as it is
-- run sequentially 64 at a time.
def expand_masked 'a 'b
                  (sz: a -> i64)
                  (get: a -> i64 -> b)
                  (pred: a -> i64 -> bool)
                  (arr: []a) : *[]b =
  let num_bits = i64.i32 u64.num_bits
  let szs = map sz arr
  let arr_szs =
    zip (indices arr) szs
    |> expand (\(_, s) -> (s + num_bits - 1) / num_bits)
              (\(xi, s) i ->
                 let o = num_bits * i
                 let n = i64.min num_bits (s - o)
                 in (xi, o, n))
  let f (xi, o, n) =
    let mask =
      loop mask = 0
      for i < n do
        u64.set_bit (i32.i64 i) mask (i32.bool <| pred arr[xi] (o + i))
    in (xi, o, mask)
  let get' (xi, o, mask) j =
    let i = i64.i32 <| select_u64 mask (i32.i64 j)
    in get arr[xi] (o + i)
  let arr_szs' = map f arr_szs
  in expand (\(_, _, mask) -> i64.i32 <| u64.popc mask) get' arr_szs'

-- | Expansion function with an additional predicate function ``pred`` that takes
-- the target element to filter. This calls ``get`` twice for every target element
-- produced that fulfill the predicate, and once on the target elements that don't.
--
-- Can be more efficient than a naive expand-filter-target when both ``pred`` and
-- ``get`` is cheap.
def expand_masked_target 'a 'b
                         (sz: a -> i64)
                         (get: a -> i64 -> b)
                         (pred: b -> bool)
                         (arr: []a) : *[]b =
  let pred' x i = pred (get x i)
  in expand_masked sz get pred' arr
