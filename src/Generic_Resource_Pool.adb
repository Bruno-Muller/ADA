package body Generic_Resource_Pool is

    -- Acqu�rir les ressources d'une requ�te
   procedure Acquire(Map : in Request_Map) is
   begin
      -- On acqui�re les ressources demand�es par la requ�te
      for Rsc in Resource_Id'First..Resource_Id'Last loop
         if Map(Rsc) then
            Acquire(Rsc); -- bloque si la ressource n'est pas disponible
         end if;
      end loop;
   end Acquire;

   -- Acqu�rir une ressource en particulier
   procedure Acquire(Id: in Resource_Id) is
   begin
      Resource_Pool(Id).Acquire;
   end Acquire;

   -- Lib�rer une requ�te de resource
   procedure Release(Map: in Request_Map) is
   begin
      -- On lib�re les ressources de la requ�te
      for Rsc in Resource_Id'First..Resource_Id'Last loop
         if Map(Rsc) then
            Release(Rsc);
         end if;
      end loop;
   end Release;

   -- Lib�rer une ressource en particulier
   procedure Release(Id: in Resource_Id) is
   begin
      Resource_Pool(Id).Release;
   end Release;

   protected body Resource is

      -- Lib�rer la ressource
      procedure Release is
      begin
         Acquired := False;
      end Release;

      -- Acquirer la ressource, bloque si la ressource n'est pas disponible
      entry Acquire when not Acquired is
      begin
         Acquired := True;
      end Acquire;

   end Resource;

end Generic_Resource_Pool;
