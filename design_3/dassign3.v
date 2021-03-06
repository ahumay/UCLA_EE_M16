//`include "led_fsm.v"
//`include "code_reg.v"
////////////////////////////////////////////////////////////////
//  Main File for dassign3 
////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
//  module dassign3 (also MORSE_ENCODER)
////////////////////////////////////////////////////////////////
module dassign3(
		input 	    char_vald,
		input [7:0] charcode_data,
		input [3:0] charlen_data,
		output 	    char_next, led_drv,
		input 	    reset, clock
		);

////////////////////////////////////////////////////////////////
//  Parameter Declarations
////////////////////////////////////////////////////////////////
  parameter START = 2'b00;
  parameter CHAR = 2'b01;
 
////////////////////////////////////////////////////////////////
//  Variable Declaration
////////////////////////////////////////////////////////////////

   // Outputs from modules       
   wire       shft_data, sym_done, led_drv; 
   wire [3:0] cntr_data; 

   // Signals that needs to be generated by this module
   reg 	      char_next, char_load, shft_cnt, sym_strt;

////////////////////////////////////////////////////////////////
//  Module Instantiation
////////////////////////////////////////////////////////////////

   code_reg codestore0(charcode_data, charlen_data, char_load, 
                       sym_done, cntr_data, shft_data, reset, clock);
   led_fsm ledfsm0(sym_strt, shft_data, led_drv, sym_done, 
                   reset, clock);
        
/* Some useful pseudo-code (you have to figure out if there are
   timing consideration or sequencing that you would want to do.
   From that, you can choose to build an FSM. You can choose to 
   build it as a separate module).
 
 symbol for led_fsm = shft_data from the shifter
 sym_strt is asserted when char_vald or after you've shifted 
    a new data symbol from the shifter

 space symbol is detected when charlen_data = 4'b0000      
 shft_cnt is asserted when sym_done is asserted (if using the 
    counter to deal with a space, you'd need to enable shft_cnt for 
    a "space" symbol)

 char_next for encoder = cntr counts down to 0
    (load counter with 4'b0111 when it is a space either in 
    code_reg or here)
 char_ vald input should trigger the char_load to grab the new 
    charcode_data and charlen_data
 */

////////////////////////////////////////////////////////////////
//  Your Code Here
////////////////////////////////////////////////////////////////
  reg[1:0] fsm_st;
  reg[1:0] fsm_nx_st;

  always @(posedge clock) begin
      fsm_st <= fsm_nx_st;
   end
  
  
  always @(*) begin
    
    if(reset) begin
      fsm_nx_st = START;
	end
    case(fsm_st)
      START: begin
        if(char_vald == 1'b1) begin
          	sym_strt = 1'b1;
          	char_next = 1'b0;
          	char_load = 1'b1;
          	shft_cnt = sym_done;
            fsm_nx_st = CHAR;
        end
		else
          	sym_strt = 1'b0;
      end
      CHAR: begin
		char_next = 1'b1;
        fsm_nx_st = START;
      end
    endcase
  end
      
endmodule // dassign3
