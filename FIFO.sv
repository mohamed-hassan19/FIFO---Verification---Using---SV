////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_if.DUT F_if);

localparam max_fifo_addr = $clog2(F_if.FIFO_DEPTH);

reg [F_if.FIFO_WIDTH-1:0] mem [F_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		wr_ptr <= 0;
		F_if.wr_ack   <= 0; //reset the value of wr_ack flag
		F_if.overflow <= 0; //reset the value of overflow flag

	end
	else if (F_if.wr_en && count < F_if.FIFO_DEPTH)  begin
		mem[wr_ptr] <= F_if.data_in;
		F_if.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		F_if.wr_ack <= 0; 
	end

	if (F_if.full && F_if.wr_en && F_if.rst_n)
		F_if.overflow <= 1;
	else
		F_if.overflow <= 0;
	
end

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		rd_ptr <= 0;
		F_if.underflow <= 0; //reset the underflow flag

	end
	else if ( F_if.rd_en && count != 0 ) begin
		F_if.data_out <= mem[rd_ptr];                                                       
		rd_ptr <= rd_ptr + 1;
	end

	if (F_if.rd_en && F_if.empty && F_if.rst_n) begin  // adding the F_if.underflow signal into this block because it's sequential not combinational as it was made.
		F_if.underflow <= 1;
	end
	else begin
		F_if.underflow <= 0;
	end 
end

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ( ({F_if.wr_en, F_if.rd_en} == 2'b10) && (!F_if.full) ) || (F_if.wr_en && F_if.rd_en && F_if.empty) ) 
			count <= count + 1;
		else if ( ( ({F_if.wr_en, F_if.rd_en} == 2'b01) && (!F_if.empty) ) || (F_if.wr_en && F_if.rd_en && F_if.full) )
			count <= count - 1;
	end
end

assign F_if.full        = (count == F_if.FIFO_DEPTH)? 1 : 0;
assign F_if.empty       = (count == 0)? 1 : 0;
assign F_if.almostfull  = (count == F_if.FIFO_DEPTH-1)? 1 : 0;  // modify the functionality of reset from (count == F_if.FIFO_DEPTH-2) to (count == F_if.FIFO_DEPTH-1) 
assign F_if.almostempty = (count == 1)? 1 : 0;


always_comb begin

	if(!F_if.rst_n) begin
		reset_assert: assert final(rd_ptr == 0 && wr_ptr == 0 && count == 0 && F_if.wr_ack == 0 && F_if.overflow == 0 && F_if.underflow == 0 
			        && F_if.full == 0 && F_if.empty == 1 &&  F_if.almostfull == 0 && F_if.almostempty == 0);
	end

end

property pr1;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) ( ( ({F_if.wr_en, F_if.rd_en} == 2'b10 ) && (!F_if.full) ) || (F_if.wr_en && F_if.rd_en && F_if.empty) ) |=>
	(count == ( $past(count) + 1 ) );
endproperty

property pr2;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) ( ( ({F_if.wr_en, F_if.rd_en} == 2'b01) && (!F_if.empty) ) || (F_if.wr_en && F_if.rd_en && F_if.full) ) |=> 
	(count == ( $past(count) - 1 ) );
endproperty

property pr3;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) (F_if.rd_en && F_if.empty) |=> (F_if.underflow == 1);
endproperty

property pr4;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) (F_if.full & F_if.wr_en)   |=> (F_if.overflow == 1);
endproperty

property pr5;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) (F_if.wr_en && count < F_if.FIFO_DEPTH) |=> (F_if.wr_ack == 1);
endproperty

property pr6;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) ( F_if.wr_en && !F_if.full ) |=> (wr_ptr == ( $past(wr_ptr) + 1 ) % F_if.FIFO_DEPTH);
endproperty

property pr7;
	@(posedge F_if.clk) disable iff (!F_if.rst_n) ( F_if.rd_en && !F_if.empty ) |=> (rd_ptr == ( $past(rd_ptr) + 1 ) % F_if.FIFO_DEPTH);
endproperty

property pr8;
	@(posedge F_if.clk) (count == F_if.FIFO_DEPTH) |-> (F_if.full == 1);
endproperty

property pr9;
	@(posedge F_if.clk) (count == 0) |-> (F_if.empty == 1);
endproperty

property pr10;
	@(posedge F_if.clk) (count == F_if.FIFO_DEPTH - 1) |-> (F_if.almostfull == 1);
endproperty

property pr11;
	@(posedge F_if.clk) (count == 1) |-> (F_if.almostempty == 1);
endproperty


count_increment_assert: assert property(pr1);  count_decrement_assert: assert property(pr2);  underflow_assert: assert property(pr3);  overflow_assert: assert property(pr4);
wr_ack_assert: assert property(pr5);  wr_ptr_assert: assert property(pr6);  rd_ptr_assert: assert property(pr7); full_assert: assert property(pr8);
empty_assert : assert property(pr9); almostfull_assert: assert property(pr10); almostempty_assert: assert property(pr11);

cover property(pr1);  cover property(pr2);  cover property(pr3) ; cover property(pr4) ;  cover property(pr5);  cover property(pr6);  cover property(pr7);
cover property(pr8);  cover property(pr9);  cover property(pr10); cover property(pr11);

endmodule