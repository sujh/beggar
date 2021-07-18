#!/bin/bash
rails db:migrate
# rake assets:precompile

bin/webpack-dev-server >/dev/null 2&>1 &

exec "$@"
