# -*- coding: utf-8 -*-
""""
helpers files
"""
__author__ = 'av.nikitin'

from functools import wraps
from time import time


def timing(f):
    @wraps(f)
    def wrapper(*args, **kwargs):
        start_time = time()
        result = f(*args, **kwargs)
        end_time = time()
        print(f'Elapsed time {end_time-start_time}')

        return result

    return wrapper
