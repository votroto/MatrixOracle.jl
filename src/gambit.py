import numpy as np
import pygambit as gb
import sys
import csv

flt32 = np.vectorize(float)
lines = sys.stdin.read()
g = gb.Game.parse_game(lines)

sols = gb.nash.gnm_solve(g)

if len(sols)==0:
	sols = gb.nash.ipa_solve(g)

s = sols[0]
print(*flt32(np.array(s.payoff())))
for p in g.players:
	print(*flt32(np.array(s[p])))