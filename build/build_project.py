#! /usr/bin/env python
# -*- coding: utf-8 -*-
#

import os
import sys
import subprocess

LIB="libdash.so"
BIN_DIR = os.path.join("..", "bin")

cmd = "cmake ."
p = subprocess.Popen(cmd.split())
p.communicate()
if p.returncode != 0:
   sys.exit(-1)

cmd = "make build_deb"
p = subprocess.Popen(cmd.split())
p.communicate()
if p.returncode != 0:
   sys.exit(-1)

if not os.path.exists(LIB):
   print("Dash lib has not been created")
   sys.exit(-1)

if not os.path.exists(BIN_DIR):
   os.makedirs(BIN_DIR)

if not os.path.lexists(os.path.join(BIN_DIR, LIB)):
   os.symlink(os.path.join("..", "build", LIB), os.path.join(BIN_DIR, LIB))

sys.exit(0)
