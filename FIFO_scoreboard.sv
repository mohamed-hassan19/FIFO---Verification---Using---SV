package FIFO_scoreboard_pkg;

	import FIFO_transaction_pkg::*;
	import shared_pkg::*;

	class FIFO_scoreboard;
			
		parameter FIFO_WIDTH = 16; 
		parameter FIFO_DEPTH = 8;

		localparam max_fifo_addr = $clog2(FIFO_DEPTH);

		logic [FIFO_WIDTH-1:0] data_out_ref;
		logic wr_ack_ref, overflow_ref;
		logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

		logic [max_fifo_addr-1:0] rd_ptr_ref, wr_ptr_ref;
		logic [max_fifo_addr:0] count_ref;

		logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];

		function void check_data(FIFO_transaction F_chk);
			reference_model(F_chk);

			if(data_out_ref !== F_chk.data_out || wr_ack_ref !== F_chk.wr_ack || overflow_ref !== F_chk.overflow || underflow_ref !== F_chk.underflow 
			  || full_ref !== F_chk.full || empty_ref !== F_chk.empty || almostfull_ref !== F_chk.almostfull || almostempty_ref !== F_chk.almostempty)  begin
				
				error_count++;
				$display("%t Error - Error - Error", $time);
				$display("actual data_out: %0b but the required : %0b, actual wr_ack: %0b but the required : %0b, actual overflow: %0b but the required : %0b, actual underflow: %0b but the required : %0b",
					     F_chk.data_out, data_out_ref, F_chk.wr_ack, wr_ack_ref, F_chk.overflow, overflow_ref, F_chk.underflow, underflow_ref);
				$display("actual full: %0b but the required : %0b, actual empty: %0b but the required : %0b, actual almostfull: %0b but the required : %0b, actual almostempty: %0b but the required : %0b",
					     F_chk.full, full_ref, F_chk.empty, empty_ref, F_chk.almostfull, almostfull_ref, F_chk.almostempty, almostempty_ref);

			end
			else begin
				correct_count++;
			end

		endfunction 

		function void reference_model(FIFO_transaction F_ref);

			if (!F_ref.rst_n) begin
				wr_ack_ref = 0; rd_ptr_ref = 0; wr_ptr_ref = 0; count_ref = 0;
				overflow_ref = 0; underflow_ref = 0;
			end
			else begin

				if(F_ref.wr_en && count_ref < F_ref.FIFO_DEPTH)  begin
					mem_ref[wr_ptr_ref] = F_ref.data_in;
					wr_ack_ref = 1;
					wr_ptr_ref = wr_ptr_ref + 1;
				end
				else begin
					wr_ack_ref = 0;
				end 

				if (full_ref && F_ref.wr_en && F_ref.rst_n)
					overflow_ref = 1;
				else
					overflow_ref = 0;



				if(F_ref.rd_en && count_ref != 0)  begin 
					data_out_ref = mem_ref[rd_ptr_ref];                                                       
					rd_ptr_ref   = rd_ptr_ref + 1;
				end

				if (F_ref.rd_en && empty_ref && F_ref.rst_n)  
					underflow_ref = 1;
				else 
					underflow_ref = 0;



				if( ( ({F_ref.wr_en, F_ref.rd_en} == 2'b10) && (!full_ref) ) || (F_ref.wr_en && F_ref.rd_en && empty_ref) ) begin
					count_ref = count_ref + 1;
				end 
				else if( ( ({F_ref.wr_en, F_ref.rd_en} == 2'b01) && (!empty_ref) ) || (F_ref.wr_en && F_ref.rd_en && full_ref) ) begin
					count_ref = count_ref - 1;
				end 

			end

			full_ref        = (count_ref == F_ref.FIFO_DEPTH)? 1 : 0;
			empty_ref       = (count_ref == 0)? 1 : 0;
			almostfull_ref  = (count_ref == F_ref.FIFO_DEPTH-1)? 1 : 0;
		    almostempty_ref = (count_ref == 1)? 1 : 0;

		endfunction

	endclass

endpackage 