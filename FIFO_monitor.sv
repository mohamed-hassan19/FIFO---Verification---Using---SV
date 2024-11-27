import shared_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;

module FIFO_monitor(FIFO_if.MONITOR F_if);

FIFO_transaction transaction1;
FIFO_coverage coverage1;
FIFO_scoreboard scoreboard1;

logic [F_if.FIFO_WIDTH-1:0] data_in;
logic clk, rst_n, wr_en, rd_en;
logic [F_if.FIFO_WIDTH-1:0] data_out;
logic wr_ack, overflow;
logic full, empty, almostfull, almostempty, underflow;

assign data_in=F_if.data_in;
assign clk = F_if.clk;
assign rst_n=F_if.rst_n;
assign wr_en = F_if.wr_en;
assign rd_en = F_if.rd_en;
assign data_out = F_if.data_out;
assign wr_ack = F_if.wr_ack;
assign overflow = F_if.overflow;
assign full = F_if.full;
assign empty = F_if.empty;
assign almostfull = F_if.almostfull;
assign almostempty = F_if.almostempty;
assign underflow = F_if.underflow;

initial begin

	transaction1 = new();
	coverage1    = new();
	scoreboard1  = new();

	@(negedge F_if.clk);

	forever begin
		
		@(negedge F_if.clk);

		transaction1.rst_n = rst_n; transaction1.wr_en = wr_en; transaction1.rd_en = rd_en; transaction1.data_in = data_in;
		transaction1.data_out = data_out; transaction1.wr_ack = wr_ack; transaction1.full = full; transaction1.empty = empty;
		transaction1.almostfull = almostfull; transaction1.almostempty = almostempty; transaction1.overflow = overflow; transaction1.underflow = underflow;


		fork

			begin
				coverage1.sample_data(transaction1);
			end

			begin
				scoreboard1.check_data(transaction1);
			end

		join

		if (test_finished == 1) begin
			$display("At the End : error_count is: %0d and correct_count is: %0d", error_count, correct_count);
			$stop;
		end

	end
	
end

endmodule 