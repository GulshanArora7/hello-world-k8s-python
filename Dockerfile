FROM python:alpine3.7
COPY . /app
WORKDIR /app
RUN pip install flask
EXPOSE 9090
CMD [ "python", "./hello_world.py" ]
