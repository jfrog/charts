## psql --host=mydb.xyz.eu-central-1.rds.amazonaws.com -U postgres --password --dbname=postgres
```bash
CREATE USER "artifactory" WITH PASSWORD 'password';
CREATE USER "xray" WITH PASSWORD 'password';
CREATE USER "distribution" WITH PASSWORD 'password';
CREATE USER "insight" WITH PASSWORD 'password';
CREATE USER "pipelines" WITH PASSWORD 'password';

CREATE DATABASE artifactory ENCODING='UTF8';
CREATE DATABASE xray ENCODING='UTF8';
CREATE DATABASE distribution ENCODING='UTF8';
CREATE DATABASE insight ENCODING='UTF8';
CREATE DATABASE pipelinesdb ENCODING='UTF8';

GRANT ALL PRIVILEGES ON DATABASE artifactory TO artifactory;
GRANT ALL PRIVILEGES ON DATABASE xray TO xray;
GRANT ALL PRIVILEGES ON DATABASE distribution TO distribution;
GRANT ALL PRIVILEGES ON DATABASE insight TO insight;
GRANT ALL PRIVILEGES ON DATABASE pipelinesdb TO pipelines;
```