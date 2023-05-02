library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGnED.ALL;

entity MEM is
    port ( memWrite : in std_logic;
           en : in std_logic;
           clk : in std_logic;
           ALURes : in std_logic_vector(15 downto 0);
           RD2 : in std_logic_vector(15 downto 0);
           ALUResOut : out std_logic_vector(15 downto 0);
           memData : out std_logic_vector(15 downto 0)
         );
end MEM;

architecture arh of MEM is 

type t_MEM is array(0 to 32) of std_logic_vector(15 downto 0);
signal MEM : t_mem := (
    x"0000",
    x"0001",
    x"0002",
    x"0003",
    x"0004",
    x"0005",
    x"0006",
    x"0007",
    x"0008",
    x"0009",
    x"000A",
    
    others => x"0000"
);

begin
    ALUResOut <= ALURes;
    
    MemProcess: process(clk)
    begin
        if rising_edge(clk) then 
            if en = '1' and memWrite = '1' then 
                MEM(conv_integer(ALURes(5 downto 0))) <= RD2;
            end if;
        end if;
    end process;
    
    memData <= MEM(conv_integer(ALURes(5 downto 0)));
    
end arh;