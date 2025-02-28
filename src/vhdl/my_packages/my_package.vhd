LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.ALL;

package my_package is

	-- General MIPS Parameters --
	constant n_bits_address : natural := 32; -- 32 bits
	constant n_bits_data 	: natural := 32; -- 32 bits
	constant n_bits_instr 	: natural := 32; -- 32 bits
   	constant zeros		    : std_logic_vector(n_bits_data - 1 downto 0) := (others => '0');
   	constant nop	        : std_logic_vector(n_bits_instr - 1 downto 0) := (others => '0');
   	   	   	
	-- Register File Parameters --
	constant reg_file_depth   : natural := 32; -- 32 registers
	constant reg_file_width   : natural := n_bits_data;
	type reg_file_type is array(natural range <>) of std_logic_vector(reg_file_width - 1 downto 0);
	constant initial_reg_file : reg_file_type(0 to reg_file_depth - 1) := (others => zeros);
	constant stack_pointer    : natural := 29; -- register 29 is the stack pointer

	-- Data Memory Parameters --
	constant data_mem_depth   : natural := 128; -- 128 registers
	constant data_mem_width   : natural := n_bits_data;
	type data_mem_type is array(natural range <>) of std_logic_vector(data_mem_width - 1 downto 0);
	constant initial_data_mem : data_mem_type(0 to data_mem_depth - 1) := (others => zeros);

   	-- Instruction Memory Parameters --
   	constant instr_mem_depth   : natural := 128;
	constant instr_mem_width   : natural := n_bits_instr;
	type instr_mem_type is array(natural range <>) of std_logic_vector(instr_mem_width - 1 downto 0);
	constant initial_instr_mem : instr_mem_type(0 to instr_mem_depth - 1) := (others => nop);  

   	-- User Program Parameters --
   	constant my_program_size : natural := 51; -- Number of instructions for Recursive Fibonacci Sequence
--   	constant my_program_size : natural := 36; -- Number of instructions for Non-Recursive Fibonacci Sequence
	constant my_program : instr_mem_type(0 to my_program_size - 1) :=  
	
	    -- Recursive Fibonacci Sequence --  
	    ( -- 51 Instructions
	    "00100000000001000000000000001111", -- n = 15
	    "00111100000001010001000000000001",
	    "00110100101001010000000000001100",
	    "00001100000100000000000000000101",
	    "00001000000100000000000000000100",
	    "00100011101111011111111111110000",
	    "10101111101111110000000000001100",
	    "10101111101001010000000000001000",
	    "10101111101001000000000000000100",
	    "10101111101010000000000000000000",
	    "00000000100000000100000000100000",
	    "00000000000000000010000000100000",
	    "00001100000100000000000000011000",
	    "10101100101000100000000000000000",
	    "00100000100001000000000000000001",
	    "00100000101001010000000000000100",
	    "00000001000001000000100000101010",
	    "00010000001000001111111111111010",
	    "10001111101010000000000000000000",
	    "10001111101001000000000000000100",
	    "10001111101001010000000000001000",
	    "10001111101111110000000000001100",
	    "00100011101111010000000000010000",
	    "00000011111000000000000000001000",
	    "00100011101111011111111111101100",
	    "10101111101111110000000000010000",
	    "10101111101000010000000000001100",
	    "10101111101100000000000000001000",
	    "10101111101001000000000000000100",
	    "10101111101010000000000000000000",
	    "00000000000001000000100000101010",
	    "00010100001000000000000000000010",
	    "00000000000000000001000000100000",
	    "00001000000100000000000000101100",
	    "00100000000010000000000000000001",
	    "00010101000001000000000000000010",
	    "00000000000010000001000000100000",
	    "00001000000100000000000000101100",
	    "00100000100001001111111111111111",
	    "00001100000100000000000000011000",
	    "00000000010000001000000000100000",
	    "00100000100001001111111111111111",
	    "00001100000100000000000000011000",
	    "00000000010100000001000000100000",
	    "10001111101010000000000000000000",
	    "10001111101001000000000000000100",
	    "10001111101100000000000000001000",
	    "10001111101000010000000000001100",
	    "10001111101111110000000000010000",
	    "00100011101111010000000000010100",
	    "00000011111000000000000000001000"
	    );
--	    -----------------------------------------------------------


--      -- Non-Recursive Fibonacci Sequence --  
--	    ( -- 36 Instructions
--	    "00100000000001000000000000001111", -- n = 15
--	    "00111100000001010001000000000001",
--	    "00110100101001010000000000001100",
--	    "00001100000100000000000000000101",
--	    "00001000000100000000000000000100",
--	    "00100011101111011111111111101000",
--	    "10101111101111110000000000010100",
--	    "10101111101001010000000000010000",
--	    "10101111101001000000000000001100",
--	    "10101111101010000000000000001000",
--	    "10101111101010010000000000000100",
--	    "10101111101010100000000000000000",
--	    "00100000000010100000000000000000",
--	    "10101100101010100000000000000000",
--	    "00100000101001010000000000000100",
--	    "00010000100000000000000000001100",
--	    "00100000000010010000000000000001",
--	    "10101100101010010000000000000000",
--	    "00100000101001010000000000000100",
--	    "00100000100001001111111111111111",
--	    "00010000100000000000000000000111",
--	    "00000001001010100100000000100000",
--	    "00000001001000000101000000100000",
--	    "00000001000000000100100000100000",
--	    "10101100101010000000000000000000",
--	    "00100000101001010000000000000100",
--	    "00100000100001001111111111111111",
--	    "00010100100000001111111111111001",
--	    "10001111101010100000000000000000",
--	    "10001111101010010000000000000100",
--	    "10001111101010000000000000001000",
--	    "10001111101001000000000000001100",
--	    "10001111101001010000000000010000",
--	    "10001111101111110000000000010100",
--	    "00100011101111010000000000011000",
--	    "00000011111000000000000000001000"
--	    );
--    -----------------------------------------------------------

	--------------------------------------------------------------- 

	-- ALU Parameters --
	constant n_bits_alu  : natural := n_bits_data;
	constant n_functions_alu : natural := 16;

	-- Format Parameters --
	constant opcode_end           : natural := 31;
	constant opcode_start         : natural := 26;
	constant rs_end               : natural := 25;
	constant rs_start             : natural := 21;
	constant rt_end               : natural := 20;
	constant rt_start             : natural := 16;
	constant rd_end               : natural := 15;
	constant rd_start             : natural := 11;
	constant shamt_end            : natural := 10;
	constant shamt_start          : natural :=  6;	
	constant funct_end            : natural :=  5;
	constant funct_start          : natural :=  0;

	constant immediate_end        : natural := 15;
	constant immediate_start      : natural :=  0;
	
	constant pseudo_address_end   : natural := 25;
	constant pseudo_address_start : natural :=  0;

	-- Memory Mapping Parameters --
	constant text_segment_start : std_logic_vector(n_bits_address - 1 downto 0) := x"00400000";
	constant data_segment_start : std_logic_vector(n_bits_address - 1 downto 0) := x"10010000";
   	constant TOS : std_logic_vector(reg_file_width - 1 downto 0) := data_segment_start + (data_mem_depth - 1)*4; -- Top-Of-Stack
	

	-- Utility Functions --
	function n_bits_of (X : in integer) return integer;

end package my_package;
