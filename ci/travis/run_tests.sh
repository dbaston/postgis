#!/usr/bin/env bash
set -e

WARNINGS="-Werror -Wall -Wextra -Wformat -Werror=format-security"
WARNINGS_DISABLED="-Wno-unused-parameter -Wno-implicit-fallthrough -Wno-unknown-warning-option -Wno-cast-function-type"

# Standard flags, as we might build PostGIS for production
CFLAGS_STD="-g -O2 -mtune=generic -fno-omit-frame-pointer ${WARNINGS} ${WARNINGS_DISABLED}"
LDFLAGS_STD="-Wl,-Bsymbolic-functions -Wl,-z,relro"

# Second build with coverage and debugging code enabled
CFLAGS_COV="-g -O0 --coverage --enable-debug"
LDFLAGS_COV="--coverage"

export CUNIT_WITH_VALGRIND=YES
export CUNIT_VALGRIND_FLAGS="--leak-check=full --error-exitcode=1"

/usr/local/pgsql/bin/pg_ctl -c -l /tmp/logfile start
./autogen.sh

./configure CFLAGS="${CFLAGS_STD}" LDFLAGS="${LDFLAGS_STD}"
bash ./ci/travis/logbt -- make -j check RUNTESTFLAGS=--verbose

./configure CFLAGS="${CFLAGS_COV}" LDFLAGS="${LDFLAGS_COV}"
make -j check
