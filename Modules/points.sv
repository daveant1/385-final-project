//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  points (  input     	Clk,                // 50 MHz clock
										Reset,              // Active-high reset signal
					 input [9:0]	player_health,
					 
                output logic  [3:0] player_digit_1, player_digit_2
              );

	 logic flag, flag_in;
	 logic [3:0] digit_1, digit_2, digit_1_in, digit_2_in;
	 assign player_digit_1 = digit_1;
	 assign player_digit_2 = digit_2;
	 
	 initial begin
		digit_1 = 4'b0000;
		digit_2 = 4'b0000;
		flag_in = 1'b0;
	 end

    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            digit_1 <= 4'b0000;
				digit_2 <= 4'b0000;
				flag <= 1'b0;
        end
        else
        begin
				digit_1 <= digit_1_in;
				digit_2 <= digit_2_in;
				flag <= flag_in;
        end
    end

    always_comb
		begin
        // By default, keep variables unchanged
		  digit_1_in = digit_1;
		  digit_2_in = digit_2;
		  flag_in = flag;
		  

			if(player_health == 10'd0)
				begin
				if (flag_in == 1'b1)
					begin
					flag_in = 1'b0;
					if (digit_1_in == 4'd9)
						begin
						if (digit_2_in == 4'd9)
							begin
							digit_2_in = 4'd9;
							digit_1_in = 4'd9;
							end
						else
							begin
							digit_2_in++;
							digit_1_in = 4'd0;
							end
						end
					else
						digit_1_in++;
					end
				else
					begin
					flag_in = 1'b0;
					end
				end
			else
				begin
				flag_in = 1'b1;
				end

		end
    
endmodule
