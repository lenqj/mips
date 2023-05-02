library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainControl is
 Port (
 Instruction : in std_logic_vector(15 downto 0);
 RegDst: out std_logic;
 ExtOp: out std_logic;
 AluSrc: out std_logic;
 Branch: out std_logic;
 Jump: out std_logic;
 AluOP: out std_logic_vector(2 downto 0);
 MemWrite: out std_logic;
 MemtoReg: out std_logic;
 RegWrite: out std_logic
 );
end MainControl;

architecture Behavioral of MainControl is

begin

process(Instruction(15 downto 13))
begin
 RegDst <= '0';
 ExtOp <= '0';
 AluSrc <= '0';
 Branch <= '0';
 Jump <= '0'; 
 AluOP <= "000";
 MemWrite <= '0';
 MemtoReg <= '0';
 RegWrite <= '0';
 case Instruction(15 downto 13) is
    when "000" => 
    RegDst <= '1';
    RegWrite <= '1';
    AluOP <= "000";
    
    when "001" =>
    ExtOp <= '1';
    AluSrc <= '1';
    RegWrite <= '1';
    AluOP <= "001";
    
    when "010" =>
    ExtOp <= '1';
    AluSrc <= '1';
    MemtoReg <= '1';
    RegWrite <= '1';
    AluOP <= "001";
    
    when "011" =>
    ExtOp <= '1';
    AluSrc <= '1';
    MemWrite <= '1';
    AluOP <= "001";
    
    when "100" =>
    ExtOp <= '1';
    Branch <= '1';
    AluOP <= "010";
    
    when "101" =>
    ExtOp <= '1';
    AluSrc <= '1';
    RegWrite <= '1';
    AluOP <= "011";
    
    when "110" =>
    ExtOp <= '1';
    AluSrc <= '1';
    RegWrite <= '1';
    AluOP <= "100";
    
    when "111" =>
    Jump <= '1'; 
    end case;
     
     
     

end process;


end Behavioral;
