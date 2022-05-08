export Reports_DIR="logfiles"

mkdir $Reports_DIR

cd work

dc_shell -f synthesis_CORDIC.tcl | tee -i $Reports_DIR/synthesis_CORDIC.log
