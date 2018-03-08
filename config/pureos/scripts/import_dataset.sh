#!/bin/bash

# Copyright (C) 2008,2010 Joerg Jaspert <joerg@debian.org>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


set -e
set -u

# Load up some standard variables
export SCRIPTVARS=/srv/dak/dak/config/pureos/vars
. $SCRIPTVARS

IMPORTSUITE=${1:-"$devel_suite"}
BRITNEY=""

case "${IMPORTSUITE}" in
    $devel_suite)
        # What file we look at.
        INPUTFILE="/var/archive-kit/britney2/var/Heidi/set/current"
        # changelog doesn't work at time
        DO_CHANGELOG="false"
        BRITNEY=" --britney"
        ;;
    *)
        echo "You are so wrong here that I can't even believe it. Sod off."
        exit 42
        ;;
esac

echo "Importing dataset..."

# Change to a known safe location
cd $masterdir

NOW=$(date "+%Y%m%d%H%M")

echo "Creating database backup..."
pg_dump -Fc projectb > $dbbackupdir/projectb_$(date +%Y-%m-%d_%H%M%S).dump
# remove old backups
cd $dbbackupdir
find . -maxdepth 1 -mindepth 1 -type f -mmin +4320 -name '*.dump' -delete
cd $masterdir

echo "Importing new data for ${IMPORTSUITE} into database"

if [ "x${DO_CHANGELOG}x" = "xtruex" ]; then
    rm -f ${ftpdir}/pureos/dists/${IMPORTSUITE}/ChangeLog
    BRITNEY=" --britney"
fi

dak control-suite --set ${IMPORTSUITE} ${BRITNEY} < ${INPUTFILE}

if [ "x${DO_CHANGELOG}x" = "xtruex" ]; then
    cd ${ftpdir}/pureos/dists/${IMPORTSUITE}/
    mv ChangeLog ChangeLog.${NOW}
    ln -s ChangeLog.${NOW} ChangeLog
    find . -maxdepth 1 -mindepth 1 -type f -mmin +2880 -name 'ChangeLog.*' -delete
fi

echo "Done"

exit 0
