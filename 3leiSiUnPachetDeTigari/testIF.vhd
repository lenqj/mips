library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity testIF is
    port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR(15 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end testIF;

architecture arh of testIF is

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

signal rst : std_logic;
signal en : std_logic;
signal instruction : std_logic_vector(15 downto 0);
signal PCinc : std_logic_vector(15 downto 0);
signal muxOut : std_logic_vector(15 downto 0);

begin
    MPGEN: MPG port map(en, btn(0), clk);
    MPGRST: MPG port map(rst, btn(1), clk);
    SEG7: SSD port map(clk, muxOut, an, cat);  
    
    IFTST: IIF port map(sw(0), x"0000", sw(1), x"0003", en, rst, clk, instruction, PCinc);
    
    process(sw(7), instruction, PCinc)
    begin
        if sw(7) = '1' then
            muxOut <= PCinc;
        else 
            muxOut <= instruction;
        end if;
    end process;
    
end arh;