-- | expand-filter implementation well-suited when segment sizes are bounded and small.
--
-- ´expand_masked´ filters input segment elements before they are expanded, hence it's
-- a "masked" expansion rather than a mere expand-filter implementation.
--
-- In principle can be implemented as following:
-- def expand_masked 'a 'b
--                   (max_sz: a -> i64)
--                   (get: a -> i64 -> b)
--                   (pred: a -> i64 -> bool)
--                   (arr: []a) : []b =
--   let get' x i = (get x i, x, i)
--   in expand max_sz get' arr
--      |> filter (\(_, x, i) -> pred x i)
--      |> map (.0)

import "../../diku-dk/segmented/segmented"

module type partial_bitmask = {
  type t
  val num_bits : i64
  val empty : t
  val set : t -> i64 -> bool -> t
  val rank : t -> i64
  val select : t -> i64 -> i64
}

module expand_masked_generic (M: partial_bitmask) = {
  def expand_masked 'a 'b
                    (max_sz: a -> i64)
                    (get: a -> i64 -> b)
                    (pred: a -> i64 -> bool)
                    (arr: []a) : []b =
    let f x =
      let pred' = pred x
      in loop mask = M.empty
         for i < i64.min M.num_bits (max_sz x) do
           M.set mask i (pred' i)
    let get' (x, mask) i = get x (M.select mask i)
    in zip arr (map f arr) |> expand (\(_, mask) -> M.rank mask) get'
}

import "bitmask"

local module expand_masked_8 = expand_masked_generic bitmask_8
local module expand_masked_16 = expand_masked_generic bitmask_16
local module expand_masked_32 = expand_masked_generic bitmask_32
local module expand_masked_64 = expand_masked_generic bitmask_64
local module expand_masked_128 = expand_masked_generic bitmask_128
local module expand_masked_256 = expand_masked_generic bitmask_256

-- | expand_masked with dynamic dispatch given max_segment_size selecting
-- the fixed-size method. Preferably use fixed-size method for better performance.
--
-- Falls back to regular filtering if max_segment_size is larger than 256.
def expand_masked 'a 'b
                  (max_segment_size: i64)
                  (max_sz: a -> i64)
                  (get: a -> i64 -> b)
                  (pred: a -> i64 -> bool)
                  (arr: []a) : []b =
  if max_segment_size <= 8
  then expand_masked_8.expand_masked max_sz get pred arr
  else if max_segment_size <= 16
  then expand_masked_16.expand_masked max_sz get pred arr
  else if max_segment_size <= 32
  then expand_masked_32.expand_masked max_sz get pred arr
  else if max_segment_size <= 64
  then expand_masked_64.expand_masked max_sz get pred arr
  else if max_segment_size <= 128
  then expand_masked_128.expand_masked max_sz get pred arr
  else if max_segment_size <= 256
  then expand_masked_256.expand_masked max_sz get pred arr
  else let get' x i = (get x i, x, i)
       in expand max_sz get' arr
          |> filter (\(_, x, i) -> pred x i)
          |> map (.0)

-- | expand with segments expanding to at most 8 elements pr segment
def expand_masked_8 = expand_masked_8.expand_masked

-- | expand with segments expanding to at most 16 elements pr segment
def expand_masked_16 = expand_masked_16.expand_masked

-- | expand with segments expanding to at most 16 elements pr segment
def expand_masked_32 = expand_masked_32.expand_masked

-- | expand with segments expanding to at most 32 elements pr segment
def expand_masked_64 = expand_masked_64.expand_masked

-- | expand with segments expanding to at most 64 elements pr segment
def expand_masked_128 = expand_masked_128.expand_masked

-- | expand with segments expanding to at most 256 elements pr segment
def expand_masked_256 = expand_masked_256.expand_masked
