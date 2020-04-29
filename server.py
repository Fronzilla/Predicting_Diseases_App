""""
Deployment server
"""

from flask import Flask, request, jsonify
from flask_restful import Api, Resource
import pickle
import os
from diseases import DISEASES
import numpy as np

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
    def post():
        """"
        Post method:
        The structure of json input object is like:
            - {'Symptom': 'Value'}
        """
        data = request.get_json(force=True)
        list_ = []
        for item in data.values():
            list_.append(DISEASES.get(item))

        if not list_:
            return jsonify({'Unfortunately, There is no match': 'Unfortunately, There is no match'}), 404

        sample = [i * 0 for i in range(len(DISEASES))]

        for i in sample:
            for j in list_:
                if i == j:
                    sample[i] = 1

        sample = np.array(sample).reshape(1, len(DISEASES))

        diagnosis = model.predict(sample).item()

        return jsonify({'Diagnosis': diagnosis})


api.add_resource(Disease, '/getdiagnosis')
if __name__ == '__main__':
    app.run(debug=True)


