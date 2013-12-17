with Robot.Trajectory;
with Robot.Trajectory.Safe;

package body Robot is

   task body Object is
      Next: Ada.Calendar.Time := Ada.Calendar.Clock;
      Counter: Integer := 0;
      State: State_Type := Ready;
      Mouth_Opened: Boolean := False;
      Its_Trajectory: Trajectory.Safe.Object;
   begin
      loop
         select
            when State=Ready => accept Go(From: Site.Input_Places; To: Site.Output_Places) do
                  State := Following;

                  -- Ouvre un chemin (proc�dure bloquante), en fait on n'acqui�re que la place d'entr�e ici
                  Trajectory.Safe.Open(Safe_Trajectory => Its_Trajectory,
                                       From => From,
                                       To => To,
                                       Speed => 75.0);
               end Go;

               -- comme le code est synchronis� il faut mettre la boucle de d�placement � l'ext�rieur du accept pour avoir plusieurs robots simultan�ement

               -- Dessine le robot sur sa place d'entr�e
               Site.Safely.Draw_Robot(Pnt    =>  Trajectory.XY(Trajectory.Safe.Get_Trajectory(Its_Trajectory)),
                                      Radius => Radius,
                                      Direction    => Trajectory.Direction(Trajectory.Safe.Get_Trajectory(Its_Trajectory)),
                                      Mouth_Opened    => True,
                                      Clr    => Color);

               -- Le robot est sur la place d'entr�e en attente d'acqu�rir le reste des ressources
               -- Pas d'op�ration de dessins n�cessaire
               Next := Ada.Calendar.Clock;
               while Trajectory.Safe.Is_On_Departure(Its_Trajectory) loop
                  -- comme les tasks sont pr�empt�es il faut comprendre que delay 0.5 va durer plus longtemps que 0.5s
                  -- il faut g�rer le delay par raport � l'horloge du syst�me (faire un delay until Next; et pas un delay 0.5)
                  Next := Next + 0.05;
                  delay until Next;
                  -- On ne d�place pas le robot durant cette phase d'attente
                  -- mais on le titille pour qui essaie d'acquire le reste des ressources
                  Trajectory.Safe.Next(Safe_Trajectory => Its_Trajectory, DeltaT => 0.0);
               end loop;

               -- Le robot est maintenant pr�s � se d�placer
               -- Il vient d'acqu�rir toutes les ressources
               -- On dessine sont chemin
               Site.Safely.Draw_Path(Pth => Trajectory.Safe.Get_Trajectory(Its_Trajectory).Route,
                                     Clr => Color);

               Next := Ada.Calendar.Clock;
               while not Trajectory.At_End(Trajectory.Safe.Get_Trajectory(Its_Trajectory)) loop
                  Next := Next + 0.05;
                  -- On dessine le robot l� o� il se trouve
                  Site.Safely.Draw_Robot(Pnt    =>  Trajectory.XY(Trajectory.Safe.Get_Trajectory(Its_Trajectory)),
                                         Radius => Radius,
                                         Direction    => Trajectory.Direction(Trajectory.Safe.Get_Trajectory(Its_Trajectory)),
                                         Mouth_Opened    => Mouth_Opened,
                                         Clr    => Color);


                  -- Compteur utilis� pour fermer et ouvrir la bouche de Pacman
                  if Counter=7 then
                     Counter:=0;
                     Mouth_Opened := not Mouth_Opened;
                  end if;
                  Counter := Counter + 1;

                  -- On attend 0.5s
                  delay until Next;

                  -- On efface le robot
                  Site.Safely.Hide_Robot(Pnt    => Trajectory.XY(Trajectory.Safe.Get_Trajectory(Its_Trajectory)),
                                         Radius => Radius);

                  -- On d�place le robot
                  Trajectory.Safe.Next(Safe_Trajectory => Its_Trajectory, DeltaT => 0.05);


               end loop;

               -- Le robot est arriv� � destination, on ferme le chemin
               Trajectory.Safe.Close(Safe_Trajectory => Its_Trajectory);

               -- Il passe � l'�tat Ready
               State := Ready;

               -- On d�pose le message de fin de mission dans la mailbox (Discrimant)
               if Mission_Done/=null then
                  Mission_Done.Put(Id);
               end if;
         or
            when State=Ready => accept Shutdown do
                  State:=Shutdown;
               end Shutdown;
         end select;
         -- ferme la t�che quand l'�tat est shutdown
         exit when State=Shutdown;
      end loop;
   end Object;

end Robot;
