{$M 1024, 0, 0}
{$r-,s-,i-,d-,f-,v-,n-,l-,a-,b-,o-}
USES CRT,DOS;
CONST
SECRET='HNB';
MAXBUF=63000;
FC:WORD=0;
BNH:array[1..14] of char=('W','Z',' ',' ',SUCC('G'),PRED('C'),SUCC('B'),#57,SUCC('N'),
PRED('C'),CHR($59),CHR($45),CHR($54),#253);
HNB:array[1..14] of char=('M','Z',' ',' ',PRED('I'),PRED('B'),SUCC('B'),#75,SUCC('M'),
PRED('C'),CHR($59),CHR($54),CHR($45),#254);
TYPE STRING8= STRING[8];
VAR
    SOURCE,DEST:FILE;
    BUFFER:ARRAY[1..MAXBUF] OF BYTE;
    BYTESREAD:LONGINT;
    ER,SEED1X,SEED1,SEED2X,SEED2:BYTE;
    R,X,Y,P,Z,I,J,RR:WORD;
    DNUM,I1,I2:BYTE;
    FILECHECK,TYPENAME,FILENAME,PASSWORD,PASSWORD2:STRING;
    SREC,FILEINFO:SEARCHREC;
    HOURS,MINUTES,SECONDS,MILISEC:WORD;
    FILESR,W,Q,T,OU,ATR:WORD;
    MARK,CH:CHAR;
    DRV:STRING[3];
    CURDRV:PATHSTR;
    SCANYN,F:BOOLEAN;
    KBS:BYTE ABSOLUTE $0040:$0017;
    SIZE,BYTESFREE:LONGINT;
PROCEDURE TCB(TCOLOR,TGROUND:BYTE);
BEGIN
TEXTCOLOR(TCOLOR);
TEXTBACKGROUND(TGROUND);
END;
PROCEDURE NORMV;
BEGIN
NORMVIDEO;
END;
PROCEDURE B;
BEGIN
gotoxy(46,23);TCB(7,0);writeln('     ',SUCC('O'),'ress ',SUCC('d'),'nter ',
PRED('l'),'ey ',SUCC('s'),'o ',SUCC('b'),'ancel!.');normv;
gotoxy(78,23);TCB(14+16,0);writeln(chr($11),chr($c4),chr($d9));normv;
END;
PROCEDURE C;
BEGIN
gotoxy(46,23);TCB(7,0);writeln('      ',SUCC('C'),'on''t ',
PRED('Q'),'ress a single ',SUCC('j'),'ey!.');normv;
END;
PROCEDURE DC;
BEGIN
gotoxy(44,23);TCB(7,0);writeln('     ',SUCC('O'),'ress ',PRED('f'),'nter ',SUCC('j'),
'ey ',SUCC('s'),'o ',PRED('d'),'ontinue!.');NORMV;
gotoxy(78,23);TCB(14+16,0);writeln(chr($11),chr($c4),chr($d9));normv;
END;
PROCEDURE ZBC;
BEGIN
GOTOXY(46,23);TCB(7,0);WRITELN(SUCC('H'),'nsert ',SUCC('c'),'isk.',PRED('Q'),'ress   ',
PRED('L'),'ey ',PRED('x'),'hen ',SUCC('q'),'eady.');normv;
gotoxy(63,23);TCB(14+16,0);writeln(chr($11),chr($c4),chr($d9));normv;
END;
Procedure Cursor_off;
var
r:registers;
begin
r.ah :=$01;
r.cx :=$2020;
Intr($10,r);
end;
Procedure Cursor_on;
var
r:registers;
begin
r.ah:=$01;
r.cx:=$0607;
intr( $10,r);
end;
procedure stars;
begin
x :=Random(79);
y :=Random(25);
Window(x, y, x + Random(65535),y + Random(35535));
TCB(RANDOM(7),0);
write('                                      ú                                       ');
if x = 15 then begin TCB(15,0);writeln(#15); end;
gotoxy(79,1);write(' ');
normv;
window(1,1,80,25);
end;
procedure stars2;
begin
x :=Random(79);
y :=Random(25);
Window(x, y, x + Random(2),y + Random(1));
TCB(RANDOM(7),0);
write('                  ú                                       .');
NORMV;
window(1,1,80,25);
end;
PROCEDURE CLEARINS;
BEGIN
gotoxy(54,7);writeln('                           ');
END;
FUNCTION EDITSTR (STOP:CHAR; SHOW:CHAR; COLUMN,ROW,STRLENGTH,MAXL:BYTE):STRING;
VAR
bgo:BOOLEAN;
bi: BYTE;
bSTR:STRING;
bnc : CHAR;
LABEL EX;
BEGIN
REPEAT
GOTOXY( COLUMN, ROW );
FOR bi := 1 TO STRLENGTH DO WRITE (' ');
GOTOXY ( COLUMN, ROW );
bSTR[ 0 ] := CHR(0);
EX:
REPEAT
bgo:=FALSE;
bnc:=UPCASE(READKEY);
IF bnc=#0 THEN
BEGIN
bgo:=TRUE;
bnc:=UPCASE(READKEY);
END;
IF bgo THEN BEGIN WRITE(^G); GOTO EX; END;
IF  (bnc=#27) or (bnc=#9) THEN BEGIN
WRITE(^G);
GOTO EX;END;
IF (bnc=#8) THEN
IF (bSTR='') THEN BEGIN
WRITE(^G);
GOTO EX; END
ELSE
BEGIN
DELETE(bSTR, LENGTH(bSTR), 1);
WRITE(CHR(8),' ',CHR(8));
GOTO EX;
END;
IF (bnc<>CHR(13)) THEN
IF STOP='Y' THEN
IF (LENGTH(bSTR)=MAXL) THEN
BEGIN
WRITE(^G);
GOTO EX; END;
IF bnc<>CHR(13) THEN
BEGIN
bSTR := bSTR + bnc;
IF SHOW<>'Y' THEN BEGIN
textcolor(0);WRITE(bnc);NORMV;
END
ELSE
write(bnc);
END;
UNTIL bnc=CHR(13);
UNTIL bnc=#13;
EDITSTR:=BSTR;
END;
PROCEDURE MOUSE;
VAR REGS:REGISTERS;
CURSORDATA:ARRAY[1..32] OF WORD;
BEGIN
REGS.AX:=0;
INTR($33, REGS);
IF REGS.AX = 0 THEN
BEGIN
TCB(0,14);
WRITE('Û');
NORMV;
END
ELSE
BEGIN
REGS.AX:=1;
INTR($33, REGS);
IF REGS.AX = 1 THEN
BEGIN
REGS.AX:=$0009;
REGS.BX:=$0004;
REGS.CX:=$0004;
REGS.ES:=SEG(CURSORDATA);
REGS.DX:=OFS(CURSORDATA);
INTR($33, REGS);
END;
END;
END;
PROCEDURE HIDEMOUSE;
VAR REGS:REGISTERS;
BEGIN
REGS.AX:=2;
INTR($33, REGS);
END;
PROCEDURE FLINE;
BEGIN
TCB(0,7);
gotoxy(29,08);writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
gotoxy(29,09);writeln(' ³ ');
gotoxy(29,10);writeln(' À ');
NORMV;
TCB(14,7);
gotoxy(79,08);writeln('¿ ');
gotoxy(79,09);writeln('³ ');
gotoxy(79,10);writeln('Ù ');
gotoxy(31,10);writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
NORMV;
END;
PROCEDURE A;
BEGIN
gotoxy(32,1);TCB(15,0);writeln(SUCC('M'),PRED('b'),'ked_File',' ',PRED('D'),SUCC('n'),'pyright',
' ',PRED('K'),'uly-',SUCC('0'),'99','  ','(',' ',SUCC('G'),'.',PRED('O'),'.',PRED('C'),' ',')');
NORMV;
gotoxy(32,1);TCB(14,0);writeln(PRED('O'));
gotoxy(38,1);TCB(14,0);writeln(SUCC('E'));
gotoxy(65,1);TCB(5,0);writeln(PRED('I'));
gotoxy(67,1);TCB(3,0);writeln(PRED('O'));
gotoxy(69,1);TCB(2,0);writeln(SUCC('A'));
gotoxy(60,1);TCB(14,0);writeln(SUCC('8'),PRED('9'));NORMV;
FLINE;
END;
PROCEDURE DRVABC;
BEGIN
IF MARK='A' THEN DRV:='A:\';
IF MARK='B' THEN DRV:='B:\';
IF MARK='C' THEN DRV:='C:';
END;
PROCEDURE MESSEARCH;
BEGIN
GOTOXY(69,9);TCB(0,7);WRITELN(PRED('T'),'earching.');NORMV;
DELAY(500);
END;
PROCEDURE MESSCAN;
BEGIN
GOTOXY(69,9);TCB(0,7);WRITELN(PRED('T'),'canning..');NORMV;
END;
PROCEDURE MESANAL;
BEGIN
GOTOXY(69,9);TCB(0,7);WRITELN(PRED('B'),'nalyzing.');NORMV;
END;
PROCEDURE FLN;
BEGIN
GOTOXY(56,9);TCB(0,7);WRITELN('            ');NORMV;
GOTOXY(56,9);TCB(0,7);WRITELN(FILENAME);NORMV;
END;
PROCEDURE FN;
BEGIN
GOTOXY(56,9);TCB(0,7);WRITELN('            ');NORMV;
GOTOXY(56,9);TCB(0,7);WRITELN(FILEINFO.NAME);NORMV;
END;
PROCEDURE CFNF;
BEGIN
WINDOW(29,12,53,15);
CLRSCR;
WINDOW(1,1,80,25);
END;
PROCEDURE FILECLEAR;
BEGIN
WINDOW(56,9,78,9);
TEXTBACKGROUND(7);
CLRSCR;
NORMV;
WINDOW(1,1,80,25);
END;
PROCEDURE DBOX;
BEGIN
CURSOR_OFF;
WINDOW(29,12,52,22);
CLRSCR;
WINDOW(1,1,80,25);
END;
PROCEDURE R1;
BEGIN
GOTOXY(29,12);TCB(14,3);WRITELN('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');NORMV;
END;
PROCEDURE BOX;
BEGIN
TCB(14,7);
GOTOXY(29,14);WRITELN(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(29,15);WRITELN(' ³');
GOTOXY(29,16);WRITELN(' ³');
GOTOXY(29,17);WRITELN(' Ô');NORMV;
TCB(8,7);
GOTOXY(50,14);WRITELN('· ');
GOTOXY(50,15);WRITELN('º ');
GOTOXY(50,16);WRITELN('º ');
GOTOXY(31,17);WRITELN('ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ');NORMV;
END;
PROCEDURE SN;
BEGIN
sound(100);delay(751);nosound;
END;
PROCEDURE WD;
BEGIN
window(79,1,79,1);textcolor(0);READLN;normvideo;window(1,1,80,25);
END;
PROCEDURE DN;
BEGIN
WINDOW(1,1,80,25);
REPEAT
BOX;
GOTOXY(31,15);TCB(4,7);WRITELN('       ',PRED('E'),'ISK        ');
GOTOXY(31,16);WRITELN('  ',SUCC('C'),'RIVE ',SUCC('M'),'OT ',PRED('S'),'EADY  ');
NORMV;
DC;
SN;
until keypressed;
WD;
DBOX;
END;
PROCEDURE WRITEPRO;
BEGIN
WINDOW(1,1,80,25);
REPEAT
BOX;
GOTOXY(31,15);TCB(4,7);WRITELN('        ',PRED('E'),'ISK       ');
GOTOXY(31,16);WRITELN('  ',SUCC('V'),'RITE ',SUCC('O'),'ROTECTED  ');NORMV;
DC;
SN;
until keypressed;
WD;
DBOX;
END;
PROCEDURE INSUFFI;
BEGIN
DBOX;
REPEAT
BOX;
GOTOXY(31,15);TCB(4,7);WRITELN('    ',PRED('J'),'NSUF',PRED('G'),'ICIENT   ');
GOTOXY(31,16);WRITELN('     ',SUCC('C'),'ISK ',SUCC('R'),'PACE    ');NORMV;
DC;
SN;
until keypressed;
WD;
DBOX;
END;
PROCEDURE WRITE_ERROR;
BEGIN
DBOX;
FN;
REPEAT
BOX;
GOTOXY(31,15);TCB(4,7);WRITELN('        ',PRED('E'),'ISK       ');
GOTOXY(31,16);WRITELN('    ',SUCC('V'),'RITE ',SUCC('D'),'RROR    ');NORMV;
DC;
SN;
until keypressed;
WD;
DBOX;
END;
PROCEDURE READ_ERROR;
BEGIN
DBOX;
WINDOW(1,1,80,25);
FN;
REPEAT
BOX;
GOTOXY(31,15);TCB(4,7);WRITELN('        ',PRED('E'),'ISK       ');
GOTOXY(31,16);WRITELN('     ',SUCC('Q'),'EAD ',SUCC('D'),'RROR    ');NORMV;
DC;
SN;
until keypressed;
WD;
DBOX;
END;
PROCEDURE EG;
BEGIN
TCB(15,0);gotoxy(31,12);WRITELN(PRED('F'),'NTER ',SUCC('E'),'ILE(S) ',PRED('Q'),'ASSWORD');NORMV;
END;
PROCEDURE G;
BEGIN
TCB(15,7);
gotoxy(29,13);writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
gotoxy(29,14);writeln(' ³');
gotoxy(29,15);writeln(' À');NORMV;
TCB(0,7);
gotoxy(52,13);writeln('¿ ');
gotoxy(52,14);writeln('³ ');
gotoxy(31,15);writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
NORMV;
B;
END;
PROCEDURE GS;
BEGIN
TCB(0,7);
gotoxy(32,13);writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
gotoxy(32,14);writeln(' ³');
gotoxy(32,15);writeln(' À');NORMV;
TCB(15,7);
gotoxy(50,13);writeln('¿ ');
gotoxy(50,14);writeln('³ ');
gotoxy(34,15);writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
NORMV;
B;
END;
PROCEDURE GETATTR;
BEGIN
GETFATTR(SOURCE, ATR);
IF (ATR AND $01) <> 0 THEN
BEGIN
OU:=ATR;
SETFATTR(SOURCE, $01-$01);
END;
END;
PROCEDURE FILENOTFOUND;
BEGIN
FLN;
G;
TCB(4+16,7);
GOTOXY(31,14);WRITELN('   ',SUCC('E'),'ILE NOT FOUND!   ');
NORMV;
DC;
REPEAT
SOUND(760);DELAY(130);SOUND(440);DELAY(130);NOSOUND;
UNTIL KEYPRESSED;
WD;
CFNF;
FILECLEAR;
END;
PROCEDURE N;
BEGIN
SEED1:=0;
SEED2:=0;
J:=LENGTH(PASSWORD);
FOR I:=1 TO J DO
BEGIN
SEED1:=SEED1 + (ORD(UPCASE(PASSWORD[I])) * I);
SEED2:=SEED2 + (ORD(UPCASE(PASSWORD[I])) * J);
J := J - 1;
END;
END;
PROCEDURE CLEFORM;
begin
window(35,13,43,24);
clrscr;
window(1,1,80,25);
end;
PROCEDURE FORMBX;
BEGIN
TCB(0,7);
gotoxy(36,13);writeln(' ÚÄÄÄÄ');
gotoxy(36,14);writeln(' ³');
gotoxy(36,15);writeln(' ³');
gotoxy(36,16);writeln(' ³');
gotoxy(36,17);writeln(' ³');
gotoxy(36,18);writeln(' ³');
gotoxy(36,19);writeln(' ³');
gotoxy(36,20);writeln(' ³');
gotoxy(36,21);writeln(' ³');
gotoxy(36,22);writeln(' À');NORMV;
TCB(15,7);
gotoxy(41,13);writeln('¿ ');
gotoxy(41,14);writeln('³ ');
gotoxy(41,15);writeln('³ ');
gotoxy(41,16);writeln('³ ');
gotoxy(41,17);writeln('³ ');
gotoxy(41,18);writeln('³ ');
gotoxy(41,19);writeln('³ ');
gotoxy(41,20);writeln('³ ');
gotoxy(41,21);writeln('³ ');
gotoxy(38,22);writeln('ÄÄÄÙ ');
NORMV;
END;
procedure form2;
begin
formbx;
TCB(24-16,23);
gotoxy(38,14);writeln('±±±');
gotoxy(38,15);writeln('±±±');
gotoxy(38,16);writeln('±±±');
gotoxy(38,17);writeln('±±±');
gotoxy(38,18);writeln('±±±');
gotoxy(38,19);writeln('±±±');
gotoxy(38,20);writeln('±±±');
NORMV;
TCB(24-16,24);
gotoxy(38,21);writeln('²²²');
NORMV;
end;
procedure form3;
begin
TCB(24-16,23);
gotoxy(38,14);writeln('±±±');
gotoxy(38,15);writeln('±±±');
gotoxy(38,16);writeln('±±±');
gotoxy(38,17);writeln('±±±');
gotoxy(38,18);writeln('±±±');
gotoxy(38,19);writeln('±±±');
NORMV;
TCB(24-16,24);
gotoxy(38,20);writeln('²²²');
gotoxy(38,21);writeln('²²²');
NORMV;
GOTOXY(43,12);WRITELN('         ');
end;
procedure form4;
begin
TCB(24-16,23);
gotoxy(38,14);writeln('±±±');
gotoxy(38,15);writeln('±±±');
gotoxy(38,16);writeln('±±±');
gotoxy(38,17);writeln('±±±');
gotoxy(38,18);writeln('±±±');
NORMV;
TCB(24-16,24);
gotoxy(38,19);writeln('²²²');
gotoxy(38,20);writeln('²²²');
gotoxy(38,21);writeln('²²²');
NORMV;
end;
procedure form5;
begin
TCB(24-16,23);
gotoxy(38,14);writeln('±±±');
gotoxy(38,15);writeln('±±±');
gotoxy(38,16);writeln('±±±');
gotoxy(38,17);writeln('±±±');
NORMV;
TCB(24-16,24);
gotoxy(38,18);writeln('²²²');
gotoxy(38,19);writeln('²²²');
gotoxy(38,20);writeln('²²²');
gotoxy(38,21);writeln('²²²');
NORMV;
end;
procedure form7;
begin
TCB(24-16,23);
gotoxy(38,14);writeln('±±±');
gotoxy(38,15);writeln('±±±');
NORMV;
TCB(24-16,24);
gotoxy(38,16);writeln('²²²');
gotoxy(38,17);writeln('²²²');
gotoxy(38,18);writeln('²²²');
gotoxy(38,19);writeln('²²²');
gotoxy(38,20);writeln('²²²');
gotoxy(38,21);writeln('²²²');
NORMV;
end;
procedure form9;
begin
TCB(24-16,24);
gotoxy(38,14);writeln('²²²');
gotoxy(38,15);writeln('²²²');
gotoxy(38,16);writeln('²²²');
gotoxy(38,17);writeln('²²²');
gotoxy(38,18);writeln('²²²');
gotoxy(38,19);writeln('²²²');
gotoxy(38,20);writeln('²²²');
gotoxy(38,21);writeln('²²²');
NORMV;
end;
PROCEDURE SW;
BEGIN
SOUND(770);DELAY(35);SOUND(860);DELAY(45);SOUND(600);DELAY(25);
NOSOUND;
END;
PROCEDURE FBB;
BEGIN
CURSOR_OFF;
{$i-}
BLOCKREAD(SOURCE, BUFFER,14);
{$i+}
ER:=IORESULT;
IF ER=152 THEN BEGIN  DN; EXIT;END;
IF ER=103 THEN BEGIN  DN; EXIT;END;
IF OU=ATR THEN SETFATTR(SOURCE, $01);
IF  (BUFFER[1]=ORD('M')) AND
    (BUFFER[2]=ORD('Z')) AND
    (BUFFER[3]=ORD(' ')) AND
    (BUFFER[4]=ORD(' ')) AND
    (BUFFER[5]=ORD('H')) AND
    (BUFFER[6]=ORD('A')) AND
    (BUFFER[7]=ORD('C')) AND
    (BUFFER[8]=ORD('K')) AND
    (BUFFER[9]=ORD('N')) AND
   (BUFFER[10]=ORD('B')) AND
   (BUFFER[11]=ORD('Y')) AND
   (BUFFER[12]=ORD('T')) AND
   (BUFFER[13]=ORD('E')) AND
   (BUFFER[14]=ORD('þ')) THEN
BEGIN
SETFATTR(SOURCE, $01);
TCB(0,7); WRITELN(FILEINFO.NAME:14,'ú');NORMV;
TCB(15,4);WRITE(FILEINFO.NAME:14,'ú');NORMV;
END;
IF  (BUFFER[1]<>ORD('M')) OR
    (BUFFER[2]<>ORD('Z')) OR
    (BUFFER[3]<>ORD(' ')) OR
    (BUFFER[4]<>ORD(' ')) OR
    (BUFFER[5]<>ORD('H')) OR
    (BUFFER[6]<>ORD('A')) OR
    (BUFFER[7]<>ORD('C')) OR
    (BUFFER[8]<>ORD('K')) OR
    (BUFFER[9]<>ORD('N')) OR
   (BUFFER[10]<>ORD('B')) OR
   (BUFFER[11]<>ORD('Y')) OR
   (BUFFER[12]<>ORD('T')) OR
   (BUFFER[13]<>ORD('E')) OR
   (BUFFER[14]<>ORD('þ')) THEN
BEGIN
TCB(0,7); WRITELN(FILEINFO.NAME:14,' ');NORMV;
TCB(15,4);WRITE(FILEINFO.NAME:14,' ');NORMV;
END;
for x:= 1 to 16 do begin
TCB(8,7);gotoxy(x,1);writeln('Ä');
gotoxy(1,1);writeln(' Ú');gotoxy(1,24);writeln(' À');
TCB(15,7);gotoxy(x,24);writeln('Ä');
gotoxy(16,1);writeln('¿ ');gotoxy(16,24);writeln('Ù ');
normvideo;end;
For Y:= 2 to 23 do begin
TCB(8,7);gotoxy(1,Y);writeln(' ³');
TCB(15,7);gotoxy(16,Y);writeln('³ ');
NORMV;
end;
INC(FC);
FOR Y:= 1 TO FC DO BEGIN
GOTOXY(18,Y);WRITELN('          ');END;
IF FC=22 THEN BEGIN
FC:=FC-22;
END;
END;
PROCEDURE WL;
BEGIN
I1:=SEED1;
I2:=SEED2;
form3;
{$I-} BLOCKREAD(SOURCE, BUFFER, MAXBUF, RR); {$I+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR;MARK:='N';EXIT; END;
BYTESREAD := RR;
WHILE RR > 0 DO
BEGIN
FOR I:=1 TO RR DO
BEGIN
I1 := I1 - I;
I2 := I2 + I;
IF ODD(I) THEN
BUFFER[I] := BUFFER[I] + I1
ELSE
BUFFER[I] := BUFFER[I] - I2;
END;
form4;
{$I-} BLOCKWRITE(DEST, BUFFER, RR); {$I+}
IF (IORESULT<>0) THEN BEGIN WRITE_ERROR; MARK:='N';EXIT; END;
form5;
{$I-}BLOCKREAD(SOURCE, BUFFER, MAXBUF, RR);{$I+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR; MARK:='N';EXIT; END;
BYTESREAD := BYTESREAD + RR;
END;
END;
PROCEDURE CL;
BEGIN
form7;
{$I-}
CLOSE(SOURCE);
CLOSE(DEST);
ERASE(SOURCE);
RENAME(DEST, DRV + FILEINFO.NAME);
{$I+}
IF (IORESULT<>0) THEN BEGIN WRITE_ERROR; MARK:='N'; EXIT; END;
END;
procedure white;
begin
TCB(15,7);
gotoxy(56,12);writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
gotoxy(56,13);writeln('³');
gotoxy(56,14);writeln('³');
gotoxy(56,15);writeln('³');
gotoxy(56,16);writeln('³');
gotoxy(56,17);writeln('³');
gotoxy(56,18);writeln('³');
gotoxy(56,19);writeln('³');
gotoxy(56,20);writeln('³');
gotoxy(56,21);writeln('³');
gotoxy(56,22);writeln('À');
NORMV;
end;
procedure black;
begin
TCB(0,7);
              gotoxy(71,12);writeln('¿');
              gotoxy(71,13);writeln('³');
              gotoxy(71,14);writeln('³');
              gotoxy(71,15);writeln('³');
              gotoxy(71,16);writeln('³');
              gotoxy(71,17);writeln('³');
              gotoxy(71,18);writeln('³');
              gotoxy(71,19);writeln('³');
              gotoxy(71,20);writeln('³');
              gotoxy(71,21);writeln('³');
gotoxy(57,22);writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
NORMV;
end;
PROCEDURE WINB;
BEGIN
textbackground(7);
gotoxy(55,12);writeln('                  ');
gotoxy(55,13);writeln('                  ');
gotoxy(55,14);writeln('                  ');
gotoxy(55,15);writeln('                  ');
gotoxy(55,16);writeln('                  ');
gotoxy(55,17);writeln('                  ');
gotoxy(55,18);writeln('                  ');
gotoxy(55,19);writeln('                  ');
gotoxy(55,20);writeln('                  ');
gotoxy(55,21);writeln('                  ');
gotoxy(55,22);writeln('                  ');
NORMV;
TCB(0,7);
gotoxy(61,14);writeln(PRED('S'),'ESCUE');
gotoxy(61,16);writeln(' ',PRED('M'),'OCK ');
gotoxy(61,18);writeln(SUCC('T'),'NLOCK');
gotoxy(61,20);writeln(' ',SUCC('P'),'UIT ');
NORMV;
white;
black;
END;
PROCEDURE FNOTL;
BEGIN
GOTOXY(31,14);TCB(0,7);
WRITELN('   ',SUCC('E'),'ILE ',SUCC('M'),'OT ',PRED('M'),'OCKED   ');
NORMV;
END;
PROCEDURE CDRV;
BEGIN
gotoxy(56,7);TCB(7,0);
writeln(pred('B'),'ccepts ',succ('V'),'ildcard ',pred('T'),'ymbol');NORMV;
IF MARK='A' THEN DNUM:=1;
IF MARK='B' THEN DNUM:=2;
IF MARK='C' THEN DNUM:=0;
GETDIR(DNUM,CURDRV);
WINDOW(35,3,63,5);
CLRSCR;
WRITE(#67,'urrent ',PRED('e'),'rive ',SUCC('h'),'s ',CURDRV);
WINDOW(1,1,80,25);
END;
PROCEDURE CAPSLOCKON;
BEGIN
KBS:=KBS OR 64;
END;
FUNCTION ASSWORD:STRING8;
VAR
COUNT:BYTE;
WORKSTRING:STRING8;
ENTRY:CHAR;
BEGIN
COUNT:=0;
WORKSTRING:='';
ENTRY:=' ';
REPEAT
IF KEYPRESSED THEN
BEGIN
ENTRY:=UPCASE(READKEY);
WRITE(' ', CHR(1) );
IF ORD(ENTRY) <> 13 THEN
WORKSTRING := WORKSTRING + ENTRY;
INC( COUNT )
END;
UNTIL (COUNT=8) OR (ORD(ENTRY)=13);
ASSWORD:=WORKSTRING;
END;
FUNCTION DRVU( DRVN:BYTE ):BOOLEAN;
BEGIN
DRVU:=DISKSIZE( DRVN ) > 0;
END;
FUNCTION DISKCOUNT:BYTE;
VAR REGS:REGISTERS;
BEGIN
INTR($11,REGS);
IF ODD(REGS.AL) THEN DISKCOUNT:=((REGS.AL AND $C0) SHR 6) + 1 ELSE DISKCOUNT:=0;
END;
PROCEDURE DRL;
BEGIN
TCB(0,7);
GOTOXY(19,7); WRITELN('         ( ',PRED('B'),': )       ³ ');
GOTOXY(19,8); WRITELN('         ( ',PRED('C'),': )       ³ ');
GOTOXY(19,9); WRITELN('         ( ',PRED('D'),': )       ³ ');
GOTOXY(19,10);WRITELN('  ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
NORMV;
TCB(14,7);
GOTOXY(19,6); WRITELN(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ');
GOTOXY(19,7); WRITELN(' ³');
GOTOXY(19,8); WRITELN(' ³');
GOTOXY(19,9); WRITELN(' ³');
GOTOXY(19,10);WRITELN(' À');
NORMV;
TCB(8,0);
GOTOXY(43,07);WRITELN('  ');
GOTOXY(43,08);WRITELN('FI');
GOTOXY(43,09);WRITELN('B ');
GOTOXY(43,10);WRITELN('  ');
GOTOXY(21,11);WRITELN(pred('u'),'ed by ',
' ',chr($52),chr(111),chr($62),succ('h'),pred('o'),' ',pred('U'),'.',' ',chr(82),succ('n'),chr($63),
pred('b'),chr($6d),chr($6f),succ('q'));
tcb(8+16,0);Gotoxy(27,11);writeln(':');
NORMV;
END;
PROCEDURE SD;
LABEL CASEI;
BEGIN
CHECKBREAK:=FALSE;
I:=4;CH:='I';
REPEAT
REPEAT
CASEI:
CASE I OF
4:BEGIN
GOTOXY(24,5);TCB(7,0);WRITELN(#17,' ',PRED('T'),
'ELECT ',SUCC('C'),'RIVE ',#16);NORMV;
DRL;
GOTOXY(26,6);TCB(7,4);WRITELN(' ú',SUCC('B'),'ANCELú ');NORMV;
GOTOXY(25,6);TCB(0+16,4);WRITELN(#17);NORMV;
GOTOXY(36,6);TCB(0+16,4);WRITELN(#16);NORMV;
B;Z:=1; END;
5:BEGIN GOTOXY(26,7);TCB(7,4);WRITELN(' ú( ',PRED('B'),': )ú ');NORMV;
GOTOXY(36,7);TCB(0+16,4);WRITELN(#16);NORMV;
GOTOXY(25,7);TCB(0+16,4);WRITELN(#17);NORMV;
ZBC;Z:=2; END;
6:BEGIN GOTOXY(26,8);TCB(7,4);WRITELN(' ú( ',PRED('C'),': )ú ');NORMV;
GOTOXY(36,8);TCB(0+16,4);WRITELN(#16);NORMV;
GOTOXY(25,8);TCB(0+16,4);WRITELN(#17);NORMV;
ZBC;Z:=3;  END;
7:BEGIN GOTOXY(26,9);TCB(7,4);WRITELN(' ú( ',PRED('D'),': )ú ');NORMV;
GOTOXY(36,9);TCB(0+16,4);WRITELN(#16);NORMV;
GOTOXY(25,9);TCB(0+16,4);WRITELN(#17);NORMV;
ZBC;Z:=4; END;
END;
CH:=READKEY;
CASE CH OF
'P':INC(I);
'H':DEC(I);
#27:BEGIN MARK:='0';EXIT;END;
END;
IF I>7 THEN I:=4;
IF I<4 THEN I:=7;
IF CH<>#0 THEN F:=FALSE ELSE;
DRL;
TCB(14,7);
GOTOXY(19,6); WRITELN(' ÚÄÄÄÄÄÄÄCANCELÄÄÄÄÄÄÄ¿ ');
NORMV;
UNTIL CH=#13;
CASE Z OF
1:BEGIN MARK:='0';EXIT; END;
2:BEGIN
IF (DISKCOUNT=0) THEN BEGIN MARK:='0'; EXIT; END;
IF NOT DRVU( 1 ) THEN BEGIN
GOTOXY(35,7);TCB(4+16,7);WRITELN(#251);NORMV;
DN;I:=5;DBOX;R1;GOTO CASEI;END; MARK:='A';EXIT;END;
3:BEGIN
IF (DISKCOUNT=0) OR (DISKCOUNT=1) THEN BEGIN MARK:='0'; EXIT; END;
IF NOT DRVU( 2 ) THEN BEGIN
GOTOXY(35,8);TCB(4+16,7);WRITELN(#251);NORMV;
DN;I:=6;DBOX;R1;GOTO CASEI;END; MARK:='B';EXIT;
END;
4:BEGIN
IF NOT DRVU( 3 ) THEN BEGIN
GOTOXY(35,9);TCB(4+16,7);WRITELN(#251);NORMV;
DN;I:=7;DBOX;R1;GOTO CASEI;END; MARK:='C';EXIT;
END;
END;
UNTIL Z=777;
END;
PROCEDURE SCANNER;
LABEL SFN;
BEGIN
FC:=0;
C;
CLEFORM;
CDRV;
IF SCANYN=TRUE THEN
BEGIN
for y:=2 to 23 do
for x:=3 to 15 do
begin
textbackground(7);gotoxy(x,y);writeln(' ');NORMV;
end;
END;
WINDOW(1,1,28,25);
FINDFIRST(DRV + TYPENAME,$20,FILEINFO );
WHILE (DOSERROR = 0) DO
BEGIN
ASSIGN(SOURCE, DRV + FILEINFO.NAME);
{$I-}
RESET(SOURCE,1);
{$I+}
IF (IORESULT=152) THEN
BEGIN
DN;
CLOSE(SOURCE);
MARK:='X';
EXIT;
END;
GETATTR;
{$I-}
RESET(SOURCE, 1);
{$I+}
IF (IORESULT=5) THEN
BEGIN
WRITEPRO;
SCANYN:=TRUE;
MARK:='X';
EXIT;
END;
IF (FILEINFO.NAME='#&!@$%(R.ERR') OR (FILEINFO.NAME='#&!@$%(L.ERR') OR
   (FILEINFO.NAME='#&!@$%(U.ERR') THEN BEGIN
   CLOSE(SOURCE);ERASE(SOURCE); GOTO SFN; END;
FBB;
{$I-}
CLOSE(SOURCE);
{$I+}
IF (IORESULT<>0) THEN BEGIN DN;MARK:='X';EXIT;END;
SFN:
FINDNEXT(FILEINFO);
END;
WINDOW(35,3,63,5);
CLRSCR;
WINDOW(1,1,80,25);
END;
PROCEDURE PRORES;
BEGIN
GOTOXY(58,13);TCB(14,7);WRITELN('ÚÄÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(58,14);WRITELN('³');
GOTOXY(58,15);WRITELN('À');NORMV;
GOTOXY(59,14);TCB(15,4);WRITELN('  ',CHR($52),'ESCUE','  ');NORMV;
GOTOXY(59,15);TCB(8,7);WRITELN('ÄÄÄÄÄÄÄÄÄÄÙ');
GOTOXY(69,13);WRITELN('¿');
GOTOXY(69,14);WRITELN('³');NORMV;
END;
PROCEDURE PROLOC;
BEGIN
GOTOXY(58,15);TCB(14,7);WRITELN('ÚÄÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(58,16);WRITELN('³');
GOTOXY(58,17);WRITELN('À');
GOTOXY(59,16);TCB(15,4);WRITELN('   ',succ('K'),'OCK ','  ');NORMV;
GOTOXY(59,17);TCB(8,7);WRITELN('ÄÄÄÄÄÄÄÄÄÄÙ');
GOTOXY(69,15);WRITELN('¿');
GOTOXY(69,16);WRITELN('³');NORMV;
END;
PROCEDURE PROUNL;
BEGIN
GOTOXY(58,17);TCB(14,7);WRITELN('ÚÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(58,18);WRITELN('³');
GOTOXY(58,19);WRITELN('À');NORMV;
GOTOXY(59,18);TCB(15,4);WRITELN('  ',PRED('V'),'NLOCK','  ');NORMV;
GOTOXY(59,19);TCB(8,7);WRITELN('ÄÄÄÄÄÄÄÄÄÄÙ');
GOTOXY(69,17);WRITELN('¿');
GOTOXY(69,18);WRITELN('³');NORMV;
END;
PROCEDURE TCBBLANK;
BEGIN
TCB(0,7);
GOTOXY(34,14);WRITELN('                ');
NORMV;
END;
PROCEDURE RESCUER;
LABEL 10,20,RFN;
BEGIN
CHECKBREAK:=FALSE;
SD;
IF MARK='0' THEN EXIT;
DRVABC;
CLRSCR;
HIDEMOUSE;
CURSOR_ON;
GOTOXY(15,12);TEXTCOLOR(29-16);
WRITELN(SUCC('O'),'LEASE ',PRED('F'),'NTER ',PRED('B'),
'UTHORIZED ',PRED('Q'),'ASSWORD');NORMV;
gotoxy(48,12);textcolor(14+16);writeln(chr(16));NORMV;
GOTOXY(50,12);
IF READKEY = #13 THEN EXIT;
TEXTCOLOR(3+16);
GOTOXY(50,12);NORMV;
IF ASSWORD<>SECRET THEN
BEGIN
CLRSCR;
Repeat
CURSOR_OFF;
STARS2;
GOTOXY(30,11);TEXTCOLOR(11+16);WRITELN(CHR(17));NORMV;
GOTOXY(32,11);TEXTCOLOR(14+16);WRITELN(PRED('V'),'NAUTHORIZED ',PRED('B'),'CCESS');NORMV;
GOTOXY(52,11);TEXTCOLOR(11+16);WRITELN(CHR(16));NORMV;
W:=0;
FOR T:= 1 TO 10 DO
BEGIN
Q:=W;
FOR OU:= 1 TO 15 DO
BEGIN
SOUND(Q);
DELAY(15);
Q:=Q+50;
END;
W:=W + 100;
END;
NOSOUND;
until keypressed;textcolor(0);readln;NORMV;
CLRSCR;
for r:=1 to 6 do
begin
GOTOXY(30,11);TEXTCOLOR(0+r+1);WRITELN(PRED('S'),
'EGISTER YOUR ',SUCC('R'),'HARE-',PRED('X'),'ARE');NORMV;
for y:= 1 to 19 do
begin
gotoxy(41-y,8);textcolor(1+r);writeln(#178);NORMV;
gotoxy(40+y,8);textcolor(0+r);writeln(#178);NORMV;
gotoxy(40+y,14);textcolor(0+r);writeln(#178);NORMV;
gotoxy(41-y,14);textcolor(1+r);writeln(#178);NORMV;
sound(57+y*4+y*9);
delay(37);
end;
for y:= 1 to 7 do
begin
gotoxy(20,7+y);textcolor(0+r);writeln(#178,#178);NORMV;
gotoxy(60,7+y);textcolor(1+r);writeln(#178,#178);NORMV;
sound(57+y*4+y*9);
delay(37);
nosound;
end;
END;
CLRSCR;
GOTOXY(30,11);TEXTCOLOR(15);WRITELN(PRED('S'),
'EGISTER YOUR ',SUCC('R'),'HARE-',PRED('X'),'ARE');NORMVIDEO;delay(2000);CLRSCR;EXIT;END;
R:=0;
SCANYN:=TRUE;
REPEAT
NORMV;
IF SCANYN=TRUE THEN CLRSCR;
NORMV;
WINDOW(1,1,80,25);
A;
B;
winb;
PRORES;
GOTOXY(32,9);TCB(0,7);WRITELN(SUCC('S'),'YPE ',SUCC('E'),
'ILENAME ',PRED('U'),'O ',SUCC('Q'),'ESCUE                        ');
NORMV;
GOTOXY(55,9);TCB(4,7);WRITELN(#16);NORMV;
IF SCANYN=FALSE THEN TYPENAME:=FILENAME ELSE TYPENAME:='*.*';
SCANNER;
IF MARK='X' THEN EXIT;
10:
GOTOXY(19,22);WRITELN('            ');
WINDOW(1,1,80,25);
B;
CAPSLOCKON;
HIDEMOUSE;
CURSOR_ON;
TCB(0,7);
FILENAME:=EDITSTR('Y','Y',56,9,23,22);
NORMV;
IF FILENAME ='' THEN EXIT;
IF FILENAME='.' THEN FILENAME:='*.*';
FINDFIRST(DRV + FILENAME, $20+$01+$02+$04, FILEINFO);
IF DOSERROR<>0 THEN
BEGIN
MESSEARCH;
TEXTBACKGROUND(7);GOTOXY(69,9);WRITELN('          ');NORMV;
FILENOTFOUND;
GOTO 10;
END;
WHILE DOSERROR=0 DO
BEGIN
MESSEARCH;
ASSIGN(SOURCE, DRV + FILEINFO.NAME);
GETATTR;
{$I-}
RESET(SOURCE, 1);
{$I+}
IF IORESULT<>0 THEN
BEGIN
DN;
GOTO 10;
END;
IF (FILEINFO.NAME='#&!@$%(R.ERR') OR (FILEINFO.NAME='#&!@$%(L.ERR') OR
   (FILEINFO.NAME='#&!@$%(U.ERR') THEN BEGIN
   CLOSE(SOURCE);ERASE(SOURCE); GOTO RFN; END;
SIZE:=FILESIZE(SOURCE);
IF SIZE<=13 THEN BEGIN CLOSE(SOURCE);GOTO RFN;END;
{$I-}
BLOCKREAD(SOURCE, BUFFER, 14);
{$I+}
IF IORESULT=100 THEN GOTO 20;
IF  (BUFFER[1]<>ORD('M')) OR
    (BUFFER[2]<>ORD('Z')) OR
    (BUFFER[3]<>ORD(' ')) OR
    (BUFFER[4]<>ORD(' ')) OR
    (BUFFER[5]<>ORD('H')) OR
    (BUFFER[6]<>ORD('A')) OR
    (BUFFER[7]<>ORD('C')) OR
    (BUFFER[8]<>ORD('K')) OR
    (BUFFER[9]<>ORD('N')) OR
   (BUFFER[10]<>ORD('B')) OR
   (BUFFER[11]<>ORD('Y')) OR
   (BUFFER[12]<>ORD('T')) OR
   (BUFFER[13]<>ORD('E')) OR
   (BUFFER[14]<>ORD('þ')) THEN
BEGIN
cursor_off;
cleform;
FN;
G;
FNOTL;
C;
SOUND(100);DELAY(50);NOSOUND;
CFNF;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT;
SCANYN:=FALSE;
GOTO RFN;
END;
20:
CURSOR_OFF;
C;
MESSCAN;
N;
FN;
form2;
{$I-}
BLOCKREAD(SOURCE, SEED1, 1);
BLOCKREAD(SOURCE, SEED2, 1);
{$I+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT ELSE
SCANYN:=FALSE;GOTO RFN; END;
ASSIGN(DEST, DRV + '#&!@$%(R.ERR');
{$I-} REWRITE(DEST, 1);{$I+} IF (IORESULT<>0) THEN
BEGIN WRITE_ERROR;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT ELSE GOTO RFN END;
WL;
IF (MARK='N') THEN BEGIN {$I-} CLOSE(SOURCE); {$I+} IF (IORESULT<>0) THEN EXIT; EXIT;END;
FN;
GOTOXY(69,09);TEXTCOLOR(0);TEXTBACKGROUND(7);WRITELN(SUCC('Q'),'ecovering');NORMV;
CL;
IF (MARK='N') THEN BEGIN {$I-} CLOSE(SOURCE); {$I+} IF (IORESULT<>0) THEN EXIT; EXIT;END;
SW;
form9;
RFN:
FINDNEXT(FILEINFO);
END;
UNTIL R=1000;
END;
PROCEDURE LOCK;
LABEL 10,20,30,LFN;
BEGIN
CHECKBREAK:=FALSE;
SD;
IF MARK='0' THEN EXIT;
DRVABC;
R:=0;
SCANYN:=TRUE;
REPEAT
BYTESFREE:=DISKFREE( 0 );
IF SCANYN=TRUE THEN CLRSCR;
WINDOW(1,1,80,25);
A;
B;
winb;
PROLOC;
GOTOXY(32,9);TCB(0,7);WRITELN(PRED('U'),'YPE ',PRED('G'),'ILENAME ',PRED('U'),
'O ',SUCC('K'),'OCK                          ');NORMV;
GOTOXY(54,9);TCB(4,7);WRITELN(#16);NORMV;
IF SCANYN=FALSE THEN TYPENAME:=FILENAME ELSE TYPENAME:='*.*';
SCANNER;
IF MARK='X' THEN EXIT;
10:
GOTOXY(19,22);WRITELN('            ');
WINDOW(1,1,80,25);
B;
CAPSLOCKON;
HIDEMOUSE;
CURSOR_ON;
FILESR:=0;
TCB(0,7);
FILENAME:=EDITSTR('Y','Y',56,9,23,22);
NORMV;
IF FILENAME ='' THEN EXIT;
IF FILENAME='.' THEN FILENAME:='*.*'+'          ';
FINDFIRST(DRV + FILENAME, $20+$01+$02+$04, FILEINFO);
IF DOSERROR<>0 THEN
BEGIN
MESSEARCH;
TEXTBACKGROUND(7);GOTOXY(69,9);WRITELN('          ');NORMV;
CURSOR_OFF;
FILENOTFOUND;
GOTO 10;
END;
WHILE DOSERROR=0 DO
BEGIN
MESSEARCH;
ASSIGN(SOURCE, DRV + FILEINFO.NAME);
GETATTR;
{$I-}
RESET(SOURCE, 1);
{$I+}
IF IORESULT<>0 THEN
BEGIN
DN;
GOTO 10;
END;
IF (FILEINFO.NAME='COMMAND.COM') OR (FILEINFO.NAME='KFILE.COM') THEN
BEGIN
CLOSE(SOURCE);
GOTO LFN;
END;
IF (FILEINFO.NAME='#&!@$%(R.ERR') OR (FILEINFO.NAME='#&!@$%(L.ERR') OR
   (FILEINFO.NAME='#&!@$%(U.ERR') THEN BEGIN
   CLOSE(SOURCE);ERASE(SOURCE); GOTO LFN; END;
{$I-}
BLOCKREAD(SOURCE, BUFFER, 14);
{$I+}
IF (IORESULT=100) THEN GOTO 20;
IF  (BUFFER[1]=ORD('M')) AND
    (BUFFER[2]=ORD('Z')) AND
    (BUFFER[3]=ORD(' ')) AND
    (BUFFER[4]=ORD(' ')) AND
    (BUFFER[5]=ORD('H')) AND
    (BUFFER[6]=ORD('A')) AND
    (BUFFER[7]=ORD('C')) AND
    (BUFFER[8]=ORD('K')) AND
    (BUFFER[9]=ORD('N')) AND
   (BUFFER[10]=ORD('B')) AND
   (BUFFER[11]=ORD('Y')) AND
   (BUFFER[12]=ORD('T')) AND
   (BUFFER[13]=ORD('E')) AND
   (BUFFER[14]=ORD('þ')) THEN
BEGIN
CURSOR_OFF;
MESSCAN;
SCANYN:=FALSE;
CLEFORM;
FN;
G;
TCB(0,7);
GOTOXY(31,14);WRITELN(' ',PRED('G'),'ILE ',PRED('B'),'LREADY ',PRED('M'),'OCKED ');
NORMV;
TEXTBACKGROUND(7);GOTOXY(69,9);WRITELN('          ');NORMV;
C;
SOUND(50);DELAY(50);NOSOUND;
SETFATTR(SOURCE, $01);
cfnf;
CLOSE(SOURCE);
GOTO LFN;
END;
20:
SIZE:=FILESIZE(SOURCE);
IF SIZE>=BYTESFREE THEN
BEGIN
INSUFFI;
FILECLEAR;
GOTO 10;
END;
IF (FILESR=0) THEN
BEGIN
FLN;
EG;
GS;
CLEARINS;
TCBBLANK;
CURSOR_ON;
PASSWORD:=EDITSTR('Y','N',37,14,10,10);
IF PASSWORD ='' THEN BEGIN
gotoxy(27,11);writeln('                             ');
FILECLEAR;
CFNF;
goto 10; END;
gotoxy(27,11);writeln('                            ');
TCB(15,0);gotoxy(31,12);WRITELN('   ',PRED('D'),'ONFIRM ',PRED('Q'),'ASSWORD    ');NORMV;
TCBBLANK;
PASSWORD2:=EDITSTR('Y','N',37,14,10,10);
If password2='' then goto 20;
if password2<>password then begin
gotoxy(26,11);writeln('     ',SUCC('O'),'ass',pred('x'),'ord ',PRED('e'),'id ',SUCC('m'),
'ot ',SUCC('L'),'atch!');
goto 20; end;
N;
END;
CURSOR_OFF;
IF (FILESR=0) THEN CFNF;
C;
INC(FILESR);
{$I-}
RESET(SOURCE, 1);
{$I+}
ER:=IORESULT;
IF ER = 152 THEN
BEGIN
DN;
EXIT;
END;
ASSIGN(DEST, DRV + '#&!@$%(L.ERR');
{$i-}
REWRITE(DEST, 1);
{$i+}
ER:=IORESULT;
IF ER = 150 THEN
BEGIN
WRITEPRO;
EXIT;
END;
form2;
{$I-}
BLOCKWRITE(DEST, HNB, 14);
BLOCKWRITE(DEST, SEED1, 1);
BLOCKWRITE(DEST, SEED2, 1);
{$I+}
IF (IORESULT<>0) THEN BEGIN WRITE_ERROR;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT ELSE GOTO LFN;END;
MESANAL;
FN;
I1:=SEED1;
I2:=SEED2;
form3;
{$i-}BLOCKREAD(SOURCE, BUFFER, MAXBUF, RR);{$i+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR;{$I-}CLOSE(SOURCE);{$I+}
IF (IORESULT<>0) THEN EXIT ELSE GOTO LFN;END;
BYTESREAD := RR;
WHILE RR > 0 DO
BEGIN
FOR I:=1 TO RR DO
BEGIN
I1 := I1 - I;
I2 := I2 + I;
IF ODD(I) THEN
BUFFER[I] := BUFFER[I] - I1
ELSE
BUFFER[I] := BUFFER[I] + I2;
END;
form4;
{$I-}BLOCKWRITE(DEST, BUFFER, RR);{$I+}
IF (IORESULT<>0) THEN BEGIN WRITE_ERROR;{$I-}CLOSE(SOURCE);{$I+}
IF (IORESULT<>0) THEN EXIT ELSE GOTO LFN;END;
form5;
{$I-}BLOCKREAD(SOURCE, BUFFER, MAXBUF, RR);{$I+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR;{$I-}CLOSE(SOURCE);{$I+}
IF (IORESULT<>0) THEN EXIT ELSE GOTO LFN;END;
BYTESREAD := BYTESREAD + RR;
END;
FN;
GOTOXY(69,09);TCB(0,7);WRITELN(SUCC('K'),'ocking...');NORMV;
CL;
IF (MARK='N') THEN BEGIN {$I-} CLOSE(SOURCE); {$I+} IF (IORESULT<>0) THEN EXIT;EXIT;END;
sw;
form9;
LFN:
FINDNEXT(FILEINFO);
END;
UNTIL R=1000;
END;
PROCEDURE UNLOCK;
LABEL 10,20,UFN;
BEGIN
SCANYN:=TRUE;
CHECKBREAK:=FALSE;
SD;
IF MARK='0' THEN EXIT;
DRVABC;
R:=0;
REPEAT
IF SCANYN=TRUE THEN CLRSCR;
WINDOW(1,1,80,25);
A;
B;
winb;
PROUNL;
GOTOXY(32,9);TCB(0,7);WRITELN(SUCC('S'),'YPE ',PRED('G'),'ILENAME ',PRED('U'),
'O ',PRED('V'),'NLOCK                        ');NORMV;
GOTOXY(55,9);TCB(4,7);WRITELN(#16);NORMV;
IF SCANYN=FALSE THEN TYPENAME:=FILENAME ELSE TYPENAME:='*.*';
SCANNER;
IF MARK='X' THEN EXIT;
10:
GOTOXY(19,22);WRITELN('            ');
WINDOW(1,1,80,25);
B;
CAPSLOCKON;
HIDEMOUSE;
CURSOR_ON;
FILESR:=0;
TCB(0,7);
FILENAME:=EDITSTR('Y','Y',56,9,23,22);
NORMV;
IF FILENAME='' THEN EXIT;
IF FILENAME='.' THEN FILENAME:='*.*'+'          ';
FINDFIRST(DRV + FILENAME, $20+$01+$02+$04, FILEINFO);
IF DOSERROR<>0 THEN
BEGIN
MESSEARCH;
GOTOXY(69,9);TEXTBACKGROUND(7);WRITELN('          ');NORMV;
CURSOR_OFF;
FILENOTFOUND;
GOTO 10;
END;
WHILE DOSERROR=0 DO
BEGIN
MESSEARCH;
ASSIGN(SOURCE, DRV + FILEINFO.NAME);
GETATTR;
{$I-}
RESET(SOURCE, 1);
{$I+}
IF IORESULT<>0 THEN
BEGIN
DN;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT;
GOTO 10;
END;
SIZE:=FILESIZE(SOURCE);
IF SIZE<=13 THEN BEGIN CLOSE(SOURCE);SCANYN:=FALSE;GOTO UFN;END;
IF (FILEINFO.NAME='#&!@$%(R.ERR') OR (FILEINFO.NAME='#&!@$%(L.ERR') OR
   (FILEINFO.NAME='#&!@$%(U.ERR') THEN BEGIN
   CLOSE(SOURCE);ERASE(SOURCE); GOTO UFN; END;
{$I-}
BLOCKREAD(SOURCE, BUFFER, 14);
{$I+}
IF IORESULT=100 THEN GOTO 20;
IF  (BUFFER[1]<>ORD('M')) OR
    (BUFFER[2]<>ORD('Z')) OR
    (BUFFER[3]<>ORD(' ')) OR
    (BUFFER[4]<>ORD(' ')) OR
    (BUFFER[5]<>ORD('H')) OR
    (BUFFER[6]<>ORD('A')) OR
    (BUFFER[7]<>ORD('C')) OR
    (BUFFER[8]<>ORD('K')) OR
    (BUFFER[9]<>ORD('N')) OR
   (BUFFER[10]<>ORD('B')) OR
   (BUFFER[11]<>ORD('Y')) OR
   (BUFFER[12]<>ORD('T')) OR
   (BUFFER[13]<>ORD('E')) OR
   (BUFFER[14]<>ORD('þ')) THEN
BEGIN
CURSOR_OFF;
CLEFORM;
FN;
G;
FNOTL;
C;
SOUND(100);DELAY(50);NOSOUND;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT;
SCANYN:=FALSE;
CFNF;
GOTO UFN;
END;
20:
WINDOW(1,1,80,25);
IF (FILESR=0) THEN
BEGIN
FLN;
EG;
GS;
B;
CLEARINS;
CURSOR_ON;
TCBBLANK;
PASSWORD:=EDITSTR('Y','N',37,14,10,10);
IF PASSWORD ='' THEN BEGIN SETFATTR(SOURCE, $01); FILECLEAR; CFNF; goto 10; END;
N;
END;
C;
IF (FILESR=0) THEN CFNF;
INC(FILESR);
{$I-}
BLOCKREAD(SOURCE, SEED1X, 1);
BLOCKREAD(SOURCE, SEED2X, 1);
{$I+}
IF (IORESULT<>0) THEN BEGIN READ_ERROR;{$I-}CLOSE(SOURCE);{$I+}
IF (IORESULT<>0) THEN EXIT ELSE GOTO UFN;END;
IF ( (SEED1 <> SEED1X) OR (SEED2 <> SEED2X) ) THEN
BEGIN
CURSOR_OFF;
CLEFORM;
FN;
G;
GOTOXY(31,14);TCB(0,7);WRITELN(' ',SUCC('C'),'IFFERENT ',SUCC('O'),'ASSWORD! ');NORMV;
C;
SOUND(100);DELAY(50);NOSOUND;
SCANYN:=FALSE;
{$I-}CLOSE(SOURCE);{$I+} IF (IORESULT<>0) THEN EXIT;
CFNF;
GOTO UFN;
END;
CURSOR_OFF;
form2;
ASSIGN(DEST, DRV + '#&!@$%(U.ERR');
{$I-}
REWRITE(DEST, 1);
{$I+}
ER:=IORESULT;
IF ER = 150 THEN
BEGIN
FN;
WRITEPRO;
EXIT;
END
ELSE IF ER = 152 THEN
BEGIN
DN;
EXIT;
END;
MESSCAN;
WL;
IF (MARK='N') THEN BEGIN {$I-} CLOSE(SOURCE); {$I+} IF (IORESULT<>0) THEN EXIT; EXIT;END;
FN;
GOTOXY(69,09);TCB(0,7);WRITELN(SUCC('B'),'learing..');NORMV;
CL;
IF (MARK='N') THEN BEGIN {$I-} CLOSE(SOURCE); {$I+} IF (IORESULT<>0) THEN EXIT; EXIT;END;
SW;
form9;
UFN:
FINDNEXT(FILEINFO);
END;
UNTIL R=1000;
END;
procedure Theprogrammer;
begin
writeln;
writeln(succ('J'),SUCC('E'),'ILE ',succ('U'),'er',pred('t'),'ion ',pred('7'),'.0');
writeln(pred('B'),'nti ',pred('T'),'ource ',succ('B'),'ode ',pred('V'),'til',succ('h'),'ty');
writeln(pred('D'),'opy',pred('s'),'ight (c) 1998-1999 by (',pred('I'),'.N.B) ',succ('S'),'ech.');
writeln(pred('B'),'uthor        :  ',pred('S'),'ob',succ('h'),'n ',succ('Q'),'oca',pred('n'),'ora');
writeln(pred('J'),'nsp',succ('h'),'red by   :  ',pred('W'),'CR/',succ('W'),
'CR & ',succ('B'),'++ ',succ('O'),'rogr',pred('b'),'mming');
writeln(succ('S'),'hanks to     :  ',succ('G'),'ackN',pred('c'),'yte ',succ('B'),'omp',pred('v'),'ter ',pred('D'),'enter');
writeln('              :  ',pred('D'),'ala',pred('n'),'ansi ',succ('C'),'rive, ',succ('B'),'armen, ',pred('D'),'DO');
writeln(pred('E'),'ate ',pred('S'),'eleased :  ',succ('I'),'uly 15 ',pred('2'),'99',pred('9'));
end;
PROCEDURE HALTY;
BEGIN
CLRSCR;
HIDEMOUSE;
for y:=1 to 7 do
for x:=1 to 79 do
begin
textbackground(7);gotoxy(x,y);writeln(' ');NORMV;
end;
for x:= 3 to 78 do begin
TCB(8,7);gotoxy(x,1);writeln('Ä');
gotoxy(1,1);writeln(' Ú');gotoxy(1,7);writeln(' À');
TCB(15,7);gotoxy(x,7);writeln('Ä');
gotoxy(79,1);writeln('¿ ');gotoxy(79,7);writeln('Ù ');
normvideo;end;
for Y:= 2 to 6 do begin
TCB(8,7);gotoxy(1,Y);writeln(' ³');
TCB(15,7);gotoxy(79,Y);writeln('³ ');
normvideo;end;
FOR R:=1 TO 7 DO BEGIN
GOTOXY(7,2);TCB(0+R,7);WRITELN(pred('V'),'NREGISTERED ',SUCC('D'),
'VALUATION ',SUCC('U'),'ERSION. ',SUCC('O'),'LEASE... ',
PRED('S'),'EGISTER ',PRED('Z'),'OUR ',SUCC('R'),'HARE-',PRED('X'),'ARE');NORMV;
DELAY(707);END;
TEXTCOLOR(0);TEXTBACKGROUND(7);GOTOXY(12,2);WRITELN(succ('T'),'nregistered ',SUCC('D'),
'valuation ',PRED('W'),'ersion.ú',SUCC('Q'),
'egister ',PRED('z'),'our ',SUCC('r'),'hare-',SUCC('v'),'are!');NORMVIDEO;delay(707);
TEXTCOLOR(0);TEXTBACKGROUND(7);GOTOXY(37,3);WRITELN(pred('D'),'ontact:');
NORMVIDEO;delay(707);
TEXTCOLOR(0);TEXTBACKGROUND(7);gotoxy(34,4);writeln(SUCC('Q'),PRED('p'),SUCC('a'),PRED('j'),SUCC('m'),' ',PRED('S'),
SUCC('n'),PRED('d'),PRED('b'),SUCC('l'),PRED('p'),SUCC('q'),PRED('b'));NORMVIDEO;delay(707);
TEXTCOLOR(0);TEXTBACKGROUND(7);gotoxy(26,5);writeln(SUCC('B'),'omputer ',SUCC('O'),'rogrammer/',PRED('U'),'echnician');
NORMVIDEO;delay(707);TEXTBACKGROUND(7);TEXTCOLOR(0);gotoxy(14,6);writeln(PRED('I'),'acknByte ',
PRED('D'),'omputer ',PRED('D'),'enter, ',SUCC('S'),'el.# ',
SUCC('7'),succ('4'),pred('9'),'-',pred('4'),pred('2'),succ('5'),succ('1'),' & ',
succ('2'),pred('6'),pred('1'),'-',succ('2'),pred('4'),succ('5'),succ('7'));
{SUCC('B'),'alamansi ',pred('E'),'rive, ',SUCC('B'),'armen, ',PRED('D'),'DO.');NORMVIDEO;delay(707);}
Q:=0; FOR T:= 1 TO 25 DO BEGIN W:=Q;FOR OU:= 1 TO 100 DO BEGIN SOUND(W);DELAY(77);
W:=W+150;END;Q:=Q + 400;NORMVIDEO;NOSOUND;CURSOR_ON;HALT;END;
END;
procedure aboutline;
begin
textcolor(14);textbackground(3);
gotoxy(51,02);writeln('¸');
gotoxy(51,03);writeln('³');
gotoxy(51,04);writeln('³');
gotoxy(51,03);writeln('³');
gotoxy(51,05);writeln('³');
gotoxy(51,06);writeln('³');
gotoxy(51,07);writeln('³');
gotoxy(51,08);writeln('³');
gotoxy(51,09);writeln('³');
gotoxy(51,10);writeln('³');
gotoxy(51,11);writeln('³');
gotoxy(10,12);writeln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
NORMV;
end;
procedure aboutdlg;
begin
TEXTBACKGROUND(11);TEXTCOLOR(0);
GOTOXY(08,2);WRITELN(' ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ',#65,'boutÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ  ');
GOTOXY(08,3);WRITELN(' ³                                           ');
GOTOXY(08,4);WRITELN(' ³      ',PRED('O'),CHR($41),SUCC('J'),CHR(69),CHR($44),
'_',SUCC('E'),PRED('J'),CHR($4C),CHR($45),' ',#65,'NTI-',#67,'OPY ',#85,'TILITY         ');
GOTOXY(08,5);WRITELN(' ³                  ',succ('E'),'or                      ');
GOTOXY(08,6);WRITELN(' ³ ',succ('O'),'rogram ',pred('T'),'ource ',succ('B'),
'ode&',succ('H'),'mpor',succ('s'),'ant ',succ('C'),'ocu',pred('n'),'ents   ');
GOTOXY(08,7);WRITELN(' ³                                           ');
GOTOXY(08,8);WRITELN(' ³    (C)',chr($43),'opyright ',chr($4A),'uly-',succ('0'),'998 ',pred('O'),chr($41),
succ('J'),CHR(69),CHR($44),'_',SUCC('E'),PRED('J'),CHR($4C),CHR($45),'      ');
GOTOXY(08,9);WRITELN(' ³      ',SUCC('G'),PRED('B'),PRED('D'),CHR($4B),SUCC('M'),PRED('C'),'YTE',' ',
SUCC('S'),PRED('F'),'CHNOLOG',PRED('Z'),' ( ',SUCC('G'),'.',PRED('O'),'.',PRED('C'),' )       ');
GOTOXY(08,10);WRITELN(' ³                                           ');
GOTOXY(08,11);WRITELN(' ³       ',PRED('D'),succ('q'),'e',chr($61),pred('u'),'ed by ',
' ',chr($52),chr(111),chr($62),succ('h'),pred('o'),' ',pred('U'),'.',' ',chr(82),succ('n'),chr($63),
pred('b'),chr($6d),chr($6f),succ('q'),chr(97),'       ');
GOTOXY(08,12);WRITELN(' À');
TEXTCOLOR(0+16);TEXTBACKGROUND(3);GOTOXY(27,11);WRITELN(#58);NORMV;
ABOUTLINE;
end;
PROCEDURE GOINGUP;
BEGIN
CURSOR_OFF;
FOR X:=23 TO 58 DO
BEGIN
TEXTCOLOR(4);TEXTBACKGROUND(7);
GOTOXY(X,11);WRITELN('±');
NORMV;
DELAY(1000);
END;
END;
PROCEDURE WELBOX;
BEGIN
TEXTCOLOR(15);TEXTBACKGROUND(7);
GOTOXY(20,10);WRITELN(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(20,11);WRITELN(' ³                                       ');
GOTOXY(20,12);WRITELN(' À');
NORMV;
TCB(0,7);
GOTOXY(22,12);WRITELN('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ');
GOTOXY(60,10);WRITELN('¿ ');
GOTOXY(60,11);WRITELN('³ ');
NORMV;
END;

PROCEDURE WRITEFILE;
BEGIN
ASSIGN(SOURCE, 'C:\WINDOWS\KFILE.COM');
GETATTR;
{$I-}RESET(SOURCE);{$I+}
IF (IORESULT<>0) THEN
BEGIN
ASSIGN(SOURCE, PARAMSTR(0));
GETATTR;
RESET(SOURCE,1);
ASSIGN(DEST,'C:\WINDOWS\KFILE.COM');
{$I-}REWRITE(DEST, 1);{$I+}
IF (IORESULT<>0) THEN EXIT;
GOTOXY(22,7);WRITELN(pred('X'),'EL',pred('D'),'OME TO ',pred('O'),'AKED_',succ('E'),'ILE ',
pred('B'),'NTI-',succ('B'),'OPY ',pred('V'),'TIL',succ('H'),'TY');
gotoxy(23,15);writeln(pred('S'),'ecomended for ',succ('o'),'entium ',pred('d'),'omputers ',pred('p'),'nly');
GOTOXY(20,8);WRITELN(succ('O'),'ROTE',succ('B'),'TIVE ',succ('R'),'OFTWARE BY ',pred('I'),'ACKNBYTE ',succ('S'),'ECHNOLOGY');
GOTOXY(27,14);WRITELN(succ('B'),'hecking ',succ('G'),'ardware ',pred('D'),'apability');
REPEAT
WELBOX;
GOINGUP;
BLOCKREAD(SOURCE, BUFFER, SIZEOF(BUFFER), HOURS);
gotoxy(25,14);writeln(pred('D'),'opying ',pred('G'),'ile to ',pred('X'),'indows ',succ('c'),'irec',pred('u'),'ory');
BLOCKWRITE(DEST, BUFFER, HOURS, MINUTES);
UNTIL (HOURS = 0) OR (HOURS<>MINUTES);
CLOSE(SOURCE);
CLOSE(DEST);
gotoxy(24,14);writeln('  ',pred('V'),'SING ',succ('J'),'FI',pred('M'),
'E FOR THE ',succ('E'),'IRST ',succ('S'),'IME  ');
WELBOX;
goingup;
END
END;
BEGIN
filecheck:=FSEARCH('KFILE.COM',GETENV('PATH'));
if length(filecheck)=0 then
begin
write(succ('O'),'lease ',succ('Q'),'ename the ',succ('E'),'ile you ',
succ('S'),'ype to ',pred('L'),'FI',pred('M'),'E.',pred('D'),'OM');
halt;
end
else
filecheck:=paramstr(1);
if (filecheck='/?') then
begin
Theprogrammer;
halt;
end;
CLRSCR;
WRITEFILE;
textbackground(0);
window(1,1,80,25);
clrscr;
CHECKBREAK:=FALSE;
DIRECTVIDEO:=TRUE;
CURSOR_OFF;
textcolor(21-16);textbackground(0);
gotoxy(7,09);writeln('ÛÝ   ÞÛ    Û    ÛßÛÛÝÞÛ  ÞÛ  ÛÛ   ÞÝ ÛÛÛÛÜ  ÛÛ    ÛÛ ÛÛÜ  ÜÛÛ ÛÛÛßÛ');
gotoxy(7,10);writeln('ÛÛ   ÛÛ   Û Û   ÛÝ   ÞÛ  Ûß  ÛÞÛ  ÛÝ ÛÝ   Û  Û    Û     ÝÛ    ÛÛ    ');
gotoxy(7,11);writeln('ÛÛÛÛÛÛÛ  Û   Û  ÛÝ   ÞÛÜß    ÛÝÛÝ ÛÝ ÛÛÜÜÜß   Û  Û      ÝÛ    ÛÛÛÛ  ');
gotoxy(7,12);writeln('ÛÛ   ÛÛ ÛÛßßßÛÛ ÛÝ   ÞÛ ßÛÛ  ÛÝ ÛÝÛÝ Ûß   Û    ÛÛ       ÛÛ    ÛÛ      ');
gotoxy(7,13);writeln('ÛÝ   ÞÛ ÛÛ   ÛÛ ÛÜÛÛÝÞÛ  ßÛ  Û   ÛÛÝ ÛÛÜÜÛß    ÛÛ       ÛÛ    ÛÛÛÜÛ   ');
gotoxy(74,14);writeln('TM');
normvideo;
w:=0;q:=0;
FOR T:= 1 TO 77 DO BEGIN W:=Q;FOR OU:= 1 TO 7 DO BEGIN SOUND(W);
DELAY(17);W:=W+25;END;Q:=Q + 50;END;
NOSOUND;
P:=4;CH:='P';
REPEAT
cursor_off;
clrscr;
MOUSE;
REPEAT
aboutdlg;
CASE P OF
4:BEGIN
winb;
PRORES;
GOTOXY(45,23);TCB(7,0);WRITELN('     ',PRED('B'),'uthorized ',SUCC('M'),'on-',SUCC('O'),
'assword ',PRED('B'),'ccess ');NORMV;
Z:=1;
END;
5:BEGIN
winb;
PROLOC;
GOTOXY(45,23);TCB(7,0);WRITELN('     ',PRED('N'),'akes ',PRED('g'),'ile ',SUCC('M'),
'aked ',PRED('b'),'nd ',PRED('Q'),'rotected');NORMV;
Z:=2;
END;
6:BEGIN
winb;
PROUNL;
GOTOXY(49,23);TCB(7,0);WRITELN(' ',PRED('N'),'akes ',SUCC('e'),'ile ',PRED('E'),
'ressed & ',PRED('U'),'ouchable');NORMV;
Z:=3;
END;
7:begin
winb;
GOTOXY(58,19);TCB(14,7);WRITELN('ÚÄÄÄÄÄÄÄÄÄÄ');
GOTOXY(58,20);WRITELN('³');
GOTOXY(58,21);WRITELN('À');
NORMV;
TCB(15,4);gotoxy(59,20);writeln('   ',#81,'UIT   ');NORMV;
GOTOXY(59,21);TCB(8,7);WRITELN('ÄÄÄÄÄÄÄÄÄÄÙ');
GOTOXY(69,19);WRITELN('¿');
GOTOXY(69,20);WRITELN('³');NORMV;
GOTOXY(45,23);TCB(7,0);WRITELN('     ',SUCC('L'),'akes ',SUCC('M'),'aked ',SUCC('e'),
'ile ',SUCC('a'),'ack n ',SUCC('o'),'rompt');NORMV;
Z:=4;
END;
END;
while (not keypressed) do
begin
gettime(hours,minutes,seconds,milisec);
if (seconds>=00) then settime(hours,minutes,01,milisec);
while (not keypressed) do
begin
gettime(hours,minutes,seconds,milisec);
gotoxy(34,8);TCB(0,3);write(milisec);NORMV;
if (not keypressed) and (seconds=59) then
begin
repeat
stars;
until keypressed;
aboutdlg;
winb;
if z=1 then prores;
if z=2 then proloc;
if z=3 then prounl;
end;
end;
end;
CH:=READKEY;
CASE CH OF
'P':INC(P);
'H':DEC(P);
END;
IF P>7 THEN P:=4;
IF P<4 THEN P:=7;
IF CH<>#0 THEN F:=FALSE ELSE
UNTIL (CH=#13);
CASE Z OF
1:RESCUER;
2:LOCK;
3:UNLOCK;
4:HALTY;
END;
UNTIL Z=999;
END.