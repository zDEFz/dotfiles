#!/bin/bash
curl -s https://easyfitness.club/studio/easyfitness-wiesloch/ \
  | sed -n 's/.*class="meterbubble">\([0-9][0-9]*\)%.*/\1/p' \
  | head -n1 \
  | sed 's/$/% Gym/'
