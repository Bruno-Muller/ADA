package body Agency is

   procedure Handle_Transfert(From: Site.Input_Places; To: Site.Output_Places) is
   begin
      null;
   end Handle_Transfert;

   procedure Shutdown is
   begin
      for I in 1..Agency_Robot_Table'Length loop
         Agency_Robot_Table(I).Shutdown;
      end loop ;
   end Shutdown;

end Agency;
