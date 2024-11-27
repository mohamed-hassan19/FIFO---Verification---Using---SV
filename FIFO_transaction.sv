package FIFO_transaction_pkg;

class FIFO_transaction;

parameter FIFO_WIDTH = 16; 
parameter FIFO_DEPTH = 8;

rand logic [FIFO_WIDTH-1:0] data_in;
rand logic rst_n, wr_en, rd_en;
logic [FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;

integer RD_EN_ON_DIST, WR_EN_ON_DIST;

function new(integer RD_EN_ON_DIST = 30, integer WR_EN_ON_DIST = 70);
	this.RD_EN_ON_DIST = RD_EN_ON_DIST;
	this.WR_EN_ON_DIST = WR_EN_ON_DIST;
endfunction

constraint c {

	rst_n dist {1'b0 := 10, 1'b1 := 90};
	wr_en dist {1'b1 := WR_EN_ON_DIST, 1'b0 := (100 - WR_EN_ON_DIST)};
	rd_en dist {1'b1 := RD_EN_ON_DIST, 1'b0 := (100 - RD_EN_ON_DIST)};
	
}

endclass

endpackage 