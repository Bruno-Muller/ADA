with Site;

-- Randomizer de place d'entr�e et de sortie
package Place_Randomizer is

   -- Obtient une place d'ent�e al�atoire
   function Random_Input return Site.Input_Places;

   -- Obtient une place de sortie al�atoire
   function Random_Output return Site.Output_Places;

end Place_Randomizer;
