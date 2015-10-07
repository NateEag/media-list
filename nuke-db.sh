#! /bin/sh

# Drop the database and re-create it from schema.sql.

dropdb --if-exists media_tracker
./create-db.sh
