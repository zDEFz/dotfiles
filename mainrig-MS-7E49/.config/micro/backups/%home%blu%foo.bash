#!/bin/bash
sed '/ICONST_1/{N;/DUP/{N;/POP2/d;}}
