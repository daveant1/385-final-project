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


module  player1 (  input     	Clk,                // 50 MHz clock
										Reset,              // Active-high reset signal
										frame_clk,          // The clock indicating a new frame (~60Hz)
                input [7:0]	keycode,				 // Keyboard input direction
                input logic	press,
					 input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					 
					 input logic [9:0] p2_x,
					 input logic p2_punch,
					 input logic paused,
					 
                output logic [17:0] OCM_address1,
                output logic  is_sprite1,             // Whether current pixel belongs to player or background
					 output logic [9:0] p1_x,
					 output logic p1_punch,
					 output logic [9:0] p1_health
              );
    
    parameter [9:0] p1_x_init = 10'd100;  // top-left position on the X axis
    parameter [9:0] p1_y_init = 10'd300;  // top-left position on the Y axis
    parameter [9:0] player_x_min = 10'd10;       // Leftmost point on the X axis
    parameter [9:0] player_x_max = 10'd630;     // Rightmost point on the X axis
    parameter [9:0] player_y_min = 10'd150;       // Topmost point on the Y axis
    parameter [9:0] player_y_max = 10'd300;     // Bottommost point on the Y axis
    parameter [9:0] player_x_step = 10'd1;      // Step size on the X axis
    parameter [9:0] player_y_step = 10'd1;      // Step size on the Y axis
    parameter [9:0] player_size = 10'd100;        // Player size
    
    logic [9:0] p1_x_pos, p1_x_motion, p1_y_pos, p1_y_motion;
    logic [9:0] p1_x_pos_in, p1_x_motion_in, p1_y_pos_in, p1_y_motion_in;
	 
	 assign p1_x = p1_x_pos;
	 
	 // move frame counters
	 logic [4:0] move_counter, move_counter_in;
	 
	 // attack frame counter
	 logic [3:0] attack_counter, attack_counter_in;
	 logic attack_flag, attack_flag_in;
	 
	 // hurt frame counter
	 logic [2:0] hurt_counter, hurt_counter_in;
	 
	 // punch flag
    logic p1_puncher, p1_punch_in;
	 assign p1_punch = p1_puncher;
	 
	 // health bar
	 logic [9:0] health_bar, health_bar_in;
	 assign p1_health = health_bar;
	 
	 initial begin
		p1_x_pos = 10'd100;
		p1_y_pos = 10'd300;
		p1_x_motion = 10'd0;
      p1_y_motion = 10'd0;
		
		move_counter = 5'd0;
		move_counter_in = 5'd0;
		
		attack_counter = 4'd0;
		attack_counter_in = 4'd0;
		attack_flag_in = 1'b0;
		
		hurt_counter = 3'd0;
		hurt_counter_in = 3'd0;
		
		p1_puncher = 1'b0;
		p1_punch_in = 1'b0;
		
		health_bar = 10'd16;
		health_bar_in = 10'd16;
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
            p1_x_pos <= p1_x_init;
            p1_y_pos <= p1_y_init;
            p1_x_motion <= 10'd0;
            p1_y_motion <= 10'd0;
				
				move_counter <= 5'd0;
				
				attack_counter <= 4'd0;
				attack_flag <= 1'd0;
				
				hurt_counter <= 3'd0;
				
				p1_puncher <= 1'b0;
				
				health_bar <= 10'd16;
        end
        else
        begin
            p1_x_pos <= p1_x_pos_in;
            p1_y_pos <= p1_y_pos_in;
            p1_x_motion <= p1_x_motion_in;
            p1_y_motion <= p1_y_motion_in;
				
				move_counter <= move_counter_in;
				
				attack_counter <= attack_counter_in;
				attack_flag <= attack_flag_in;
				
				hurt_counter <= hurt_counter_in;
				
				p1_puncher <= p1_punch_in;
				
				health_bar <= health_bar_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        p1_x_pos_in = p1_x_pos;
        p1_y_pos_in = p1_y_pos;
        p1_x_motion_in = p1_x_motion;
        p1_y_motion_in = 1'd0;
		  
		  move_counter_in = move_counter;
		  attack_counter_in = attack_counter;
		  attack_flag_in = attack_flag;
		  hurt_counter_in = hurt_counter;
		  health_bar_in = health_bar;
		  
        
		 // Update position and motion only at rising edge of frame clock
       if (frame_clk_rising_edge)
       begin
			//hurt animation
			if(p2_punch == 1'b1 && hurt_counter_in == 3'd0 && p1_x_pos + player_size - 7'd20 > p2_x)
			begin
				if (p1_x_pos <= player_x_min)
							p1_x_motion_in = 1'd0;
            else
							p1_x_motion_in = (~(player_x_step + 1'b1) + 1'b1);
				hurt_counter_in++;
				if (health_bar_in > 10'd0)
					health_bar_in--;
				else
					health_bar_in = 10'd0;
				
				move_counter_in = 5'd0;
				attack_counter_in = 4'd0;
				attack_flag_in = 1'b0;
			end
			else if(hurt_counter_in != 3'd0)
			begin
				if (p1_x_pos <= player_x_min)
							p1_x_motion_in = 1'd0;
            else
							p1_x_motion_in = (~(player_x_step + 1'b1) + 1'b1);
				hurt_counter_in++;
				
				move_counter_in = 5'd0;
				attack_counter_in = 4'd0;
				attack_flag_in = 1'b0;
			end
			
		 	//F key - punch
			else if(paused == 1'b0 && keycode == 8'h2b && press == 1'b1 && attack_counter_in == 4'd0)
			begin
					p1_x_motion_in = 1'd0;
					
					move_counter_in = 5'd0;
					if (attack_flag_in == 1'b0)
						attack_counter_in++;
					else
						attack_counter_in = 4'd0;
					attack_flag_in = 1'b1;
			end
			//punch animation
			else if(attack_counter_in > 4'd0)
			begin
					p1_x_motion_in = 1'd0;
					
					move_counter_in = 5'd0;
					attack_counter_in++;
					attack_flag_in = 1'b1;
			end

			//A key - left
		   else if(paused == 1'b0 && keycode == 8'h1C && press == 1'b1)	
		   begin
                if (p1_x_pos <= player_x_min)
                     p1_x_motion_in = 1'd0;
                else
							p1_x_motion_in = (~(player_x_step) + 1'b1);
					
					 move_counter_in++;
					 attack_counter_in = 4'd0;
					 attack_flag_in = 1'b0;
			end
			
			//D key - right
			else if(paused == 1'b0 && keycode == 8'h23 && press == 1'b1)	
			begin
                if (p1_x_pos + player_size >= player_x_max || p1_x_pos + player_size - 7'd40 >= p2_x)
						  p1_x_motion_in = 1'd0;
                else
                    p1_x_motion_in = player_x_step;
						  
					 move_counter_in++;
					 attack_counter_in = 4'd0;
					 attack_flag_in = 1'b0;
			end
			
			//No input
			else
			begin
				p1_x_motion_in = 10'd0;
				
				move_counter_in = 5'd0;
				attack_counter_in = 4'd0;
				attack_flag_in = 1'b0;
			end
            
         p1_y_motion_in = 1'd0;
        
            // Update the player's position with its motion
            p1_x_pos_in = p1_x_pos + p1_x_motion;
            p1_y_pos_in = p1_y_pos + p1_y_motion;
      end
    end
    
    // Compute whether the pixel corresponds to sprite or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, Size;
    assign DistX = DrawX - p1_x_pos;
    assign DistY = DrawY - p1_y_pos;
    assign Size = player_size;
    always_comb
	 begin
	 	  p1_punch_in = p1_puncher;
        if (DrawX >= p1_x_pos && DistX < Size && DrawY >= p1_y_pos && DistY < Size)
         begin
			is_sprite1 = 1'b1;
			//Hurt counter
			if (hurt_counter != 3'd0)
			begin
				OCM_address1 = (DistY * 10'd100) + DistX + 16'd40000;
				p1_punch_in = 1'b0;
			end
			//Move sprite
			else if (move_counter[4] == 1)
				OCM_address1 = (DistY * 10'd100) + DistX + 16'd10000;
			//Attack_sprite
			else if (attack_counter > 4'd0)
			begin
				if (attack_counter[3] == 0)
				begin
					if (attack_counter[2] == 0)
					begin
						OCM_address1 = (DistY * 10'd100) + DistX + 16'd20000;
						p1_punch_in = 1'b0;
					end
					else
					begin
						OCM_address1 = (DistY * 10'd100) + DistX + 16'd30000;
						p1_punch_in = 1'b1;
					end
				end
				else
				begin
					if (attack_counter[2] == 0)
					begin
						OCM_address1 = (DistY * 10'd100) + DistX + 16'd30000;
						p1_punch_in = 1'b1;
					end
					else
					begin
						OCM_address1 = (DistY * 10'd100) + DistX + 16'd20000;
						p1_punch_in = 1'b0;
					end
				end
			end
			//Idle sprite
			else
			begin
				if (health_bar != 10'd0)
					OCM_address1 = (DistY * 10'd100) + DistX;
				else
					OCM_address1 = (DistY * 10'd100) + DistX + 16'd40000;
			end
			
			end
        else
         begin
			is_sprite1 = 1'b0;
			OCM_address1 = 18'h0;
		   end
    end
    
endmodule
