with Ada.Calendar;  use Ada.Calendar;
with Ada.Text_IO;   use Ada.Text_IO;

procedure cyclic is
    Message : constant String := "Cyclic scheduler";
    -- change/add your declarations here
    Start_Time        : Time               := Clock;
    d                 : Duration           := 1.0;
    Next              : Time               := Start_Time;
    Iteration_Counter : Integer            := 0;

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
    end f3;

begin
    loop
        -- change/add your code inside this loop
        f1;
        f2;

		-- adds 500ms delays from when f1 started
		delay until (Next + 0.5);

		-- every other second, run f3
        if Iteration_Counter mod 2 = 0 then
            f3;
        end if;

        Iteration_Counter := Iteration_Counter + 1;

		-- set next start time of f1
		Next := Next + d;
        delay until Next;
    end loop;
end cyclic;
