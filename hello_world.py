#!/usr/bin/python3

import os

from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    target = os.environ.get('TARGET', 'World')
    return 'Hello {}!\n'.format(target)

@app.route('/health')
def health_check():
    return 'OK'

if __name__ == "__main__":
    app.run(debug=False,use_reloader=True,host='0.0.0.0',port=int(os.environ.get('PORT', 9090)))
