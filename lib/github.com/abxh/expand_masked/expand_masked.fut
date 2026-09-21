-- | Implementation of flattening by expansion with filtering

import "../../diku-dk/segmented/segmented"
import "bitmask"

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

local module B = bitmask_32

-- | Alternative implementation to expand-filter
def expand_masked 'a 'b
                  (sz: a -> i64)
                  (get: a -> i64 -> b)
                  (pred: a -> i64 -> bool)
                  (arr: []a) : *[]b =
  let szs = map sz arr
  let arr_szs =
    zip (indices arr) szs
    |> expand (\(_, s) -> (s + B.num_bits - 1) / B.num_bits)
              (\(xi, s) i ->
                 let o = B.num_bits * i
                 let n = i64.min B.num_bits (s - o)
                 in (xi, o, n))
  let f (xi, o, n) i =
    let b = if i < n then pred arr[xi] (o + i) else false
    in B.set B.empty i b
  let arr_szs' = 
    #[incremental_flattening(only_intra)]
    map (\(xi, o, n) -> 
      let iot = iota B.num_bits
      let flags = map (\i -> f (xi, o, n) i) iot
      in (xi, o, reduce_comm B.union B.empty flags))
    arr_szs
  let get' (xi, o, mask) j =
    let i = B.select mask j
    in get arr[xi] (o + i)
  in expand (\(_, _, mask) -> B.rank mask) get' arr_szs'

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
