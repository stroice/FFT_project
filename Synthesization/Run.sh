export Reports_DIR="logfiles"

mkdir $Reports_DIR

cd work

dc_shell -f synthesis.tcl | tee -i $Reports_DIR/synthesis.log