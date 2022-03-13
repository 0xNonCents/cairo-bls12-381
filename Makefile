# Build and test
all:
	@echo "Compiling.." 
	@cairo-compile contracts/test.cairo --output test.json 
	@echo "Running.." 
	@cairo-run --program test.json --print_output --layout=small --print_info
run:
	@echo "Running.." 
	@cairo-run --program test.json --print_output --layout=small --print_info

