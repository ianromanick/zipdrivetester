#!/bin/bash
#
# Copyright 2016 Ian Romanick
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

if [ "x$1" = "x" ]; then
    echo Must specify full device path.
    exit 127
fi

DEV=$1

if [ ! -b $DEV ]; then
    echo $DEV is not a block device
fi

typeset -i ret=0

echo First random data write...
if ! shred -n 1 $DEV; then
    echo "    Failed!"
    ret=1
fi

echo Read back data...
if ! dd if=$DEV of=/tmp/zip-test bs=4096 iflag=direct > /dev/null; then
    echo "    Failed!"
    ret=1
fi

echo Second random data write...
if ! shred -n 1 -z $DEV ; then
    echo "    Failed!"
    ret=1
fi

# The first and second sets of random data must be different.  Read back the
# second set of random data and compare it to the first set.  If they are the
# same, fail the test.
echo Read second random data and compare with first...
if ! dd if=$DEV of=/tmp/zip-test-second bs=4096 iflag=direct > /dev/null; then
    echo "    Failed! (read)"
    ret=1
fi

if cmp -s /tmp/zip-test /tmp/zip-test-second; then
    echo "    Failed! (data same)"
    ret=1
fi

rm -f /tmp/zip-test-second

echo Re-write random data...
if ! dd if=/tmp/zip-test of=$DEV bs=4096 oflag=direct > /dev/null; then
    echo "    Failed!"
    ret=1
fi
    
echo Re-read random data...
if ! dd if=$DEV of=/tmp/zip-test-after bs=4096 iflag=direct > /dev/null; then
    echo "    Failed!"
    ret=1
fi

echo Compare data...
if ! cmp /tmp/zip-test /tmp/zip-test-after ; then
    echo "    Failed!"
    ret=1
fi

if [ $ret -eq 0 ]; then
    rm /tmp/zip-test /tmp/zip-test-after
fi

exit $ret

