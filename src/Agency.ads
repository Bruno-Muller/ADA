with Robot;
with Adagraph;
with Site;
with Parking;
with Generic_Mailbox;

package Agency is

   -- Fonction appel�e pour demander � l'agence de g�rer un transfert de robot de From vers To
   procedure Handle_Transfer(From: Site.Input_Places; To: Site.Output_Places);

   -- Ferme l'agence,
   procedure Shutdown;

   -- Signal d'arr�t utilis� par le Listener (cf Cours)
   protected type Signal is
      entry Wait;
      procedure Signal;
   private
      Arrived: Boolean := False;
   end Signal;

private
   -- Task qui surveille les fins de mission de ronot
   task Mission_Listener;

   -- Type pour d�crire un tableau de robot
   type Robot_Table is array(Robot.Robot_Id) of access Robot.Object;

   -- Rq: si on voulait cr�er les tasks robot ici, il aurait fallu utiliser un pragrma
   --     les tasks sont cr��es dans la partie �laboration du body
   Agency_Robot_Table: Robot_Table;

   -- Signal d'arr�t utilis� par le Listener (cf Cours)
   Cancel: Signal;
   Agency_Parking: Parking.Object;

   -- On cr�er une mailbox dont la capacit� et �gale au nombre de robots pouvant exister
   Mailbox:  access Robot.Robot_Mailbox.Object := new Robot.Robot_Mailbox.Object(Robot.Robot_Id'Size);

end Agency;
