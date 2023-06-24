# For ice40 FPGA
TOP			:=	SOC
filename	:=	SOC
pcf_file	:=	io.pcf

ICELINK_DIR=$(shell df | grep iCELink | awk '{print $$6}')
${warning iCELink path: $(ICELINK_DIR)}


$(filename).json : *.v
	yosys -p "synth_ice40 -json $(filename).json -top $(TOP)" $(filename).v

$(filename).asc : $(filename).json io.pcf
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
	iverilog -y ./ $(filename)_tb.v -o $(filename)_tb
	vvp -n $(filename)_tb -lxt2
	gtkwave ./wave.vcd

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).bin

.PHONY : clean build prog_flash simlate
