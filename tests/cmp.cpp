#include <cstdio>
#include <cctype>

int _std[1024]; int n;

int scan_verilog(FILE* f){
	int y = 0; int S = 0;
	for (int x = fgetc(f); x >= 0; x = fgetc(f)){
		if (S == 5) {
			if (isdigit(x))
				y = y * 10 + (x - '0');
			else return y;
		} 
		if (S == 4) {
			if (isdigit(x)) {
				y = x - '0';
				S = 5;
			}
		}
		if (S == 3) {
			if (x == ':') S = 4; else S = 0;
		}
		if (S == 2) {
			if (x == 'g') S = 3; else S = 0;
		}
		if (S == 1) {
			if (x == 'e') S = 2; else S = 0;
		}
		if (S == 0 && x == 'R') {
			S = 1;
		}
	}
}

int main(int argc, char ** args) {
	if (argc != 3) {
		printf("[Usage] cmp verilog_output standard output.\n");
	}
	FILE *fverilog = fopen(args[1], "rb");
	FILE *fstd = fopen(args[2], "rb");
	while (!feof(fstd)) {
		if (fscanf(fstd, "%d", _std + n) != -1)
			n++;
	}
	fclose(fstd);
	int passed = 0;
	for (int i = 0; i < n; i++) {
		int x = scan_verilog(fverilog);
		if (x != _std[i])
			printf("[Error] Line %d, %d expected, but %d found.\n", i + 1, _std[i], x);
		else
			passed++;
	}
	fclose(fverilog);
	printf("[Log] Finished tests, passed %d/%d.", passed, n);
	return 0;
}