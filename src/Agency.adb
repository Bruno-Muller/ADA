with Robot;
with Site;

package body Agency is

   -- Fonction appel�e pour demander � l'agence de g�rer un transfert de robot de From vers To
   procedure Handle_Transfer(From: Site.Input_Places; To: Site.Output_Places) is
      Id: Robot.Robot_Id;
   begin

      -- Demande au parking un robot disponible,
      -- la valeur de retour est dans Id (out),
      -- fonction bloquante (entry) si aucun robot n'est disponible
      Agency_Parking.Take(Id);

      -- On attribue la mission au robot Id
      -- et bloque jusqu'� que la place d'entr�e soit disponible
      Agency_Robot_Table(Id).Go(From => From, To   => To);

      -- On efface le robot du parking seulement maintenant et pas dans 'Take'
      -- (pour ne pas faire disparaitre le robot du Site
      -- si il ne peut pas acc�der � la place d'entr�e)
      Site.Safely.Hide_Robot_Park(Place  => Id, Radius => Robot.Radius);
   end Handle_Transfer;

   -- Ferme l'agence,
   procedure Shutdown is
   begin
      -- Shutdown tous les robots
      for I in Agency_Robot_Table'First..Agency_Robot_Table'Last loop
         Agency_Robot_Table(I).Shutdown;
      end loop ;

      -- envoie le signal Cancel (pour abort la task du Listener)
      Cancel.Signal;
   end Shutdown;

   -- Taks pour �couter la mailbox des fins de mission
   task body Mission_Listener is
      Id: Robot.Robot_Id;
   begin
      select
         Cancel.Wait; -- Signal pour arr�ter la task
      then abort
         while True loop -- boucle infine pour �couter la mailbox
            -- on attend de recevoir un id (out)
            -- fonction bloquante (entry)
            Mailbox.Get(Id);

            -- La mission est termin�e, on met le robot au parking
            Agency_Parking.Park(Id);
         end loop;
      end select;
   end Mission_Listener;

   -- Signal d'arr�t utilis� par le Listener (cf Cours)
   protected body Signal is

      procedure Signal is
      begin
         Arrived:= True;
      end Signal;

      -- Wait bloquant tant que Signal n'a pas �t� appel�
      entry Wait when Arrived is
      begin
         Arrived := False;
      end Wait;

   end Signal;
begin
   -- On cr�er les task robot
   -- Pour modifier les robots il suffit de changer le range du type Robot.Robot_Id
   -- Rq: si on voulait cr�er les tasks robot dans la spec de Agency,
   --     il aurait fallu utiliser un pragrma
   for I in Robot.Robot_Id'First..Robot.Robot_Id'Last loop
      Agency_Robot_Table(I) := new Robot.Object(I, Mailbox, Robot.Robot_Color(I));
   end loop;
end Agency;
