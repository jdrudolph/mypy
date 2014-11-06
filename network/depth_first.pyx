cimport cython 
cimport numpy as np

from libc.stdlib cimport malloc, free

import numpy as np

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef int _depth_first_visit(int i,
                            int order_end,
                            int[::1] indptr, 
                            int[::1] indices, 
                            int[::1] status, 
                            int[::1] order, 
                            int[::1] predecessors) nogil:
    cdef int j
    cdef int idx

    status[i] = 1

    order[order_end] = i
    order_end += 1

    for idx in range(indptr[i], indptr[i+1]):
        j = indices[idx]
    
        if status[j] == 0:
            predecessors[j] = i
            order_end = _depth_first_visit(j, order_end, indptr, indices, status, order, predecessors)

    status[i] = 2

    return order_end

cdef struct StackEntry:
    int node
    int index

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef int _depth_first_iterative(int i_start, 
                                int[::1] indptr, 
                                int[::1] indices, 
                                int[::1] order, 
                                int[::1] predecessors) nogil:
    cdef int i, j
    cdef int idx
    cdef int n = order.shape[0]
    cdef int order_end = 0

    cdef int* status = <int*> malloc(n*sizeof(int))
    cdef StackEntry* stack = <StackEntry*>malloc(n * sizeof(StackEntry))
    cdef StackEntry* head = stack
    
    for idx in range(n):
        status[idx] = 0

    try:
        head.node = i_start
        head.index = indptr[i_start]

        order[order_end] = i_start
        order_end += 1

        predecessors[i_start] = -9999
        status[i_start] = 1
        
        while head >= stack:
            i = head.node

            for idx in range(head.index, indptr[i+1]):
                j = indices[idx]

                if status[j] == 0:
                    head.index = idx + 1

                    predecessors[j] = i
                    status[j] = 1
                    order[order_end] = j
                    order_end += 1

                    head += 1
                    head.node = j
                    head.index = indptr[j]
                    break
            
            if head.node == i: # no push
                status[i] = 2
                head -= 1

    finally:
        free(stack)
        free(status)


def depth_first_order(csgraph, i_start, directed=True, return_predecessors=True):
    cdef int n = csgraph.shape[0]

    order = np.empty(n, dtype=np.int32)
    predecessors = np.empty(n, dtype=np.int32)

    _depth_first_iterative(i_start, csgraph.indptr, csgraph.indices, order, predecessors)

    if return_predecessors:
        return order, predecessors

    return order
