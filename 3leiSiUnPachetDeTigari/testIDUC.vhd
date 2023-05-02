library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testIDUC is
    port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end testIDUC;

architecture arh of testIDUC is

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

signal rst : std_logic;
signal en : std_logic;
signal instruction : std_logic_vector(15 downto 0);
signal PCinc : std_logic_vector(15 downto 0);
signal muxOut : std_logic_vector(15 downto 0);
signal RD1 : std_logic_vector(15 downto 0);
signal RD2 : std_logic_vector(15 downto 0);
signal extImm : std_logic_vector(15 downto 0);
signal func : std_logic_vector(2 downto 0);
signal sa : std_logic;
signal memToReg : std_logic;
signal regDst : std_logic;
signal extOp : std_logic;
signal ALUSrc : std_logic;
signal branch : std_logic;
signal jump : std_logic;
signal memWrite : std_logic;
signal regWrite : std_logic;
signal ALUOp : std_logic_vector(2 downto 0);
signal addOut : std_logic_vector(15 downto 0);
signal funcExt : std_logic_vector(15 downto 0);
signal saExt : std_logic_vector(15 downto 0);
    
begin
    MPGEn: MPG port map(en, btn(0), clk);
    MPGRst: MPG port map(rst, btn(1), clk);
    SEG7: SSD port map(clk, muxOut, an, cat);
    IFTST: IIF port map(jump, x"0000", sw(1), x"0003", en, rst, clk, instruction, PCinc);
    IDTST: ID port map(regWrite, regDst, en, extOp, clk, instruction, addOut, RD1, RD2, extImm, func, sa);
    UCTST: MainControl port map(instruction, memToReg, regDst, extOp, ALUSrc, branch, jump, memWrite,
     regWrite, ALUOp);
    
    led(10 downto 0) <= ALUOp & regDst & extOp & ALUSrc & branch & jump & memWrite & memToReg & regWrite;
    addOut <= RD1 + RD2;
    funcExt <= "0000000000000" & func;
    saExt <= "000000000000000" & sa;
   
    MuxSSDProcess: process(sw(7 downto 5), instruction, PCinc, RD1, RD2, addOut, extImm, funcExt, saExt)
    begin
        case sw(7 downto 5) is
            when "000" => muxOut <= instruction;
            when "001" => muxOut <= PCinc;
            when "010" => muxOut <= RD1;
            when "011" => muxOut <= RD2;
            when "100" => muxOut <= addOut;
            when "101" => muxOut <= extImm;
            when "110" => muxOut <= funcExt;
            when "111" => muxOut <= saExt;
        end case;
    end process;
end arh;