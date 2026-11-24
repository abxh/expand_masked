import "../../diku-dk/segmented/segmented"
import "./bitmask"

module expand_masked_generic
  (M: {
    type t
    val num_bits : i64
    val empty : t
    val set : t -> i64 -> bool -> t
    val rank : t -> i64
    val select : t -> i64 -> i64
  }) = {
  def expand_masked 'a 'b
                    (sz: a -> i64)
                    (get: a -> i64 -> b)
                    (pred: a -> i64 -> bool)
                    (arr: []a) : *[]b =
    let szs = map sz arr
    let arr_szs =
      zip (indices arr) szs
      |> expand (\(_, s) -> (s + M.num_bits - 1) / M.num_bits)
                (\(xi, s) i ->
                   let o = M.num_bits * i
                   let n = i64.min M.num_bits (s - o)
                   in (xi, o, n))
    let f (xi, o, n) =
      let mask =
        loop mask = M.empty
        for i < M.num_bits do
          let b = if i < n then pred arr[xi] (o + i) else false
          in M.set mask i b
      in (xi, o, mask)
    let get' (xi, o, mask) j =
      let i = M.select mask j
      in get arr[xi] (o + i)
    let arr_szs' = map f arr_szs
    in expand (\(_, _, mask) -> M.rank mask) get' arr_szs'
}

local module expand_masked_default = expand_masked_generic bitmask_8

-- | Expansion function with an additional predicate function ``pred`` that takes
-- the segment source element and segment index to pre-filter them before obtaining
-- the corresponding target element with ``get``.
--
-- This can be used to replace use cases where the source element is transformed to
-- the form #some value | #none with ``get``, by pre-filtering the #none cases with
-- ``pred`` and just outputting the value with ``get`` instead, thereby avoid wasting
-- memory on values that would otherwise be discarded.
def expand_masked 'a 'b
                  (sz: a -> i64)
                  (get: a -> i64 -> b)
                  (pred: a -> i64 -> bool)
                  (arr: []a) : *[]b =
  expand_masked_default.expand_masked sz get pred arr

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
