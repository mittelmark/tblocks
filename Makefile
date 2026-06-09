##-*- makefile -*-############################################################
#
# Copyright (C) 2026 MicroEmacs User.
#
# All rights reserved.
#
# Synopsis:    
# Authors:     MicroEmacs User
#
##############################################################################

CURRENT_MAKEFILE := $(lastword $(MAKEFILE_LIST))

## argument delegation
ARGS=

## default: list existing tasks 
.PHONY: tasks
tasks:  ## list all tasks
	@grep -Eo '^[a-z0-9]+:.+' $(CURRENT_MAKEFILE) | sed -E 's/:\s+##/\t- /g'

example:
	tclsh tblocks/tblocks.tcl --mode=table examples/cpp-does.md examples/cpp-does.svg
	tclsh tblocks/tblocks.tcl --mode=boxes examples/cpp-overload.md examples/cpp-overload.svg	
	tclsh tblocks/tblocks.tcl --mode=boxes examples/cpp-func.md examples/cpp-func.svg
	tclsh tblocks/tblocks.tcl --mode=sequence examples/sequence.md examples/sequence.svg	
	tclsh tblocks/tblocks.tcl --mode=inout examples/flow.md assets/flow.svg
