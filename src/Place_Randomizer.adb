with Ada.Numerics.Discrete_Random;
with Site;

-- Randomizer de place d'entr�e et de sortie
package body Place_Randomizer is

   package Integer_Randomizer is new Ada.Numerics.Discrete_Random(Integer);
   package Input_Randomizer is new Ada.Numerics.Discrete_Random(Site.Input_Places);
   package Output_Randomizer is new Ada.Numerics.Discrete_Random(Site.Output_Places);

   Integer_Generator: Integer_Randomizer.Generator;
   Input_Generator: Input_Randomizer.Generator;
   Output_Generator: Output_Randomizer.Generator;

   -- Obtient une place d'ent�e al�atoire
   function Random_Input return Site.Input_Places is
   begin
	return Input_Randomizer.Random(Input_Generator);
   end Random_Input ;

   -- Obtient une place de sortie al�atoire
   function Random_Output return Site.Output_Places is
   begin
	return Output_Randomizer.Random(Output_Generator);
   end Random_Output ;

begin

   -- On initialise les g�nerateurs pseudo-al�atoires :

   -- On s'assure que les g�n�rateurs de place d'entr�e et de sortie
   -- ont des seeds diff�rents en prenant des seeds eux m�mes al�atoires.

   -- Sinon les g�n�rateurs retourneraient les couples I1,01 puis I4,04 par exemple

   Integer_Randomizer.Reset(Gen => Integer_Generator);

   Input_Randomizer.Reset(Gen =>Input_Generator,
                          Initiator => Integer_Randomizer.Random(Integer_Generator));

   Output_Randomizer.Reset(Gen => Output_Generator,
                          Initiator => Integer_Randomizer.Random(Integer_Generator));

end Place_Randomizer;
