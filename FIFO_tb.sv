import shared_pkg::*;
import FIFO_transaction_pkg::*;

module FIFO_tb (FIFO_if.TEST F_if);

	FIFO_transaction trans1 = new();
	initial begin
		
		F_if.wr_en = $random; F_if.rd_en = $random; F_if.data_in = $random;
		F_if.rst_n = 0;
		
		@(negedge F_if.clk);
		@(negedge F_if.clk);

		F_if.rst_n = 1;

		repeat(20000) begin

			assert(trans1.randomize());

			F_if.wr_en   = trans1.wr_en;
			F_if.rd_en   = trans1.rd_en;
			F_if.data_in = trans1.data_in;

			@(negedge F_if.clk);

		end

		test_finished = 1;

	end

endmodule 