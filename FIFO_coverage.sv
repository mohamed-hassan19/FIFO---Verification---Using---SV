package FIFO_coverage_pkg;

	import FIFO_transaction_pkg::*;

	class FIFO_coverage;

		FIFO_transaction F_cvg_txn;

		covergroup fifo_cg;

			wr_en: coverpoint F_cvg_txn.wr_en{option.weight = 0;}  rd_en: coverpoint F_cvg_txn.rd_en{option.weight = 0;}  
			full : coverpoint F_cvg_txn.full {option.weight = 0;}  empty: coverpoint F_cvg_txn.empty{option.weight = 0;}
			almostfull: coverpoint F_cvg_txn.almostfull{option.weight = 0;} almostempty: coverpoint F_cvg_txn.almostempty{option.weight = 0;}
			overflow  : coverpoint F_cvg_txn.overflow  {option.weight = 0;} underflow  : coverpoint F_cvg_txn.underflow  {option.weight = 0;}
			wr_ack: coverpoint F_cvg_txn.wr_ack{option.weight = 0;}
			
			en_with_full       : cross wr_en, rd_en, full;
			en_with_empty      : cross wr_en, rd_en, empty;
			en_with_almostfull : cross wr_en, rd_en, almostfull;
			en_with_almostempty: cross wr_en, rd_en, almostempty;
			en_with_overflow   : cross wr_en, rd_en, overflow;
			en_with_underflow  : cross wr_en, rd_en, underflow;
			en_with_wr_ack     : cross wr_en, rd_en, wr_ack;
			
		endgroup

		function new();
			fifo_cg = new();
		endfunction

		function void sample_data(FIFO_transaction F_txn);
			F_cvg_txn = F_txn;
			fifo_cg.sample();
		endfunction 
		
	endclass

endpackage 