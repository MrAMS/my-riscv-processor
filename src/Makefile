# For ice40 FPGA
TOP			:=	SOC
dirname		:=	SOC
filename	:=	$(dirname)/$(TOP)
pcf_file	:=	$(dirname)/io.pcf

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}


$(filename).json : $(dirname)/*.v
	yosys -p "synth_ice40 -json $(filename).json -top $(TOP)" *.v

$(filename).asc : $(filename).json
	nextpnr-ice40 --lp1k --package cm36 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc --freq 48

$(filename).bin : $(filename).asc 
	icepack $(filename).asc $(filename).bin

build : $(filename).bin

prog_flash : $(filename).bin 
# use shell command check if directory exist
	@if [ -d '$(ICELINK_DIR)' ]; \
        then \
            cp $(filename).bin $(ICELINK_DIR); \
        else \
            echo "iCELink not found"; \
            exit 1; \
    fi

sim:
	iverilog -y $(dirname) $(filename)_tb.v -o $(filename)_tb
	vvp -n $(filename)_tb -lxt2
	gtkwave ./wave.vcd

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).bin

.PHONY : clean build prog_flash simlate
