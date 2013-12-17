with Site;

generic
   type Resource_Id is (<>);

   -- Pool de resource g�n�rique
package Generic_Resource_Pool is

   -- Type utilis� pour repr�senter une requ�te d'acc�s aux ressources
   type Request_Map is array(Resource_Id) of Boolean;

   -- Acqu�rir les ressources d'une requ�te
   procedure Acquire(Map : in Request_Map);

   -- Acqu�rir une ressource en particulier
   procedure Acquire(Id: in Resource_Id);

   -- Lib�rer une requ�te de resource
   procedure Release(Map: in Request_Map);

   -- Lib�rer une ressource en particulier
   procedure Release(Id: in Resource_Id);

private

   -- type prot�ger pour r�pr�sente une ressource
   protected type Resource is
      -- Acquirer la ressource, bloque si la ressource n'est pas disponible
      entry Acquire;

      -- Lib�rer la ressource
      procedure Release;
   private
      Acquired: Boolean := False;
   end;

   -- Pool de ressource g�n�rique
   Resource_Pool : array(Resource_Id) of Resource;

end Generic_Resource_Pool;
