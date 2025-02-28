LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

ENTITY mips_single_cycle_tb IS
END mips_single_cycle_tb;
 
ARCHITECTURE behavior OF mips_single_cycle_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
     COMPONENT mips_single_cycle
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic
        );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';

   -- Clock period definitions
   --constant clk_period : time := 10 ns; -- 100 MHz
   constant clk_period : time := 40 ns; -- 25 MHz
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mips_single_cycle PORT MAP (
          clk => clk,
          rst => rst
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- insert stimulus here
		rst <= '1';
		wait for clk_period*10;

		rst <= '0';
		wait for clk_period*100;			

      wait;
   end process;

END;
