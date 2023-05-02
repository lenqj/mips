library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity MEM is
    Port ( MemWrite : in STD_LOGIC;
           Address : in STD_LOGIC_VECTOR (15 downto 0);
           WriteData : in STD_LOGIC_VECTOR (15 downto 0);
           CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           ReadData : out STD_LOGIC_VECTOR (15 downto 0);
           AluResOut: out STD_LOGIC_VECTOR (15 downto 0));
end MEM;

architecture Behavioral of MEM is
type MEM_T is array(0 to 31) of std_logic_vector(15 downto 0);
signal MEM: MEM_T :=(
X"000A",  -- 10
X"0008",  -- 8
X"0009",  -- 9
X"0005",  -- 5
X"0006",  -- 6
X"0003",  -- 3
others=>x"0000");
begin

process(CLK)
begin
    if rising_edge(CLK) then
        if EN='1' and MemWrite='1' then
            MEM(conv_integer(Address(5 downto 0))) <= WriteData;
        end if;
    end if;
end process;
ReadData <= MEM(conv_integer(Address(5 downto 0)));

AluResOut <= Address;

end Behavioral;
