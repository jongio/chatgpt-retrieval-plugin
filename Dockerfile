
FROM python:3.10 as requirements-stage

WORKDIR /tmp

RUN pip install poetry

COPY ./pyproject.toml ./poetry.lock* /tmp/


RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

FROM python:3.10

WORKDIR /code

# Install jq using apt-get
RUN apt-get update && \
    apt-get install -y jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
COPY --from=requirements-stage /tmp/requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/

COPY entrypoint.sh /entrypoint.sh
COPY hostconfig.sh /hostconfig.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
