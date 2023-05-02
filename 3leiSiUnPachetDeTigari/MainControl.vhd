library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainControl is
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
end MainControl;

architecture arh of MainControl is
begin
    
    MainControlProcess: process(instruction(15 downto 13))
    begin
        memToReg <= '0'; regDst <= '0'; extOp <= '0'; ALUSrc <= '0'; branch <= '0'; jump <= '0'; memWrite <= '0';
        regWrite <= '0'; ALUOp <= "000";
        
        case instruction(15 downto 13) is
            when "000" => --R Type
                regDst <= '1'; regWrite <= '1'; ALUOp <= "000";
            when "001" => --ADDi
                extOp <= '1'; ALUSrc <= '1'; regWrite <= '1'; ALUOp <= "100";
            when "010" => --LW
                extOp <= '1'; ALUSrc <= '1'; memToReg <= '1'; regWrite <= '1'; ALUOp <= "100";
            when "011" => --SW
                extOp <= '1'; ALUSrc <= '1'; memWrite <= '1'; ALUOp <= "100";
            when "100" => --BEQ
                extOp <= '1'; branch <= '1'; ALUOp <= "001";
            when "101" => --ORI
                ALUSrc <= '1'; regWrite <= '1'; ALUOp <= "101";
            when "110" => --SLTI
                extOp <= '1'; ALUSrc <= '1'; regWrite <= '1'; ALUOp <= "110";
            when "111" => --J
                jump <= '1';
        end case;
    end process;

end arh;