{$mode objfpc}
(*
 * Project: lab6_1
 *PTreeser: alexa
 * Date: 07.04.2017
 *)

unit btree;

interface

type
    PTree = ^BinTree;
    BinTree = record
        key : integer; 
        left, right :PTree
    end;
    procedure insert_item(var root :PTree; x : integer);
    procedure print_tree(root :PTree);
    procedure delete_tree(var root: PTree);
    function find_item(root :PTree; x : integer) : boolean;
    function delete_item(root:PTree; x: integer) :PTree;

implementation

procedure insert_item(var root :PTree; x : integer);
begin
    if root = nil
    then begin
        new(root);
        root^.left := nil;
        root^.right := nil;
        root^.key := x
    end
    else if x < root^.key then 
        insert_item(root^.left, x)
    else 
        insert_item(root^.right, x)
end;

procedure print_tree(root :PTree);
begin
    if root = nil then
        WriteLn('Дерево пусто')
    else
    begin
        if root^.left <> nil then
            print_tree(root^.left);
        Writeln(root^.key);
        if root^.right <> nil then
            print_tree(root^.right);
    end;
end;

function find_item(root :PTree; x : integer) : boolean;
begin
    if root=nil then
        find_item := false
    else 
        if root^.key=x then 
            find_item := True
        else
            if x < root^.key then
                find_item := find_item(root^.left, x)
            else
                find_item := find_item(root^.right, x)
end;

function delete_item(root:PTree; x: integer) :PTree;
var
    P, v :PTree;
begin 
    if (root=nil) then
        writeln('Такого элемента нет')
    else
        if x < root^.key then 
            root^.left := delete_item(root^.left, x)
        else
        if x > root^.key then
            root^.right := delete_item(root^.right, x)
        else
        begin
            P := root;
            if root^.right=nil
            then root:=root^.left
            else
                if root^.left=nil then
                    root:=root^.right
                else
                begin 
                    v := root^.left;
                    if v^.right <> nil then
                    begin 
                        while v^.right^.right <> nil do 
                            v:= v^.right;
                        root^.key := v^.right^.key;
                        P := v^.right;
                        v^.right :=v^.right^.left;
                    end
                    else 
                    begin
                        root^.key := v^.key;
                        P := v;
                        root^.left:= root^.left^.left 
                    end;
                end;
            dispose(P);
        end;
    delete_item := root
end;

procedure delete_tree(var root: PTree);
begin
    if root^.left <> nil then
        delete_tree(root^.left);
    if root^.right <> nil then
        delete_tree(root^.right);
    Dispose(root);
    root := nil;
end;

end.