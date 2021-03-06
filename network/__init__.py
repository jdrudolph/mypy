"""
Collection of utitilities to work with networks that are represented as
csr_matrix (sparse matrices from scipy)
"""
from __future__ import absolute_import

from .sparse_graph import SparseGraph, from_indices
from .util import edge_id
