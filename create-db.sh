#! /bin/sh

# Create an instance of the API's DB.

# TODO Think about authentication, I suppose...
createdb -E UTF8 -e media_tracker
psql media_tracker -f schema.sql
