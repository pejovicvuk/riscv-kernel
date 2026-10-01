# 02 - Memory allocator (Part 1)

Files: `inc/memoryAllocator.hpp`, `src/memoryAllocator.cpp`

## The idea in one sentence

The heap is one long strip of memory; the free parts are kept in a linked list
sorted by address, and the bookkeeping for each free block (the header) is
stored inside the block itself. That makes it an "intrusive" list: the
bookkeeping needs no separate memory.

## Key design decisions

- **The header lives in the first 16B of the block**:
  `struct FreeBlock { FreeBlock* next; size_t size; }` (8B + 8B = 16B).
  The user gets a pointer right after the header.
- **First-fit**: take the first block that is large enough (simple, good enough)
- **Everything is in bytes internally**, and every allocation is a multiple of
  `MEM_BLOCK_SIZE` (64B)
- **The list is sorted by address**: that keeps merging neighbors
  (coalescing) simple
- All-static class: `MemoryAllocator::init/alloc/free`, constructor deleted

## Flow: alloc(100)

```
1. the user asks for 100 bytes
2. add the header:        100 + 16 = 116
3. round up to blocks:    ((116 + 63) / 64) * 64 = 128     <- ceiling division
4. first-fit: walk the list until a block with size >= 128 is found
5. found a block of, say, 1024B:
   remainder = 1024 - 128 = 896 >= 64  -> SPLIT:
      [ our block: 128B ][ new free block: 896B -> stays in the list ]
   (if the remainder were < 64, we would hand out the whole block - it is too
   small to live on its own)
6. return (char*)block + 16   <- the address AFTER the header
```

In step 3, ceiling division is `(n + B - 1) / B`. "Divide, then +1" is wrong
for exact multiples: 128/64+1 gives 3 blocks instead of 2.

In step 2, we add the header before rounding. That way the user's payload
always has at least the requested `size` bytes.

## Flow: free(p)

```
1. the header is right in front of the payload:  block = (char*)p - 16
2. walk the list (sorted by address) to the place where block belongs
3. check whether block PHYSICALLY touches a neighbor:
   mergePrev: (char*)prev + prev->size == (char*)block
   mergeNext: (char*)block + block->size == (char*)curr
4. four cases:
   no merge             -> just insert block into the list
   merge with previous  -> prev->size += block->size   (block disappears into prev)
   merge with next      -> block "swallows" curr (takes over its size and next)
   merge with both      -> prev swallows both block and curr
```

Example of merging with both neighbors:

```
before: [prev 128B free][block 128B just freed][curr 256B free]
after:  [prev 512B free]                    <- one block, list shorter by 2
```

## Pitfalls

- `sizeof(FreeBlock)` is 16 (the whole struct), `sizeof(FreeBlock*)` is 8 (a pointer).
- Short-circuit `&&` in mergePrev/mergeNext protects against null dereference
  (`prev != nullptr && ...` - the right side is not evaluated if the left is false)
- `free(nullptr)` returns -1 and does not crash

## Double rounding through the whole chain (expected)

When a request goes through C API -> ABI -> kernel, it gets rounded twice:

```
mem_alloc(100):  C API: (100+63)/64 = 2 blocks    (the user gets >= 128 USABLE bytes)
                 kernel: alloc(2*64 = 128)
                 allocator: 128+16 header = 144 -> 192 (3 blocks used)
```

Every allocation takes one block more than the "obvious" amount. The header
lives inside the block, so giving the user a full n*64 usable bytes needs
extra room for the header. That is the price of the intrusive design. The
project specification asks for "at least size bytes", and we meet that. Evidence from an actual test: p2-p1 = 0xC0 (192),
p3-p2 = 0x140 (320).

## How it was verified

A test in `userMain` through the whole chain (C API -> ecall -> kernel ->
allocator): three allocations (100, 200, 50), freed in the order p2, p1, p3 -
this covers the "merge with next" and "merge with both" branches. Evidence:
after free(p2)+free(p1) there is a single hole of 0x200 (= 0xC0 + 0x140), and
after free(p3) the whole heap is again a single block at the initial address
with the initial size (0x7ffa720), so nothing leaks. Both mem_alloc and mem_free
go through ecall.

## Review questions

1. Why must the list be sorted by address?
2. What would happen if the header were not included in the rounding?
3. Why is a remainder smaller than MEM_BLOCK_SIZE "too small to live on its own"?
4. How do we find the header from the payload pointer, and why is that safe?
