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


module  menu (  input     		Clk,                // 50 MHz clock
										Reset,              // Active-high reset signal
										frame_clk,          // The clock indicating a new frame (~60Hz)
                input [7:0]	keycode1, keycode2,				  // Keyboard input direction
                input logic	press,
					 input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					 input [9:0]	p1_health, p2_health,
					 
                output logic  [18:0] OCM_address_menu,
                output logic  paused,
					 output logic  is_menu				  // Whether current pixel belongs to menu or background
              );

	 logic menu_enable, menu_enable_in, menu_start, menu_start_in;
	 assign paused = menu_enable;
	 
	 initial begin
		menu_start = 1'b1;
		menu_enable = 1'b1;
	 end
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            menu_enable <= 1'b1;
				menu_start <= 1'b1;
        end
        else
        begin
				menu_enable <= menu_enable_in;
				menu_start <= menu_start_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
		begin
        // By default, keep variables unchanged
		  menu_enable_in = menu_enable;
		  menu_start_in = menu_start;
		  
		 // Update state of menu only at rising edge of frame clock
       if (frame_clk_rising_edge)
			begin
			//Start menu
			if(menu_start_in == 1'b1)
				begin
				if (keycode1 == 8'h5a && press == 1'b1 || keycode2 == 8'h28)
					begin
					menu_enable_in = 1'b0;
					menu_start_in = 1'b0;
					end
				else
					begin
					menu_enable_in = 1'b1;
					menu_start_in = 1'b1;
					end
				end
			
		 	//Player 1 or Player 2 wins
			else if(p2_health == 10'd0 || p1_health == 10'd0)
				begin
				menu_enable_in = 1'b1;
				end

			//No input
			else
				begin
				menu_enable_in = menu_enable;
				menu_start_in = menu_start;
				end
			
			end
		end
    
    // Compute whether the pixel corresponds to menu or background
    always_comb
		begin
      if (DrawX >= 10'd120 && DrawX < 10'd520 && DrawY >= 10'd90 && DrawY < 10'd390)
			begin
			is_menu = 1'b1;
			//Start menu
			if (menu_start == 1'b1)
				begin
				OCM_address_menu = ( (DrawY - 10'd90) * 10'd400) + (DrawX - 10'd120);
				end
			//Player 1 wins
			else if (p2_health == 10'd0)
				OCM_address_menu = ( (DrawY - 10'd90) * 10'd400) + (DrawX - 10'd120) + 18'd120000;
			//Player 2 wins
			else if (p1_health == 10'd0)
				OCM_address_menu = ( (DrawY - 10'd90) * 10'd400) + (DrawX - 10'd120) + 18'd240000;
			//Doesn't matter, game isn't even paused
			else
				OCM_address_menu = 19'h0;
			end
      else
			begin
			is_menu = 1'b0;
			OCM_address_menu = 19'h0;
			end
		end
    
endmodule
