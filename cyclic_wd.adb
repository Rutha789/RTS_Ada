-- Cyclic scheduler with a watchdog:

with Ada.Calendar;              use Ada.Calendar;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;

-- add packages to use randam number generator

procedure cyclic_wd is
    Message : constant String := "Cyclic scheduler with watchdog";
    -- change/add your declarations here
    d                 : Duration := 1.0;
    Start_Time        : Time     := Clock;
    Next              : Time     := Start_Time;
    Iteration_Counter : Integer  := 0;
    Seed              : Generator;

    protected f3_completed is
        procedure Set (in_is_completed : Boolean);
        function Get return Boolean;
    private
        is_completed : Boolean := False;
    end f3_completed;

    protected body f3_completed is
        procedure Set (in_is_completed : Boolean) is
		begin
			is_completed := in_is_completed;
		end Set;

        function Get return Boolean is
        begin
            return is_completed;
        end Get;
    end f3_completed;

    procedure f1 is
        Message : constant String := "f1 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f1;

    procedure f2 is
        Message : constant String := "f2 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
    end f2;

    procedure f3 is
        Message : constant String := "f3 executing, time is now";
    begin
        Put (Message);
        Put_Line (Duration'Image (Clock - Start_Time));
        -- add a random delay here
        delay Duration(Random (Seed) * 0.2 + 0.4);
    end f3;

    task Watchdog is
        -- add your task entries for communication
        entry Start_Timer;
    end Watchdog;

    task body Watchdog is
    begin
        loop
            -- add your task code inside this loop
            select
                accept Start_Timer do
					Put_line ("Watchdog started.");
                end Start_Timer;
				-- wait 500ms
				delay 0.5;
				-- check if f3 is not completed
				if f3_completed.Get = False then
					Put_line ("WARNING! f3 exceeded 500ms computation time");
				end if;
            or
                terminate;
            end select;
        end loop;
    end Watchdog;

begin

    loop
        -- change/add your code inside this loop
        f1;
        f2;
        -- adds 500ms delays from when f1 started
        delay until (Next + 0.5);

        if Iteration_Counter mod 2 = 0 then
            f3_completed.Set (False);
            Watchdog.Start_Timer;
            f3;
            f3_completed.Set (True);
        end if;
        Iteration_Counter := Iteration_Counter + 1;

        -- set next start time of f1
		-- if the next time has already passed, wait for the start of the next second
		if Clock > Next + d then
			Next := Next + d + d;
		else
			Next := Next + d;
		end if;
        delay until Next;

    end loop;
end cyclic_wd;
