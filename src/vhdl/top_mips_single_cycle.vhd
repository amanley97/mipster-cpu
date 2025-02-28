LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.my_package.ALL;

ENTITY mips_single_cycle IS
   PORT( 
      clk : IN     std_logic;
      rst : IN     std_logic
   );
END mips_single_cycle ;

ARCHITECTURE struct OF mips_single_cycle IS
   
   -- PC Register Signals --
   SIGNAL PC_next          : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_current       : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_inc           : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_cond_branch   : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL PC_uncond_branch : std_logic_vector (n_bits_address - 1 DOWNTO 0); 
   SIGNAL PC_uncond_jr     : std_logic_vector (n_bits_address - 1 DOWNTO 0);   
   
   -- Instruction Memory Signals --
   SIGNAL InstrMem_A     : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL InstrMem_Instr : std_logic_vector (instr_mem_width - 1 DOWNTO 0);
   
   -- Register File Signals --
   SIGNAL RegFile_RA1      : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_RA2      : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_RegWrite : std_logic;
   SIGNAL RegFile_WA       : std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
   SIGNAL RegFile_WD       : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   SIGNAL RegFile_RD1      : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   SIGNAL RegFile_RD2      : std_logic_vector (reg_file_width - 1 DOWNTO 0);
   
   -- ALU Signals --
   SIGNAL ALU_A          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_ALUControl : std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
   SIGNAL ALU_B          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_C          : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL ALU_zero       : std_logic;
   SIGNAL ALU_overflow   : std_logic; 
   
   -- Data Memory Signals --
   SIGNAL DataMem_A        : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL DataMem_MemWrite : std_logic;
   SIGNAL DataMem_WD       : std_logic_vector (data_mem_width - 1 DOWNTO 0);
   SIGNAL DataMem_RD       : std_logic_vector (data_mem_width - 1 DOWNTO 0);

   -- Control Unit Signals --
   SIGNAL CU_Instr      : std_logic_vector (n_bits_instr - 1 DOWNTO 0);
   SIGNAL CU_ALUControl : std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
   SIGNAL CU_ALUSrc     : std_logic;
   SIGNAL CU_BEQ        : std_logic;
   SIGNAL CU_J          : std_logic;
   SIGNAL CU_MemToReg   : std_logic;
   SIGNAL CU_MemWrite   : std_logic;
   SIGNAL CU_RegDst     : std_logic;
   SIGNAL CU_RegWrite   : std_logic;
   SIGNAL CU_BNE        : std_logic;
   SIGNAL CU_Jal        : std_logic;      
   SIGNAL CU_Jr         : std_logic;
   
   -- Format-Dependent Signals --
   SIGNAL opcode         : std_logic_vector (        opcode_end DOWNTO opcode_start);
   SIGNAL rs             : std_logic_vector (            rs_end DOWNTO rs_start);
   SIGNAL rt             : std_logic_vector (            rt_end DOWNTO rt_start);
   SIGNAL rd             : std_logic_vector (            rd_end DOWNTO rd_start);
   SIGNAL shamt          : std_logic_vector (         shamt_end DOWNTO shamt_start);
   SIGNAL funct          : std_logic_vector (         funct_end DOWNTO funct_start);
   SIGNAL immediate      : std_logic_vector (     immediate_end DOWNTO immediate_start);
   SIGNAL pseudo_address : std_logic_vector (pseudo_address_end DOWNTO pseudo_address_start);

   -- Internal Signals --
   SIGNAL immediate_Sign_Extended : std_logic_vector (n_bits_alu - 1 DOWNTO 0);
   SIGNAL relative_address        : std_logic_vector (n_bits_address - 1 DOWNTO 0);
   SIGNAL branch_taken            : std_logic;

   -- Component Declarations
   
	COMPONENT PC_register
	   PORT( 
	      PC_next    : IN     std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      clk        : IN     std_logic;
	      rst        : IN     std_logic;
	      PC_current : OUT    std_logic_vector (n_bits_address - 1 DOWNTO 0)
	   );
	END COMPONENT;   

	COMPONENT InstrMem
	   PORT( 
	      A     : IN  std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      rst   : IN  std_logic;
	      Instr : OUT std_logic_vector (instr_mem_width - 1 DOWNTO 0)
	   );
	END COMPONENT;

	COMPONENT RegFile 
	   PORT( 
	      RA1      : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      RA2      : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      RegWrite : IN  std_logic;
	      WA       : IN  std_logic_vector (n_bits_of(reg_file_depth) - 1 DOWNTO 0);
	      WD       : IN  std_logic_vector (reg_file_width - 1 DOWNTO 0);
	      clk      : IN  std_logic;
	      rst      : IN  std_logic;
	      RD1      : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0);
	      RD2      : OUT std_logic_vector (reg_file_width - 1 DOWNTO 0)
	   );
	END COMPONENT;	

	COMPONENT ALU
	   PORT( 
	      A           : IN     std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      ALUControl  : IN     std_logic_vector (n_bits_of(n_functions_alu) - 1 DOWNTO 0);
	      B           : IN     std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      C           : OUT    std_logic_vector (n_bits_alu - 1 DOWNTO 0);
	      zero        : OUT    std_logic;
	      overflow    : OUT    std_logic
	   );
	END COMPONENT;	
   
	COMPONENT DataMem
	   PORT( 
	      A        : IN  std_logic_vector (n_bits_address - 1 DOWNTO 0);
	      MemWrite : IN  std_logic;
	      WD       : IN  std_logic_vector (data_mem_width - 1 DOWNTO 0);
	      clk      : IN  std_logic;
	      rst      : IN  std_logic;
	      RD       : OUT std_logic_vector (data_mem_width - 1 DOWNTO 0)
	   );
	END COMPONENT;

	COMPONENT CU
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
	END COMPONENT;

BEGIN

      --------------------
      -- Important Hint --
      --------------------
        -- When you use the components "PC_register", "InstrMem", "RegFile", "ALU", "DataMem", and "CU", in this top-level design 
        -- "top_mips_single_cycle.vhd", name their instances by appending "_inst" to the end of the component name as follows 
        -- "PC_register_inst", "InstrMem_inst", "RegFile_inst", "ALU_inst", "DataMem_inst", and "CU_inst". 
        -- This will guarantee the correct setup of your waveform configuration for showing all needed signals. For example:
              -- PC_register_inst : PC_register
              --   PORT MAP ( 
              --             PC_next    => ... ,
              --             clk        => ... ,
              --             rst        => ... ,
              --             PC_current => ...
              --   );
      --------------------
      
   -- **************************** --
   -- DO NOT MODIFY or CHANGE the ---
   -- code template provided above --
   -- **************************** --
   
   ----- insert your code here ------
    -- Inputs to PC --
    branch_taken     <= (CU_BEQ AND ALU_zero) OR (CU_BNE AND NOT(ALU_zero));
    relative_address <= (immediate_Sign_Extended(immediate_Sign_Extended'length - 1 -2 downto 0) & "00");
    branch_taken     <= (CU_BEQ and ALU_zero) or (CU_BNE and not(ALU_zero));
    PC_uncond_jr     <= RegFile_RD1;
    PC_inc           <= STD_LOGIC_VECTOR(UNSIGNED(PC_current) + 4);
    PC_cond_branch   <= STD_LOGIC_VECTOR(UNSIGNED(PC_inc) + UNSIGNED(relative_address));
    PC_uncond_branch <= (PC_inc(PC_inc'length - 1 downto PC_inc'length - 4) & pseudo_address & "00");
    PC_next          <= PC_uncond_branch when (CU_J = '1' or CU_jal = '1') else
                        PC_cond_branch when (branch_taken = '1') else
                        PC_uncond_jr when (CU_Jr = '1') else
                        PC_inc;
     
    -- Inputs to Instruction Memory --
    InstrMem_A <= PC_current;
    
    -- Decoding --
    opcode         <= InstrMem_Instr(        opcode_end DOWNTO opcode_start);
    rs             <= InstrMem_Instr(            rs_end DOWNTO rs_start);
    rt             <= InstrMem_Instr(            rt_end DOWNTO rt_start);
    rd             <= InstrMem_Instr(            rd_end DOWNTO rd_start);
    shamt          <= InstrMem_Instr(         shamt_end DOWNTO shamt_start);
    funct          <= InstrMem_Instr(         funct_end DOWNTO funct_start);
    immediate      <= InstrMem_Instr(     immediate_end DOWNTO immediate_start);
    pseudo_address <= InstrMem_Instr(pseudo_address_end DOWNTO pseudo_address_start);
    
    -- Inputs to Register File --
    RegFile_RA1      <= rs;
    RegFile_RA2      <= rt;
    RegFile_RegWrite <= CU_RegWrite;
    RegFile_WA       <= rd when (CU_RegDst = '1') else
                        "11111" when (CU_Jal = '1') else
                        rt;
    RegFile_WD       <= DataMem_RD when (CU_MemToReg = '1') else
                        PC_inc when (CU_Jal = '1') else 
                        ALU_C;
    
    -- Sign Extension --
    immediate_Sign_Extended(immediate'length - 1 downto 0) <= immediate;
    immediate_Sign_Extended(immediate_Sign_Extended'length - 1 downto immediate'length) <= (others => immediate(immediate'length - 1));
    
    -- Inputs to ALU --
    ALU_A          <= RegFile_RD1;
    ALU_ALUControl <= CU_ALUControl;
    ALU_B          <= immediate_Sign_Extended when (CU_ALUSrc = '1') else RegFile_RD2;

    -- Inputs to Data Memory --
    DataMem_A        <= ALU_C;
    DataMem_MemWrite <= CU_MemWrite;
    DataMem_WD       <= RegFile_RD2;

    -- Inputs to CU --
    CU_Instr <= InstrMem_Instr;
    
    -- Instance port mappings.
	PC_register_inst : PC_register
	   PORT MAP ( 
	      PC_next    => PC_next,
	      clk        => clk,
	      rst        => rst,
	      PC_current => PC_current
	   );

	InstrMem_inst : InstrMem
	   PORT MAP ( 
	      A     => InstrMem_A,
	      rst   => rst,
	      Instr => InstrMem_Instr
	   );

	RegFile_inst : RegFile 
	   PORT MAP (
	      RA1      => RegFile_RA1,
	      RA2      => RegFile_RA2,
	      RegWrite => RegFile_RegWrite,
	      WA       => RegFile_WA,
	      WD       => RegFile_WD,
	      clk      => clk,
	      rst      => rst,
	      RD1      => RegFile_RD1,
	      RD2      => RegFile_RD2
	   );

	ALU_inst : ALU
	   PORT MAP ( 
	      A           => ALU_A,
	      ALUControl  => ALU_ALUControl,
	      B           => ALU_B,
	      C           => ALU_C,
	      zero        => ALU_zero,
	      overflow    => ALU_overflow
	   );

	DataMem_inst : DataMem
	   PORT MAP ( 
	      A        => DataMem_A,
	      MemWrite => DataMem_MemWrite,
	      WD       => DataMem_WD,
	      clk      => clk,
	      rst      => rst,
	      RD       => DataMem_RD
	   );

	CU_inst : CU
	   PORT MAP ( 
	      Instr      => CU_Instr,
	      ALUControl => CU_ALUControl,
	      ALUSrc     => CU_ALUSrc,
	      BEQ        => CU_BEQ,
	      J          => CU_J,
	      MemToReg   => CU_MemToReg,
	      MemWrite   => CU_MemWrite,
	      RegDst     => CU_RegDst,
	      RegWrite   => CU_RegWrite,
	      BNE        => CU_BNE,
	      Jal        => CU_Jal,
	      Jr         => CU_Jr
	   );


   ----------------------------------

END struct;
