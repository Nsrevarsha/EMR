from flask import Flask, request, jsonify
import joblib

app = Flask(__name__)

# Load the model and necessary files
model = joblib.load('disease_model.pkl')
symptoms_list = joblib.load('symptoms_list.pkl')

num_to_disease = joblib.load('num_to_disease.pkl')

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json
    input_symptoms = [s.strip().lower().replace(" ", "_") for s in data.get('symptoms', [])]

    # Create input vector
    input_vector = [1 if symptom in input_symptoms else 0 for symptom in symptoms_list]

    # Make prediction
    prediction = model.predict([input_vector])[0]
    predicted_disease = num_to_disease[prediction]

    return jsonify({'predicted_disease': predicted_disease})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)