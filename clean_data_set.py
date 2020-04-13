# -*- coding: utf-8 -*-
""""
Prepare and clean raw data
"""
__author__ = 'av.nikitin'

import csv
from collections import defaultdict
from typing import (
    List,
    Dict,
    DefaultDict,
    NoReturn
)
import os
import pandas as pd
from helpers import timing

file_dir = os.path.dirname(__file__)


def return_list(disease_type: str) -> List:

    return_disease_list: List[str] = []
    match = disease_type.replace('^', '_').split('_')
    ctr = 1

    for group in match:
        if ctr % 2 == 0:
            return_disease_list.append(group)
        ctr += 1

    return return_disease_list


@timing
def prepare_and_clean_data(path: str) -> NoReturn:
    """"
    :param path str - path to file
    """
    assert path.endswith('csv'), 'Only .csv file supports'

    with open(path, 'rt') as f:

        reader: csv.reader = csv.reader(f)
        weight = 0
        disease_list: List[str] = []
        dict_wt: Dict = {}
        dict_: DefaultDict = defaultdict(list)

        for row in reader:
            row = str(row[0]).split(';')
            # avoiding \xc2 and \xa0 characters
            if row[0] != "\xc2\xa0" and row[0] != "":
                disease = row[0]
                disease_list: List[str] = return_list(disease)
                weight = row[1]

            if row[2] != "\xc2\xa0" and row[2] != "":
                symptom_list = return_list(row[2])

                for d in disease_list:
                    for s in symptom_list:
                        dict_[d].append(s)
                    dict_wt[d] = weight

    clean_data_set: str = os.path.join(file_dir, 'data', 'data_set_cleaned.csv')

    # if file not exists -> create one
    if not os.path.exists(clean_data_set):
        # closure
        def empty_csv_file():
            """
            Create empty csv - file
            """
            df = pd.DataFrame(list())
            df.to_csv(clean_data_set)

        empty_csv_file()

    with open(clean_data_set, 'w') as w:

        writer = csv.writer(w)

        for key, values in dict_.items():
            for v in values:
                key = str.encode(key).decode('utf-8')
                writer.writerow([key, v, dict_wt[key]])

    return


prepare_and_clean_data(
    os.path.join(file_dir, 'data', 'data_set_uncleaned.csv')
)
