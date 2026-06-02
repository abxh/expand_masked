-- | expand-filter implementation well-suited when segment sizes are bounded and small.

import "bitmask"
import "../../diku-dk/segmented/segmented"

module expand_masked_generic (M: bitmask) = {
  def expand_masked 'a 'b
                    (sz: a -> i64)
                    (pred: a -> i64 -> bool)
                    (get: a -> i64 -> b)
                    (arr: []a) : []b =
    let f x =
      loop mask = M.empty
      for i < i64.min M.num_bits (sz x) do
        M.set mask i (pred x i)
    let get' (x, mask) i = get x (M.select mask i)
    in zip arr (map f arr) |> expand (\(_, mask) -> M.rank mask) get'
}

local module expand_masked_8 = expand_masked_generic bitmask_8
local module expand_masked_16 = expand_masked_generic bitmask_16
local module expand_masked_32 = expand_masked_generic bitmask_32
local module expand_masked_64 = expand_masked_generic bitmask_64
local module expand_masked_128 = expand_masked_generic bitmask_128
local module expand_masked_256 = expand_masked_generic bitmask_256
local module expand_masked_512 = expand_masked_generic bitmask_512

-- | expand_masked with dynamic dispatch given max_segment_size selecting
-- the fixed-size method. Preferably use fixed-size method for better performance.
--
-- Falls back to regular filtering if max_segment_size is larger than 1024.
def expand_masked 'a 'b
                  (max_segment_size: i64)
                  (sz: a -> i64)
                  (pred: a -> i64 -> bool)
                  (get: a -> i64 -> b)
                  (arr: []a) : []b =
  if max_segment_size <= 8
  then expand_masked_8.expand_masked sz pred get arr
  else if max_segment_size <= 16
  then expand_masked_16.expand_masked sz pred get arr
  else if max_segment_size <= 32
  then expand_masked_32.expand_masked sz pred get arr
  else if max_segment_size <= 64
  then expand_masked_64.expand_masked sz pred get arr
  else if max_segment_size <= 128
  then expand_masked_128.expand_masked sz pred get arr
  else if max_segment_size <= 256
  then expand_masked_256.expand_masked sz pred get arr
  else if max_segment_size <= 512
  then expand_masked_512.expand_masked sz pred get arr
  else let get' x i = (get x i, x, i)
       in expand sz get' arr
          |> filter (\(_, x, i) -> pred x i)
          |> map (.0)

-- | expand with segments expanding to at most 8 elements
def expand_masked_8 = expand_masked_8.expand_masked

-- | expand with segments expanding to at most 16 elements
def expand_masked_16 = expand_masked_16.expand_masked

-- | expand with segments expanding to at most 16 elements
def expand_masked_32 = expand_masked_32.expand_masked

-- | expand with segments expanding to at most 32 elements
def expand_masked_64 = expand_masked_64.expand_masked

-- | expand with segments expanding to at most 64 elements
def expand_masked_128 = expand_masked_128.expand_masked

-- | expand with segments expanding to at most 256 elements
def expand_masked_256 = expand_masked_256.expand_masked

-- | expand with segments expanding to at most 512 elements
def expand_masked_512 = expand_masked_512.expand_masked
