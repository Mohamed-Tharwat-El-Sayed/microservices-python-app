FROM python:3.10-slim-bullseye

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests build-essential libpq-dev python3-dev && pip install --no-cache-dir --upgrade pip

WORKDIR /app
COPY ./requirements.txt /app

RUN pip install --no-cache-dir --requirement /app/requirements.txt
COPY . /app

EXPOSE 5000

# # Define environment variable
# ENV DATABASE_HOST your_database_host
# ENV DATABASE_NAME your_database_name
# ENV DATABASE_USER your_database_user
# ENV DATABASE_PASSWORD your_database_password
# ENV AUTH_TABLE your_auth_table
# ENV JWT_SECRET your_jwt_secret

CMD ["python", "server.py"]