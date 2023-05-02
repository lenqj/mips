library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
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
end ID;

architecture arh of ID is

    type t_RF is array(0 to 7) of std_logic_vector(15 downto 0);
    signal RF : t_RF := (others => x"0000");
    signal WA : std_logic_vector(2 downto 0);
begin

    func <= instruction(2 downto 0);
    sa <= instruction(3);
    
    MuxWr: process(regDst, instruction(9 downto 7), instruction(6 downto 4))
    begin
        if regDst = '1' then
            WA <= instruction(6 downto 4);
        else
            WA <= instruction(9 downto 7);
        end if;
    end process;
    
    RegWrProcess: process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' and regWrite = '1' then
                RF(conv_integer(WA)) <= WD;
            end if;
        end if;
    end process;
    
    RD1 <= RF(conv_integer(instruction(12 downto 10)));
    RD2 <= RF(conv_integer(instruction(9 downto 7)));
    
    extUnitProcess: process(extOp, instruction(6 downto 0))
    begin
        if extOp = '1' then
            extImm <= instruction(6) & instruction(6) & instruction(6) & instruction(6) & instruction(6) &
            instruction(6) & instruction(6) & instruction(6) & instruction(6) & instruction(6 downto 0);
        else
            extImm <= "000000000" & instruction(6 downto 0);
        end if;
    end process;
    
end arh;