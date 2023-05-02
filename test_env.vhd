library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (3 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

signal cnt: STD_LOGIC_VECTOR (15 downto 0);
signal en,rst: STD_LOGIC;
signal Instruction,PCinc:STD_LOGIC_VECTOR(15 downto 0);
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal RegDst, ExtOp, AluSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite: STD_LOGIC;
signal AluOP: STD_LOGIC_VECTOR(2 downto 0);
signal RD1, RD2, Ext_Imm : STD_LOGIC_VECTOR(15 downto 0);
signal WD2 : STD_LOGIC_VECTOR(15 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
signal sa: STD_LOGIC;
signal AluRes, AluResOut, BranchAddress, MemData: STD_LOGIC_VECTOR(15 downto 0);
signal zero: STD_LOGIC;
signal JumpAddress: STD_LOGIC_VECTOR(15 downto 0);

signal PCSrc: STD_LOGIC;



component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component MPG;
component SSD is
    Port ( clk: in STD_LOGIC;
           digit0, digit1, digit2, digit3: in STD_LOGIC_VECTOR(3 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component SSD;
component IFetch is
    Port ( Jump : in STD_LOGIC;
           JumpAdr : in STD_LOGIC_VECTOR (15 downto 0);
           PCSrc : in STD_LOGIC;
           BranchAdr : in STD_LOGIC_VECTOR (15 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           PCnext : out STD_LOGIC_VECTOR (15 downto 0);
           Instruction : out STD_LOGIC_VECTOR (15 downto 0));
end component;

component IDecode is
 Port ( RegWrite : in STD_LOGIC;
        Instruction : in STD_LOGIC_VECTOR(15 downto 0);
        RegDst : in STD_LOGIC; 
        CLK : in STD_LOGIC;         
        EN : in STD_LOGIC;
        ExtOp : in STD_LOGIC;
        RD1 : out STD_LOGIC_VECTOR(15 downto 0);
        RD2 : out STD_LOGIC_VECTOR(15 downto 0);
        WD : in STD_LOGIC_VECTOR(15 downto 0);
        Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
        func : out STD_LOGIC_VECTOR(2 downto 0);
        sa : out STD_LOGIC);
end component IDecode;

component MainControl is
 Port ( Instruction : in std_logic_vector(15 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        AluSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        AluOP: out std_logic_vector(2 downto 0);
        MemWrite: out std_logic;
        MemtoReg: out std_logic;
        RegWrite: out std_logic);
end component MainControl;

component EX is
    Port ( RD1 : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           AluSrc : in STD_LOGIC;
           Ext_Imm : in STD_LOGIC_VECTOR (15 downto 0);
           sa : in STD_LOGIC;
           func : in STD_LOGIC_VECTOR (2 downto 0);
           AluOp : in STD_LOGIC_Vector(2 downto 0);
           PC_1 : in STD_LOGIC_VECTOR (15 downto 0);
           Zero : out STD_LOGIC;
           AluRes : out STD_LOGIC_VECTOR(15 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0));
end component EX;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR (15 downto 0);
           WriteData : in STD_LOGIC_VECTOR (15 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           ReadData : out STD_LOGIC_VECTOR (15 downto 0);
           AluResOut: out STD_LOGIC_VECTOR (15 downto 0));
   end component MEM;

begin

    MPG1: MPG port map(rst, btn(1), clk);
    MPG2: MPG port map(en, btn(0), clk);
    inst_IF: IFetch port map(Jump, JumpAddress, PCSrc, BranchAddress, en, rst, clk, PCinc, Instruction);
    inst_decode: IDecode port map(RegWrite, Instruction, RegDst, clk, en, ExtOp, RD1, RD2, WD2, Ext_Imm, func, sa);
    main_control: MainControl port map(Instruction, RegDst, ExtOp, AluSrc, Branch, Jump, AluOP, MemWrite, MemtoReg, RegWrite);
    execute: EX port map(RD1, RD2, AluSrc, Ext_Imm, sa, func, AluOp, PCinc, zero, AluRes, BranchAddress);
    memorie: MEM port map(MemWrite, AluRes, RD2, clk, en, MemData, AluResOut);
    
    with MemtoReg select
        WD2 <= AluResOut      when '0',
              MemData         when '1',
        (others => 'X')       when others;
 
    
    led(10 downto 0)<=ALUOp&RegDst&ExtOp&ALUSrc&Branch&Jump&MemWrite&MemToReg&RegWrite;
    JumpAddress <= Pcinc(15 downto 13)&Instruction(12 downto 0);
    
    PCSrc <= Branch and zero;
    with sw(7 downto 5) select
    digits <= Instruction       when "000",
              PCinc             when "001",
              RD1               when "010",
              RD2               when "011",
              Ext_Imm           when "100",
              AluRes            when "101",
              MemData           when "110",
              WD2               when "111",
              (others => 'X')   when others;
                  
    display: SSD port map(clk,digits(3 downto 0),digits(7 downto 4),digits(11 downto 8),digits(15 downto 12),an,cat);
   
    
end Behavioral;

