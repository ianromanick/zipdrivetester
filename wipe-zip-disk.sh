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

typeset -i cap
cap=$(sfdisk -s $1)
if [ $cap -eq 98304 ]; then
    layout=z100-layout.txt
    name=ZIP-100
elif [ $cap -eq 244766 ]; then
    layout=z250-layout.txt
    name=ZIP250
else
    echo "Not a known kind of Zip disk with capacity $cap."
    sfdisk -g $1
    exit 1
fi

echo Unmounting volumes...
for d in ${1}?; do
    if [ -b $d ]; then
	umount $d
    fi
done

echo Shredding the disk...
shred --iterations=1 --zero --verbose $1
if [ $? -ne 0 ]; then
    exit 1
fi

echo Partitioning the disk...
sfdisk $1 < $layout
if [ $? -ne 0 ]; then
    exit 1
fi

echo Formatting the disk...
mkfs.msdos -n $name ${1}4
if [ $? -ne 0 ]; then
    exit 1
fi

echo Ejecting the disk...
eject $1

echo Done.
