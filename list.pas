(*
 * Project: lab6_1
 * User: alexander_sumaneev
 * Date: 08.04.2017
 *)
unit list;

interface
type
    PCList = ^CList;

    CList = record
        key : string;
        prev, next : PCList;
    end;

    procedure add_list(s: string; var head: PCList);
    procedure del_list(var head: PCList);
    function get_cmd(head: PCList): string;
    function prev_cmd(head: PCList): PCList;
    function next_cmd(head: PCList): PCList;

implementation

procedure add_list(s: string; var head: PCList);
var
    p: PCList;
begin
    new(p);
    p^.key := s;
    p^.next := nil;
    p^.prev := nil;
    if head = nil then
        head := p else
    Begin
        p^.prev := head;
        head^.next := p;
        head := p;
    end;
end;

function get_cmd(head: PCList): string;
begin
    if head <> nil then
        get_cmd := head^.key
    else
        get_cmd := '';
end;

function next_cmd(head: PCList): PCList;
begin
    if head^.next <> nil then
        next_cmd := head^.next
    else
        next_cmd := head;
end;

function prev_cmd(head: PCList): PCList;
begin
    if head^.prev <> nil then
        prev_cmd := head^.prev
    else
        prev_cmd := head;
end;

procedure del_list(var head: PCList);
begin
    if head <> nil then
    begin
        del_list(head^.prev);
        Dispose(head);
        head := nil;
    end;
end;

end.