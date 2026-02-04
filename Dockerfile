# Grab the latest alpine image
FROM alpine:latest

# Install python, pip and bash
RUN apk add --no-cache python3 py3-pip bash

# Create virtual environment
RUN python3 -m venv /opt/venv

# Activate virtualenv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements
COPY ./webapp/requirements.txt /tmp/requirements.txt

# Install dependencies inside venv
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Add application code
COPY ./webapp /opt/webapp/
WORKDIR /opt/webapp

# Create non-root user
RUN adduser -D myuser
USER myuser

# Heroku provides $PORT
CMD gunicorn --bind 0.0.0.0:$PORT wsgi
