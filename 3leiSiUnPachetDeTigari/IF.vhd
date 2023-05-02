library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IIF is
    port ( jump : in std_logic;
           jumpAdress : in std_logic_vector(15 downto 0);
           PCsrc : in std_logic;
           branchAdress : in std_logic_Vector(15 downto 0);
           en : in std_logic;
           rst : in std_logic;
           clk : in std_logic;
           instruction : out std_logic_vector(15 downto 0);
           PCinc : out std_logic_vector(15 downto 0));
end IIF;

architecture arh of IIF is
signal PCout : std_logic_vector(15 downto 0);
signal JMuxOut : std_logic_vector(15 downto 0);
signal BMuxOut : std_logic_vector(15 downto 0);

type tROM is array(0 to 15) of std_logic_vector(15 downto 0);

--      Urmatorul program aduna intr-o bucla fiecare element dintr-un sir cu contorul corespunzator acestuia,
--  in acelasi timp aduna toate elementele intre ele.

signal ROM : tROM := (
    B"000_000_000_001_0_000", --1 x"0010" -- ADD $1, $0, $0 -- initializare registru suma
    B"000_000_000_010_0_000", --2 x"0020" -- ADD $2, $0, $0 -- initializez pointerul la locatia din memoria de date
    B"000_000_000_011_0_000", --3 x"0030" -- ADD $3, $0, $0 -- initializez contorul
    B"001_000_100_0000100",   --4 x"2204" -- ADDI $4, $0, 4 -- setez numarul de iteratii
    B"100_011_100_0000111",   --5 x"8E07" -- BEQ $3, $4, 7 -- verific inainte de fiecare intrare in bucla daca s-a atins numarul de iteratii
    B"010_010_101_0000000",   --6 x"4A80" -- LW $5, offset($2) -- aduc din memorie elementul curent din sir
    B"000_101_011_101_0_000", --7 x"15D0" -- ADD $5, $5, $3 --adun la elementul curent valoarea contorului
    B"011_010_101_0000000",   --8 x"6A80" -- SW $5, offset($2) --incarc noua valoare in memoria de date
    B"000_001_101_001_0_000", --9 x"0690" -- ADD $1, $1, $5 --adun elementul curent la suma totala
    B"001_010_010_0000001",   --10 x"2901" -- ADDI $2, $2, 1 --incrementez pointerul catre memoria de date
    B"001_011_011_0000001",   --11 x"2D81" -- ADDI $3, $3, 1 -- incrementez contorul
    B"111_0000000000100",     --12 x"E005" -- J 5 --salt la inceputul buclei
    B"011_010_001_0000000",   --13 x"6880" -- SW $1, offset($2) --salvez suma in memoria de date
    
    others => x"0000"
);
begin
    
    instruction <= ROM(conv_integer(PCout(3 downto 0)));
    PCinc <= PCout + 1;
    
    PCProcess: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PCout <= x"0000";
            elsif en = '1' then
                PCout <= JMuxOut;
            end if;
        end if;
    end process;
    
    BMUX: process(PCsrc, branchAdress, PCout)
    begin
        if PCsrc = '1' then
            BMuxOut <= branchAdress;
        else 
            BMuxOut <= PCout + 1;
        end if;
    end process;
    
    JMUX: process(jump, jumpAdress, BMuxOut)
    begin
        if jump = '1' then
            JMuxOut <= jumpAdress;
        else 
            JMuxOut <= BMuxOut;
        end if;
    end process;
end arh;