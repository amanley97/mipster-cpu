LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

ENTITY CU IS
   PORT( 
      Instr      : IN     std_logic_vector (n_bits_instr - 1 DOWNTO 0);
      ALUControl : OUT    std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
      RegDst     : OUT    std_logic;
      ALUSrc     : OUT    std_logic;
      MemToReg   : OUT    std_logic;
      RegWrite   : OUT    std_logic;
      MemWrite   : OUT    std_logic; 
      BEQ        : OUT    std_logic;
      J          : OUT    std_logic;
      BNE        : OUT    std_logic;
      Jal        : OUT    std_logic;      
      Jr         : OUT    std_logic
   );
END CU;

ARCHITECTURE behav OF CU IS

	SIGNAL opcode : NATURAL RANGE 0 TO (2**(opcode_end - opcode_start + 1) - 1);
	SIGNAL funct  : NATURAL RANGE 0 TO (2**(funct_end - funct_start + 1) - 1);
	SIGNAL ALUControl_int : NATURAL RANGE 0 TO (n_functions_alu - 1);

BEGIN

   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------

   opcode <= TO_INTEGER(UNSIGNED(Instr(opcode_end DOWNTO opcode_start)));
   funct  <= TO_INTEGER(UNSIGNED(Instr(funct_end  DOWNTO funct_start)));
   ALUControl  <= STD_LOGIC_VECTOR(TO_UNSIGNED(ALUControl_int, ALUControl'length));
   
   ---------------------------------------------------------------------------
   process1: PROCESS(opcode, funct)
   ---------------------------------------------------------------------------
   BEGIN
	-- Default Values --
	ALUControl_int <= 0;
	RegDst <= '0';
	ALUSrc <= '0';
	MemToReg <= '0';
	RegWrite <= '0';
	MemWrite <= '0';
	BEQ <= '0';
	J <= '0';
	BNE <= '0';
	Jal <= '0';
	Jr <= '0';
	CASE opcode IS
		WHEN 0 =>                     -- R-Type
            CASE funct IS
                WHEN 36 =>            -- R-Type, AND
                    ALUControl_int <= 0;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 37 =>            -- R-Type, OR
                    ALUControl_int <= 1;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 32 =>            -- R-Type, add
                    ALUControl_int <= 2;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 34 =>            -- R-Type, sub
                    ALUControl_int <= 6;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 42 =>            -- R-Type, slt
                    ALUControl_int <= 7;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 39 =>            -- R-Type, NOR
                    ALUControl_int <= 12;
                    RegDst <= '1';
                    RegWrite <= '1';
                WHEN 8 =>            -- R-Type, Jr
                    RegDst <= '1';
                    Jr <= '1';
		        WHEN OTHERS => NULL;
            END CASE;
		WHEN 35 =>                    -- I-Type, lw
             ALUControl_int <= 2;
             ALUSrc <= '1';
             MemToReg <= '1';
             RegWrite <= '1';
		WHEN 43 =>                    -- I-Type, sw
             ALUControl_int <= 2;
             ALUSrc <= '1';
             MemWrite <= '1';
		WHEN 4 =>                     -- I-Type, beq
             ALUControl_int <= 6;
             BEQ <= '1';
		WHEN 2 =>                     -- J-Type, j
             J <= '1';
		WHEN 8 =>                     -- I-Type, addi
             ALUControl_int <= 2;
             ALUSrc <= '1';
             RegWrite <= '1';
        WHEN 5 =>                     -- I-Type, bne
             ALUControl_int <= 6;
             BNE <= '1';
        WHEN 3 =>                     -- J-Type, jal
             RegWrite <= '1';
             Jal <= '1';
        WHEN 13 =>                     -- I-Type, ori
             ALUControl_int <= 13;
             RegWrite <= '1';
             ALUSrc <= '1';
        WHEN 15 =>                     -- I-Type, lui
             ALUControl_int <= 15;
             RegWrite <= '1';
             ALUSrc <= '1';
		WHEN OTHERS => NULL;
	END CASE;
   END PROCESS process1;

   ----------------------------------
   
END behav;
