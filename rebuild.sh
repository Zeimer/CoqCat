#!/bin/bash
./clean.sh
coq_makefile -R "." Cat -o makefile *v Limits/*v OldLimits/*v Instances/*v Instances/*/*v
make
