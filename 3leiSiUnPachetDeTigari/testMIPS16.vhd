library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testMIPS16 is
    port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end testMIPS16;

architecture arh of testMIPS16 is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IIF is
    port ( jump : in std_logic;
           jumpAdress : in std_logic_vector(15 downto 0);
           PCsrc : in std_logic;
           branchAdress : in std_logic_Vector(15 downto 0);
           en : in std_logic;
           rst : in std_logic;
           clk : in std_logic;
           instruction : out std_logic_vector(15 downto 0);
           PCinc : out std_logic_vector(15 downto 0));
end component;

component ID is
    port ( regWrite : in std_logic;
           regDst : in std_logic;
           en : in std_logic;
           extOp : in std_logic;
           clk : in std_logic;
           instruction : in std_logic_vector(15 downto 0);
           WD : in std_logic_vector(15 downto 0);
           RD1 : out std_logic_vector(15 downto 0);
           RD2 : out std_logic_vector(15 downto 0);
           extImm : out std_logic_vector(15 downto 0);
           func : out std_logic_vector(2 downto 0);
           sa : out std_logic
           );
end component;

component MainControl is
    port ( instruction : in std_logic_vector(15 downto 0);
           memToReg : out std_logic;
           regDst : out std_logic;
           extOp : out std_logic;
           ALUSrc : out std_logic;
           branch : out std_logic;
           jump : out std_logic;
           memWrite : out std_logic;
           regWrite : out std_logic;
           ALUOp : out std_logic_vector(2 downto 0)
         );
end component;

component EX is
    port ( RD1 : in std_logic_vector(15 downto 0);
           RD2 : in std_logic_vector(15 downto 0);
           extImm: in std_logic_vector(15 downto 0);
           PCinc : in std_logic_vector(15 downto 0);
           ALUOp : in std_logic_vector(2 downto 0);
           func : in std_logic_vector(2 downto 0);
           sa : in std_logic;
           ALUSrc : in std_logic;
           branchAdress : out std_logic_vector(15 downto 0);
           ALURes : out std_logic_vector(15 downto 0);
           zero : out std_logic
         );
end component;

component MEM is
    port ( memWrite : in std_logic;
           en : in std_logic;
           clk : in std_logic;
           ALURes : in std_logic_vector(15 downto 0);
           RD2 : in std_logic_vector(15 downto 0);
           ALUResOut : out std_logic_vector(15 downto 0);
           memData : out std_logic_vector(15 downto 0)
         );
end component;

signal en : std_logic;
signal rst : std_logic;
signal PCSrc : std_logic;
signal regDst : std_logic;
signal extOp : std_logic;
signal ALUSrc : std_logic;
signal branch : std_logic;
signal jump : std_logic;
signal memWrite : std_logic;
signal memToReg : std_logic;
signal regWrite : std_logic;
signal sa : std_logic;
signal zero : std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal jumpAdress : std_logic_vector(15 downto 0);
signal branchAdress : std_logic_vector(15 downto 0);
signal instruction : std_logic_vector(15 downto 0);
signal PCinc : std_logic_vector(15 downto 0);
signal WD : std_logic_vector(15 downto 0);
signal RD1 : std_logic_vector(15 downto 0);
signal RD2 : std_logic_vector(15 downto 0);
signal extImm : std_logic_vector(15 downto 0);
signal func : std_logic_vector(2 downto 0);
signal ALURes : std_logic_vector(15 downto 0);
signal ALUResOut : std_logic_vector(15 downto 0);
signal memData : std_logic_vector(15 downto 0);
signal digits : std_logic_vector(15 downto 0);
    
begin
    --port maping
    MPGEN: MPG port map(en, btn(0), clk);
    MPGRST: MPG port map(rst, btn(1), clk);
    SEG7: SSD port map(clk, digits, an, cat);
    IIFP:  IIF port map(jump, jumpAdress, PCSrc, branchAdress, en, rst, clk, instruction, PCinc);
    IDP: ID port map(regWrite, regDst, en, extOp, clk, instruction, WD, RD1, RD2, extImm, func, sa);
    UCP: MainControl port map(instruction, memToReg, regDst, extOp, ALUSrc, branch, jump, memWrite, regWrite, ALUOp);
    EXP: EX port map(RD1, RD2, extImm, PCinc, ALUOp, func, sa, ALUSrc, branchAdress, ALURes, zero);
    MEMP: MEM port map(memWrite, en, clk, ALURes, RD2, ALUResOut, memData);
    --port maping
    
    PCSrc <= zero AND branch;
    led(11 downto 0) <= zero & ALUOp & regDst & extOp & ALUSrc & branch & jump & memWrite & memToReg & regWrite;
    jumpAdress <= PCinc(15 downto 13) & instruction(12 downto 0);
    
    WBMuxProcess: process(memToReg, ALUResOut, memData)
    begin
        if memToReg = '1' then
            WD <= memData;
        else
            WD <= ALUResOut;
        end if;
    end process;
    
    SSDMux: process(sw(7 downto 5), instruction, PCinc, RD1, RD2, extImm, ALURes, memData, WD)
    begin
        case sw(7 downto 5) is
            when "000" => digits <= instruction;
            when "001" => digits <= PCinc;
            when "010" => digits <= RD1;
            when "011" => digits <= RD2;
            when "100" => digits <= extImm;
            when "101" => digits <= ALURes;
            when "110" => digits <= memData;
            when "111" => digits <= WD;
            when others => digits <= (others => 'X');
        end case;
    end process;
    
end arh;