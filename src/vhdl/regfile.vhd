LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

ENTITY RegFile IS
   PORT( 
      RA1      : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
      RA2 	   : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
      RegWrite : IN  std_logic;
      WA  	   : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
      WD  	   : IN  std_logic_vector (reg_file_width - 1 DOWNTO 0);
      clk      : IN  std_logic;
      rst      : IN  std_logic;
      RD1 	   : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0);
      RD2 	   : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0)
   );
END RegFile;

ARCHITECTURE behav OF RegFile IS

   -- Internal signal declarations
   SIGNAL reg_file  : reg_file_type(0 to reg_file_depth - 1);

BEGIN

   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------

   -- Process that combines address guard, and multiplexer for read port 1
   ---------------------------------------------------------------------------
   read_port_1 : PROCESS (RA1, reg_file)
   ---------------------------------------------------------------------------
   BEGIN
      RD1 <= (OTHERS => '0');
      IF ((TO_INTEGER(UNSIGNED(RA1)) >= 0) AND (TO_INTEGER(UNSIGNED(RA1)) < reg_file_depth)) THEN
         RD1 <= reg_file(TO_INTEGER(UNSIGNED(RA1)));
      END IF;
   END PROCESS read_port_1;

   -- Process that combines address guard, and multiplexer for read port 2
   ---------------------------------------------------------------------------
   read_port_2 : PROCESS (RA2, reg_file)
   ---------------------------------------------------------------------------
   BEGIN
      RD2 <= (OTHERS => '0');
      IF ((TO_INTEGER(UNSIGNED(RA2)) >= 0) AND (TO_INTEGER(UNSIGNED(RA2)) < reg_file_depth)) THEN
         RD2 <= reg_file(TO_INTEGER(UNSIGNED(RA2)));
      END IF;
   END PROCESS read_port_2;

   -- Process that combines inferred registers, write-enable, and address guard for the write port
   ---------------------------------------------------------------------------
   write_port : PROCESS (clk, rst)
   ---------------------------------------------------------------------------
   BEGIN
      -- Asynchronous Reset
      IF (rst = '1') THEN
         -- Reset Actions
         reg_file <= initial_reg_file;
         reg_file(0) <= zeros;
         reg_file(stack_pointer) <= TOS; -- Stack Pointer Initialized to Top-Of-Stack
      ELSIF (clk'EVENT AND clk = '1') THEN -- inferred registers
         -- Write-enable, and address guard for write operation
         IF ((RegWrite = '1') AND ((TO_INTEGER(UNSIGNED(WA)) > 0) AND (TO_INTEGER(UNSIGNED(WA)) < reg_file_depth))) THEN
            reg_file(TO_INTEGER(UNSIGNED(WA))) <= WD;
         END IF;
      END IF;
   END PROCESS write_port;

   ---------------------------------- 

END behav;
