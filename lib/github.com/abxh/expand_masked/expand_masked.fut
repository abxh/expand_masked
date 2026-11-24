import "../../diku-dk/segmented/segmented"
import "./bitmask"

module expand_masked_generic
  (M: {
    type t
    val num_bits : i64
    val empty : t
    val union : t -> t -> t
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
    let (xs, os, ns) =
      zip (indices arr) szs
      |> expand (\(_, s) -> (s + M.num_bits - 1) / M.num_bits)
                (\(xi, s) i ->
                   let o = M.num_bits * i
                   let n = i64.min M.num_bits (s - o)
                   in (arr[xi], o, n))
      |> unzip3
    let (is, segm_idxs) = repl_segm_iota ns
    let vs =
      map2 (\(is: i64) (segm_idx: i64) ->
              let b = if segm_idx < ns[is] then pred xs[is] (os[is] + segm_idx) else false
              in M.set M.empty segm_idx b)
           is
           segm_idxs
    let masks = reduce_by_index (map (const M.empty) xs) M.union M.empty is vs
    let get' (x, o, mask) j =
      let i = M.select mask j
      in get x (o + i)
    in expand (\(_, _, mask) -> M.rank mask) get' (zip3 xs os masks)
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
