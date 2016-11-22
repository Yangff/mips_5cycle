predef = ''
commit = ''

stage = ''
now = []

def toBin(x, y):
	return bin(int(x, 16))[2:].zfill(y)

with open('ins.txt', 'r') as f:
	for x in f:
		if (x == '\n'):
			predef += '	wire dc_type_' + stage + ';\n'
			commit += '	assign dc_type_' + stage + ' = ' + ' | '.join(now) + ';\n\n'
			now = []
			continue
		y = x.split(' ')
		if (len(y) < 2):
			continue 
		if (len(y) == 2):
			if (y[0] == '#'):
				continue
			predef += '	// ' + y[0] + '\n'
			commit += '	// ' + y[0] + '\n'
			stage = y[1].strip()
		else:
			if (y[0] == '#'):
				continue
			cond = ''
			if y[2] == 'SP1' or y[2] == 'SP2':
				cond = '$SPECIALx$'
			else:
				q = y[2].split('/')
				if (len(q) == 1):
					cond = 'dc_op == 6\'b' + toBin(q[0][:-1], 6)
				else:
					cond = '(dc_op == 6\'b' + toBin(q[0], 6) + ') & (dc_funt == 6\'b' + toBin(q[1][:-1], 6) + ')'
			now.append('dc_ins_'+y[0].lower())
			predef += '	wire dc_ins_' + y[0].lower() + ';\n'
			commit += '	assign dc_ins_' + y[0].lower() + ' = ' + cond + ';\n'

print predef + '\n' + commit