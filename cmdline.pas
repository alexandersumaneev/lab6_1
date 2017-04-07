{$mode objfpc}
(*
 * Project: lab6_1
 * User: alexa
 * Date: 07.04.2017
 *)
unit cmdline;

interface
    procedure init();

implementation

uses crt,regexpr,btree;

var
    cmdstr:string;
    symbols: set Of char;
    cmd_list: array[0..4] of string; //список доступных команд
    prev_cmd: string; //предыдущая команда
    cmd: string; //команда после разбиения строки
    cmd_arg: string; //аргумент команды
    my_tree:PTree;

procedure help();
var
    f: Text;
    s: string;
begin
    //выводит файл со справкой на экран
    Assign(f,'help.txt');
    Reset(f);
    while not Eof(f) do
    begin
        ReadLn(f,s);
        WriteLn(s);
    end;
    Close(f);
end;


procedure split();
var
    space_pos: Integer;
    cmd_value:Integer;
begin
    WriteLn();
    space_pos := pos(' ',cmdstr);
    if space_pos <> 0 then //если нашли пробел разбиваем команду на 2 части
    begin
        cmd := Copy(cmdstr,1,space_pos - 1); //сама команда
        cmd_arg:=Copy(cmdstr,space_pos + 1,Length(cmdstr));
        if cmd = 'delete' then
            if cmd_arg='tree' then
                delete_tree(my_tree)
            else
                begin
                    Val(cmd_arg,cmd_value);
                    delete_item(my_tree,cmd_value);
                end;
        if cmd = 'insert' then
            begin
                Val(cmd_arg,cmd_value);
                insert_item(my_tree,cmd_value);
            end;
        if cmd = 'find' then
            begin
                Val(cmd_arg,cmd_value);
                WriteLn(find_item(my_tree,cmd_value));
            end;
    end
    else
    begin
        cmd := cmdstr;
        if cmd = 'help' then
            help();
        if cmd = 'print' then
            print_tree(my_tree);
    end;
end;

procedure del_spaces(var cmd:string);
begin
    cmd:=ReplaceRegExpr('(^\s*)|(\s*$)/(\s\s)',cmd,'',false);
    cmd:=ReplaceRegExpr('\s+',cmd,' ',false);
    cmd:=ReplaceRegExpr('\s$',cmd,'',false);
end;

procedure enter();
var
    expr: string;
begin
    prev_cmd := cmdstr;
    del_spaces(cmdstr);
    expr := '^(((help)|(print)|(delete tree))$)|((insert|find|delete)\s(0|(-(1|2|3|4|5|6|7|8|9)\d*)|(1|2|3|4|5|6|7|8|9)\d*))$';
    If not ExecRegExpr(expr,cmdstr) Then
    begin
        //если команда не соответствует регулярному выражению expr
        writeln(#10#13,'Команда   *',cmdstr,'*  не найдена');
        cmdstr := '';
    end
    Else
    begin
        split();
        cmdstr := '';
        WriteLn();
    end;
end;

procedure tab();
var
    i: Integer;
begin
    del_spaces(cmdstr);
    for i:=0 to 4 do
    begin
        if pos(cmdstr,cmd_list[i]) = 1 then //если нашли команду в списке команд
        begin
            cmdstr := cmd_list[i] + ' ';
            delline;
            gotoxy(1,wherey);
            Write(cmdstr);
            break;
        end;
    end;
end;

procedure arrow_up(); //выводит предыдущую команду
begin
    cmdstr := prev_cmd;
    gotoxy(1,wherey);
    clreol;
    write(cmdstr);
end;

Procedure backspace();
Begin
    delete(cmdstr,length(cmdstr),1);
    gotoxy(wherex - 1,wherey);
    clreol;
End;

procedure key_press();
var
    key: char;
begin
    if Length(cmdstr) > 80 then //если слишком много вбили в консоль
    begin
        WriteLn(#10#13,'Максимальная длина строки 80 символов');
        cmdstr := '';
    end
    else
    begin
        key := readkey();
        If (key In symbols) Then
        Begin
            write(key);
            cmdstr := cmdstr + key;
        End;
        If (key = #27) Then //Esc
            Halt();
        If (key = #13) Then
            enter();
        If (key = #9) Then
            tab();
        If (key = #8) Then
            backspace();
        If (key = #0) Then
            Case readkey() Of
            #72: arrow_up();
            End;
    end;
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
    cmd_list[0] := 'help';
    cmd_list[1] := 'insert';
    cmd_list[2] := 'print';
    cmd_list[3] := 'find';
    cmd_list[4] := 'delete';
    symbols := ['a'..'z','0' .. '9',' ','-'];
end.