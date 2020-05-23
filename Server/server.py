""""
Deployment server
"""

from flask import Flask, request, jsonify
from flask_restful import Api, Resource
import pickle
import os
from Server.diseases import *
import numpy as np
from typing import List, Dict

app = Flask(__name__)
api = Api(app)

file_dir = os.path.dirname(__file__)
model = pickle.load(
    open(os.path.join(file_dir, 'decision_tree_classifier.pkl'), 'rb')
)


class Disease(Resource):
    """"

    """
    @staticmethod
    def post() -> dict:
        """"
        Post method:
        The structure of json input object is like:
            - {'0': 'Value', 1: 'Value'}
        """
        data: Dict = request.get_json(force=True)

        list_: List[str] = []

        for _, v in [(k, v) for x in data for (k, v) in x.items()]:
            if DISEASES.get(v):
                list_.append(DISEASES.get(v))

        if not list_:
            return jsonify({'status': 'error', 'diagnosis': 'Unfortunately, There is no match'})

        sample: List[int] = [i * 0 for i in range(len(DISEASES))]

        # this is actually bad
        for i in enumerate(sample):
            for j in list_:
                if i[0] == j:
                    sample[i[0]] = 1

        sample = np.array(sample).reshape(1, len(DISEASES))

        diagnosis = model.predict(sample).item()

        return jsonify({'status': 'ok', 'diagnosis': diagnosis})


api.add_resource(Disease, '/getdiagnosis')
if __name__ == '__main__':
    app.run(debug=True)
