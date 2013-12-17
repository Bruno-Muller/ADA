with Site; use Site;
with Site.Places_Path;
with Place_Resource_Pool;

package body Robot.Trajectory.Safe is

   -- Ouvre un chemin
   procedure Open(Safe_Trajectory: in out Object; From: Site.Input_Places; To: Site.Output_Places; Speed: in Float) is
   begin
      Safe_Trajectory.Place_Path_Object := Site.Places_Path.Open(From => From, To => To);
      Safe_Trajectory.From := From;
      Safe_Trajectory.To := To;
      Safe_Trajectory.On_Departure := True;
      Safe_Trajectory.In_Place := True;

      -- Le robot attend de pouvoir se placer sur la place d'entr�e
      Pool.Acquire(From);

      -- Une fois que le robot a acc�s � la place d'ent�e, on ouvre le chemin
      Robot.Trajectory.Open(Trajectory_Object => Safe_Trajectory.Trajectory_Object,
                            From  => From,
                            To    => To,
                            Speed => Speed);
   end Open;

   -- D�place le robot pour un certain deltaT
   procedure Next(Safe_Trajectory: in out Object; DeltaT: in Float) is
      Pth: Site.Places_Path.Places := Site.Places_Path.Values(Safe_Trajectory.Place_Path_Object);
      Request: Pool.Request_Map := (others => False);
      Pnt: Path.Point;
   begin
      -- Si le robot vient tout juste d'arriver sur la place d'ent�e alors
      -- c'est sa premi�re tentative de d�placement et il faut dabord acqu�rir le reste des ressources
      if Safe_Trajectory.On_Departure=True then

         -- On cr�e la requ�te
         for P in Pth'First..Pth'Last loop
            -- On prend soin de ne pas inclure la place d'entr�e qui est d�j� acquise par le robot
            if Pth(P)/=Safe_Trajectory.From then
               Request(Pth(P)) := True;
            end if;
         end loop;

         -- On demande d'acqu�rir les ressources de la requ�te (proc�dure bloquante)
         Pool.Acquire(Request);

         Safe_Trajectory.On_Departure := False;
      end if;

      -- On d�place le robot
      Robot.Trajectory.Next(Trajectory_Object => Safe_Trajectory.Trajectory_Object,
                            DeltaT => DeltaT);

      -- On va v�rifier si le robot vient tout juste de lib�rer une place
      Pnt := Robot.Trajectory.XY(Safe_Trajectory.Trajectory_Object);
      if not Site.Robot_Intersects(Site.Places_Path.Value(Safe_Trajectory.Place_Path_Object),Pnt.X, Pnt.Y) and Safe_Trajectory.In_Place then
         -- Le robot vient de lib�rer une place
         Safe_Trajectory.In_Place := False;

         -- On lib�re la ressource
         Pool.Release(Site.Places_Path.Value(Safe_Trajectory.Place_Path_Object));

         -- Dor�navant ce teste de lib�ration de place protera sur la prochaine place
         Site.Places_Path.Next(Safe_Trajectory.Place_Path_Object);
      elsif Site.Robot_Intersects(Site.Places_Path.Value(Safe_Trajectory.Place_Path_Object),Pnt.X, Pnt.Y) and not Safe_Trajectory.In_Place then
         Safe_Trajectory.In_Place := True;
      end if;

   end Next;

   -- Fermer un chemin
   procedure Close(Safe_Trajectory: in out Object) is
   begin
      -- On lib�re la derni�re ressource
      -- Rq: Ne pas faire l'erreur de vouloir lib�rer toutes les ressources acquises au d�but est lib�r�e au fur et � mesure
      --     car les ressources pourraient �tre acquises par d'autres robots entre temps
      Pool.Release(Safe_Trajectory.To);
   end Close;

   -- Quand le robot est sur la place d'entr�e, et qu'il attend que les autres ressouces soient disponibles
   function Is_On_Departure(Safe_Trajectory: in Object) return Boolean is
   begin
      return Safe_Trajectory.On_Departure;
   end Is_On_Departure;

   -- R�cup�re la trajectory de la "safe" trajectory
   function Get_Trajectory(Safe_Trajectory: in out Object) return Robot.Trajectory.Object is
   begin
      return Safe_Trajectory.Trajectory_Object;
   end Get_Trajectory;

end Robot.Trajectory.Safe;
