{$mode objfpc}
{$H+}
{$codepage UTF8}

unit cmdline;

interface
    procedure init();

implementation

uses crt,regexpr,btree,list;

const
    number = '^(0|(-(1|2|3|4|5|6|7|8|9)\d*)|((1|2|3|4|5|6|7|8|9)\d*))$';

var
    cmdstr: string;
    symbols: set Of Char;
    cmd_list: array[1..6] of string; //Список доступных команд
    prev_cmd: array[1..1000] of string;
    n_cmd, i_cmd: integer;
    my_tree: PTree;

procedure help();
var
    f: Text;
    s: string;
begin
    //Выводит файл со справкой на экран
    Assign(f,'help.txt');
    Reset(f);
    while not Eof(f) do
    begin
        ReadLn(f,s);
        WriteLn(s);
    end;
    Close(f);
end;

procedure delete_f(arg: string);
var
    i: Integer;
    s: string;
begin
    if not ExecRegExpr('(tree$)|' + number, arg) then
        WriteLn('Недопустимый аргумент команды delete')
    else if arg = 'tree' then
        delete_tree(my_tree)
    else
    begin
        Val(arg,i);
        str(i,s);
        if s = arg then
            delete_item(i,my_tree)
        else
            WriteLn('Число не соответствует типу Integer');
    end;
end;

procedure insert_f(arg: string);
var
    i: integer;
    s: string;
begin
    if not ExecRegExpr(number, arg) then
        WriteLn('Недопустимый аргумент команды insert')
    else
    begin
        Val(arg,i);
        str(i,s);
        if s = arg then
            insert_item(i,my_tree)
        else
            WriteLn('Число не соответствует типу Integer');
    end;
end;

procedure find_f(arg: string);
var
    i: integer;
    s: string;
begin
    if not ExecRegExpr(number, arg) then
        WriteLn('Недопустимый аргумент команды find')
    else
    begin
        Val(arg,i);
        str(i,s);
        if s = arg then
            WriteLn(find_item(i,my_tree))
        else
            WriteLn('Число не соответствует типу Integer');
    end;
end;

procedure print_f(arg: string);
begin
    if arg <> '' then
        WriteLn('У команды print нет аргументов')
    else
        print_tree(my_tree);
end;

procedure help_f(arg: string);
begin
    if arg <> '' then
        WriteLn('У команды help нет аргументов')
    else
        help();
end;

procedure clear_f(arg: string);
begin
    if arg <> '' then
        WriteLn('У команды clear нет аргументов')
    else
    begin
        clrscr;
        cmdstr := '';
    end;
end;

procedure split();
var
    space_pos: Integer;
    cmd: string; //Команда после разбиения строки
    cmd_arg: string; //Аргумент команды

procedure cmd_exec();
begin
    if not ExecRegExpr('(clearscr|help|print|delete|insert|find)((\s.*)|$)',cmd) then
        writeln(#10#13,'Команда   *',cmdstr,'*  не найдена')
    else
    begin
        if cmd = 'delete' then
            delete_f(cmd_arg);
        if cmd = 'insert' then
            insert_f(cmd_arg);
        if cmd = 'find' then
            find_f(cmd_arg);
        if cmd = 'print' then
            print_f(cmd_arg);
        if cmd = 'help' then
            help_f(cmd_arg);
        if cmd = 'clearscr' then
            clear_f(cmd_arg);
    end;
end;

begin
    WriteLn();
    space_pos := pos(' ',cmdstr);
    cmd_arg := '';
    if space_pos <> 0 then //Если нашли пробел разбиваем команду на 2 части
    begin
        cmd := Copy(cmdstr,1,space_pos - 1);
        cmd_arg := Copy(cmdstr,space_pos + 1,Length(cmdstr));
        cmd_exec();
    end
    else
    begin
        cmd := cmdstr;
        cmd_exec();
    end;
end;

procedure del_spaces(var cmd: string);
begin
    cmd := ReplaceRegExpr('\s+',cmd,' ',false);
    cmd := ReplaceRegExpr('(^\s)|(\s$)',cmd,'',false);
end;

procedure enter(); //ok
begin
    n_cmd += 1;
    i_cmd := n_cmd + 1;
    prev_cmd[n_cmd] := cmdstr;
    del_spaces(cmdstr);
    split();
    cmdstr := '';
    WriteLn();
end;

procedure tab(); //ok
var
    i: Integer;
    s: string;
begin
    s := cmdstr;
    del_spaces(s);
    for i:=1 to 6 do
    begin
        if pos(s,cmd_list[i]) = 1 then //Если нашли команду в списке команд
        begin
            gotoxy(1,wherey);
            clreol;
            cmdstr := cmd_list[i] + ' ';
            Write(cmdstr);
            break;
        end;
    end;
end;

procedure exit_f();
begin
    delete_tree(my_tree);
    halt();
end;

procedure arrow_up(); //ok
begin

    if i_cmd > 1 then
    begin
        dec(i_cmd);
        cmdstr := prev_cmd[i_cmd];
    end;
    gotoxy(1,wherey);
    clreol;
    Write(cmdstr);
end;

procedure arrow_down(); //ok
begin
    if i_cmd <> n_cmd  then
    begin
        inc(i_cmd);
        cmdstr := prev_cmd[i_cmd];
    end;
    gotoxy(1,wherey);
    clreol;
    Write(cmdstr);
end;

procedure arrow_left(); //ok
begin
    gotoxy(wherex - 1,wherey);
end;

procedure arrow_right(); //ok
begin
    if wherex <= Length(cmdstr) then
        gotoxy(wherex + 1,wherey);
end;

Procedure backspace(); //ok
var
    x, y, l: integer;
Begin
    x := wherex;
    y := wherey;
    delete(cmdstr,x - 1,1);
    l := Length(cmdstr);
    gotoxy(x - 1,y);
    clreol;
    write(copy(cmdstr,x - 1,l));
    gotoxy(x - 1,y);
End;

procedure key_press(); //ok
var
    key: char;
    x: integer;
begin
    if Length(cmdstr) > 50 then
    begin
        WriteLn;
        cmdstr := '';
        Sound(440);
        Delay(300);
        NoSound;
    end;
    key := readkey();
    If (key in symbols) Then
    Begin
        x := wherex;
        insert(key,cmdstr,x);
        write(copy(cmdstr,x,Length(cmdstr)));
        gotoxy(x + 1,wherey);
    End;
    If (key = #27) Then
        exit_f();
    If (key = #13) Then
        enter();
    If (key = #9) then
        tab();
    If (key = #8) Then
        backspace();
    If (key = #0) Then
        Case readkey() Of
        #72: arrow_up();
        #80: arrow_down();
        #75: arrow_left();
        #77: arrow_right();
        End;
end;


procedure init();
begin
    help();
    while(true) do
    begin
        key_press();
    end;
end;
begin
    my_tree := nil;
    n_cmd := 0;
    cmdstr := '';
    prev_cmd[1] := '';
    cmd_list[1] := 'help';
    cmd_list[2] := 'insert';
    cmd_list[3] := 'print';
    cmd_list[4] := 'find';
    cmd_list[5] := 'delete';
    cmd_list[6] := 'clearscr';
    symbols := ['a'..'z','0' .. '9',' ','-'];
end.