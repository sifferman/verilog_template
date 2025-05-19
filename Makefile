
TOP := blinky_tb

export BASEJUMP_STL_DIR := $(abspath third_party/basejump_stl)
export YOSYS_DATDIR := $(shell yosys-config --datdir)

RTL := $(shell \
 BASEJUMP_STL_DIR=$(BASEJUMP_STL_DIR) \
 python3 misc/convert_filelist.py Makefile rtl/rtl.f \
)

SV2V_ARGS := $(shell \
 BASEJUMP_STL_DIR=$(BASEJUMP_STL_DIR) \
 python3 misc/convert_filelist.py sv2v rtl/rtl.f \
)

.PHONY: lint sim gls icestorm_icebreaker_gls icestorm_icebreaker_program icestorm_icebreaker_flash clean

lint:
	verilator lint/verilator.vlt -f rtl/rtl.f -f dv/dv.f --lint-only --top blinky

sim:
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f rtl/rtl.f -f dv/pre_synth.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/build/rtl.sv2v.v: ${RTL} rtl/rtl.f
	mkdir -p $(dir $@)
	sv2v ${SV2V_ARGS} -w $@ -DSYNTHESIS

gls: synth/yosys_generic/build/synth.v
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f synth/yosys_generic/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/yosys_generic/build/synth.v: synth/build/rtl.sv2v.v synth/yosys_generic/yosys.tcl
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/yosys_generic/yosys.tcl' -l synth/yosys_generic/build/yosys.log

icestorm_icebreaker_gls: synth/icestorm_icebreaker/build/synth.v
	verilator lint/verilator.vlt --Mdir ${TOP}_$@_dir -f synth/icestorm_icebreaker/gls.f -f dv/dv.f --binary -Wno-fatal --top ${TOP}
	./${TOP}_$@_dir/V${TOP} +verilator+rand+reset+2

synth/icestorm_icebreaker/build/synth.v synth/icestorm_icebreaker/build/synth.json: synth/build/rtl.sv2v.v synth/icestorm_icebreaker/icebreaker.v synth/icestorm_icebreaker/yosys.tcl
	mkdir -p $(dir $@)
	yosys -p 'tcl synth/icestorm_icebreaker/yosys.tcl' -l synth/icestorm_icebreaker/build/yosys.log

synth/icestorm_icebreaker/build/icebreaker.asc: synth/icestorm_icebreaker/build/synth.json synth/icestorm_icebreaker/nextpnr.sdc synth/icestorm_icebreaker/nextpnr.pcf
	nextpnr-ice40 \
	 -l synth/icestorm_icebreaker/build/nextpnr.log \
	 --json synth/icestorm_icebreaker/build/synth.json \
	 --up5k \
	 --package sg48 \
	 --sdc synth/icestorm_icebreaker/nextpnr.sdc \
	 --pcf synth/icestorm_icebreaker/nextpnr.pcf \
	 --asc $@ \
	 --report synth/icestorm_icebreaker/build/nextpnr.json

%.bit: %.asc
	icepack $< $@

icestorm_icebreaker_program: synth/icestorm_icebreaker/build/icebreaker.bit
	sudo $(shell which openFPGALoader) -b ice40_generic $<

icestorm_icebreaker_flash: synth/icestorm_icebreaker/build/icebreaker.bit
	sudo $(shell which openFPGALoader) -f -b ice40_generic $<

synth/vivado_basys3/build/basys3/basys3.runs/impl_1/basys3.bit: synth/build/rtl.sv2v.v synth/vivado_basys3/basys3.sv synth/vivado_basys3/Basys3_Master.xdc synth/vivado_basys3/constraints.xdc synth/vivado_basys3/vivado.tcl
	rm -rf synth/vivado_basys3/build/basys3
	mkdir -p synth/vivado_basys3/build
	cd synth/vivado_basys3/build && \
	 vivado -quiet -nolog -nojournal -notrace -mode tcl \
	  -source ../vivado.tcl

vivado_basys3_program: synth/vivado_basys3/build/basys3/basys3.runs/impl_1/basys3.bit
	sudo $(shell which openFPGALoader) -b vivado_basys3 $<

clean:
	rm -rf \
	 *.memh *.memb \
	 *sim_dir *gls_dir \
	 dump.vcd dump.fst \
	 synth/build \
	 synth/yosys_generic/build \
	 synth/icestorm_icebreaker/build \
	 synth/vivado_basys3/build
