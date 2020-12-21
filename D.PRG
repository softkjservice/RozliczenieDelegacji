*******************************************************************************
* Program do rozliczania delegacji w firmie transportowej                     *
*******************************************************************************
local lpoz:=1,ek
set date to german
set delete on
set century on
private k_w:=0,k_k:=0
public zpolska:=.f.
public znumer_druk:=.f.
d_public()
druk_public()
zleg_sh_public()
d_tlo()
kj_okno(0,0,10, "  KJ - SYSTEM ZARZ§DZANIA FIRM§                                                 ",2)
kj_okno(18,0,5, "         A K T U A L N E      P A R A M E T R Y      P R O G R A M U            ",2)
lcolor=setcolor()
save screen to ek
if zhaslo_l
  do skom with "Wpisz haslo i zatwierdz klawiszem [Enter]"
  set color to
  *set default to shset
  set default to &set_serwer
  if.not.kj_haslo(0,46,0)
    clear
    return
  endif
endif

setcolor(lcolor)
**
set default to leg01
if kj_use("leg01",.f.,3)
  if empty(ldat)
				if reclock(5)      
	              replace ldat with date()
                  unlock
	            endif			      
  endif
  zleg_lad()
  use
else
  set color to
  clear
  return    
endif	  

close
demo_legalizuj("SH")
restore screen from ek

if demo_end("SH")
  kj_tkom(3," Uwaga!  Korzystaliscie Panstwo z wersji   D E M O "," Dalsza praca z programem bedzie mozliwa po wykupieniu LICENCJI","Producent: Soft_KJ_Service  Tel: 0 604 219 784 ","Nacisnij dowolny klawisz.",5)
  clear
  return
endif

set default to leg01
if file("drukarki.dbf")
  if kj_use("drukarki",.f.,3)
    locate for dr="*"
	if.not.found()
	  go top
	endif
    druk_lad()	
    use
  endif
else
  clear
  @ 10,10 say "Brak pliku DRUKARKI.DBF"
  INKEY(0)
endif

**
set color to "n/w,w/n"
set default to bazy	
if param_use()
  param_lad()
endif
d_paramsay()

lpoz=dg_menu(lpoz)
*indeksacja()
RETURN

*******************************************************************************
* Menu glowne programu DELEGAT                                                *
*******************************************************************************
FUNCTION DG_MENU() 
local ek,ek1,ek2,ek3,ltnaz,ltkod,ltil,lfound:=.f.,lcolor,lzak_menu:=0
*local lbelka:="∞ Sprzedaæ ∞    Zakup    ∞  Magazyn   ∞ Kontrahent ∞  Inne  ∞  Koniec ∞"
**local lbelka:= "∞ Delegacja ∞ Pracownik ∞ Kraje ∞ przeJòcia ∞ kUrsy ∞ Inne ∞ kOniec ∞"
local lbelka:= "∞ Delegacja ∞ Pracownik ∞ Kraje ∞ przeJòcia ∞ Waluty ∞ Inne ∞ kOniec ∞"
local lliter:= "  D           P           K           J       W        I       O      "
*local lliter:="  S             Z           M           K             I                "
**local lliter:= "  D           P           K           J        U      I       O    "
*LOCAL LLITER:=""
local lpoz:=1,ltopis[20], i:=0,select,ldeleg:=1
local linne:=1,l_inne2:=1,lzak:=1,lsprzed:=1,l_inne1:=1,lsprzed1:=1,lsprzed2:=1
local lzak1:=1, lzak2:=1,luse:=.t.,ldsiec:=.f.,t[1],l_inne3:=1
local lw_grup:=2,lk_grup:=2,ld_sciezka:=""
local lile:=7,ilanal:=0,lw:=0,l_inne4:=1,l_inne41:=1,l_kas1:=1
local lwal:=1
*for i=1 to 20
*  ltopis[i]:="Ok!"
*next
ltopis[1]:="Rozliczanie delegacji"
ltopis[2]:="Lista pracownik¢w"
ltopis[3]:="Lista obsàugiwanych pa‰stw z uwzgl©dnieniem parametr¢w rozliczeniowych"
ltopis[4]:="Lista przejòÜ granicznych"
ltopis[5]:="Kursy walut oraz numer tabeli NBP"
ltopis[6]:="Indeksacja, archiwizacja"
ltopis[7]:="Zako‰czenie pracy programu"
t[1]:="naz_dok"
do while .t.    
  lpoz=menu_poziom(0,0,lile,lbelka,lliter,ltopis,lpoz,.f.,.f.)   &&Menu glowne
  
  save screen to ek
  if lastkey()=27.or.lpoz=7
    if kj_gkom(12,"","Zako‰czyÜ prac© ?","",.t.,5).or.lastkey()=27
	  exit
	endif  
  endif
*  w_tlo(.f.,4)
  if kolor=0
    set color to n/w,w/n
  endif
  do case
    case lpoz=1
*******
	  do while .t.
	    save screen to ek1
		set default to &dokdef_serwer
        if.not.file("dok_def.dbf")
		  ld_sciezka:=zd_serwer+"set"
		  set default to &ld_sciezka
		endif
	    select &dokdef_sel
	    if kj_use("dok_def",.f.,3)
		  set filter to .not.ukryj
		  go top
		  ildok=ilosc_dok()
		  @ 1,1 to 1+ildok+1,14 
		  keyboard chr(205)
          set color to n/w, w/n
		  go top
		  dbedit(2,2,2+ildok-1,13,t,"FU_D","","","",,"")
	      close
		  if lastkey()=27
			exit
		  endif
          delegac()
		  restore screen from ek1
          close all
		  buf_use()
		else
	      if.not.kj_gkom(12," Uwaga!","Brak dost©pu do pliku DOK_DEF.DBF","PonowiÜ pr¢b© ?",5)
		    exit
		  endif
	    endif
		set color to n/w,w/n
	  enddo	

******
    case lpoz=2
      pracow()
    case lpoz=3
	  kraj()
	case lpoz=4
      granic()
    case lpoz=5
*      save screen to ek1
	  do while.t.
*	    restore screen from ek1
	    restore screen from ek
	    lwal=walut_menu(lwal)
		if lastkey()=27
		  keyboard chr(205)
		  exit
		endif
		do case
		  case lwal=1
            tabela()		  
		  case lwal=2
		    kursy()

		endcase
	  enddo
	  
	case lpoz=6
      linne=inne_menu(linne)
	    do case
          case linne=1
		  	set default to &set_serwer
			has_new(6,20,12)
		  case linne=2
		    indeksacja()
          case linne=3
		    druk_wybor(9,43)
          case linne=4
		    o_programie()
		endcase
	  
  endcase

  restore screen from ek
*  sh_paramsay()
  d_paramsay() 
enddo
RETURN nil

FUNCTION FU_D()
local last:=lastkey(),lcolor:=setcolor()

do case
  case last=27
    return 0
  case last=13
    zdok_def_lad()
	return 0	
endcase
do skom with alltrim(opis_dok)
RETURN 1

FUNCTION ILOSC_DOK()
local liledok:=0
go top
do while.not.eof()
  liledok=liledok+1
  skip
enddo
go top
RETURN liledok


FUNCTION D_PUBLIC()
public zdruk_2:=.t.,zpracdruk:=.f.,zprac_druk:=1
public zkrocz_popraw:=.f.,zkoszt_co:=space(40),vrow:=0,zk_5:=2,zk_24:=16
public edit:="",zmargines:=0,zdznak:="F",lpt2_gr:="",lpt3_gr:="",lpt4_gr:="",lpt5_gr:=""
public znocleg_byl:=.f.,zmin_il:=0,znocmin_il:=0,znoc_il:=0
public aktual_kraj:=" POLSKA",zkrajowa:=.f.
public ztabela:=space(40),ztabel_dat:=date()
public astart_dat:=date(),astart_godz:=0,astart_min:=0
public aend_dat:=date(),aend_godz:=0,aend_min:=0
public zsiec:=.t.,kolor:=1,zhaslo_l:=.t.,set_serwer:="set",baz_serwer:="bazy"
public dokdef_serwer:="set",zd_serwer:=""
public zkey10:=.f.
public prac_war:=".not.pukryj"
public kraj_war:=".not.kukryj"
public granic_war:=".not.gukryj"
*public wybor_granic_war:=".not.gukryj.and.(alltrim(gkraj1)==alltrim(zbefor_kraj).or.alltrim(gkraj2)==alltrim(zbefor_kraj))"
public wybor_granic_war:=".not.gukryj.and.(alltrim(gkraj1)==alltrim(zlast_kraj).or.alltrim(gkraj2)==alltrim(zlast_kraj))"
public wybor1_granic_war:=".not.gukryj.and.((alltrim(gkraj1)==alltrim(zlast_kraj).or.alltrim(gkraj2)==alltrim(zlast_kraj)).or.(alltrim(gkraj2)==alltrim(zlast_kraj).and.alltrim(gkraj1)==alltrim(zlast_kraj)))"
public kursy_war:=".not.wukryj"
public delegac_war:=".not.danul.and.typ_del==ztyp_dok"
public przekroc_war:="pd_id=zd_id.and..not.panul"
public koszty_war:="sd_id=zd_id.and..not.sanul"
*sekcja _sel
public has_sel:=1
public pracow_sel:=2
public kraj_sel:=3
public granic_sel:=4
public kursy_sel:=5
public deleg_sel:=6
public koszty_sel:=7
public dokdef_sel:=8
public buf_sel:=9
public przekroc_sel:=10
public delegac_sel:=11
public cel_sel:=12
public param_sel:=14
*sekcja "delegac"
public zd_id:=0,zdpnazwisko:=space(20),zdp_id:=0,zstart_dat:=date()
public zstart_godz:=0,zstart_min:=0,zend_dat:=date(),zend_godz:=0
public zend_min:=0,zdkraj:=space(15),zdzalicz:=0,zdtabela:=space(30)
public zdwyroznik:=space(1),zdopis:=space(60),zdanul:=.f.,ztyp_del:=space(2)
public zdtab_dat:=date(),zdkoszty:=0,zdwaluta:=space(15),zdkoszt_co:=space(37)
public zdkurs:=0
*sekcja "koszty"
public zsd_id:=0,zskraj:=space(20),zsmin_il:=0,zdiet_il:=0,znocleg_il:=0
public zdiet_cen:=0,znoc_limit:=0,zswalut:=space(15),zskurs:=1
public znocf_il:=0,znocf_wart:=0,zpaliwo:=0,zautostrady:=0,zinne:=0
public zsanul:=.f.,zswyroznik:=space(1)
*sekcja "pracow"
public zp_id:=0,znazwisko:=space(20),zimie:=space(20),zpesel:=space(11)
public zpwyroznik:=space(1),zpukryj:=.f.,zpopis:=space(60)
*sekcja "kraj"
public zk_id:=0,zknazwa:=space(20),zkwaluta:=space(15),zkdieta:=0
public zknocleg:=0,zkwyroznik:=space(1),zkukryj:=.f.,zkopis:=space(60)
*sekcja "granice"
public zgnazwa:=space(20),zgkraj1:=space(20),zgkraj2:=space(20)
public zgwyroznik:=space(1),zgukryj:=.f.,zgopis:=space(60)
*sekcja "kursy"
public zwnazwa:=space(15),zwskrot:=space(3),zwkurs:=0
public zwwyroznik:=space(1),zwukryj:=.f.,zwopis:=space(60)
*sekcja dok_def
public zdokdef_recno:=recno()
public ztyp_dok:=space(2)
public znaz_dok:=space(12)
public zznak_dok:=space(1)
public zopis_dok:=space(80)
public zukryj:=.f.
*sekcja przekroc
public zpd_id:=0,zprzejscie:=space(20),zpdata:=date(),zpgodz:=0,zpmin:=0
public zpanul:=.f.,zkrocz_opis:=space(60),zbefor_kraj:=" POLSKA"
public zlast_kraj:=" POLSKA"
*sekcja buf
public bkraj:=space(20), bczas:=0,bnocleg:=0
*sekcja cel
public zdel_cel:=space(15)
RETURN

FUNCTION ZLEG_SH_PUBLIC()
public zlic1:=space(50),zlic2:=space(50),zlic3:=space(6)
public zlic4:=space(50),zlic5:=space(50),zlic6:=space(13)
public zlic0:=space(15)
public zleg_kod:=space(5),zlz1:=.f.,zlz2:=.f.,zlz3:=.f.,zl123:=.f.
public zlkod:=0,zldat:=date(),zld:=14
public zlic_regon:=space(10),zlic_pesel:=space(11),zlic_konto:=space(60)
public zlic_tel:=space(15),zlic_fax:=space(15)
RETURN nil

FUNCTION INDEKSACJA()
local ek,lcolor:=setcolor()
local ldserwer:=zd_serwer+"bazy",lset_serwer:=zd_serwer+"set"
save screen to ek
close all
set default to &ldserwer
if file("delegac.dbf")
  if kj_use("delegac",.t.,3)
    do skom with " Indeksacja pliku delegac.dbf"
    index on d_id to d_id
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku delegac.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
if file("koszty.dbf")
  if kj_use("koszty",.t.,3)
    do skom with " Indeksacja pliku koszty.dbf"
    index on sd_id to sd_id
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku koszty.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
if file("pracow.dbf")
  if kj_use("pracow",.t.,3)
    do skom with " Indeksacja pliku pracow.dbf"
    index on p_id to p_id
	index on nazwisko+imie to p_naz
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku pracow.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
if file("kraj.dbf")
  if kj_use("kraj",.t.,3)
    do skom with " Indeksacja pliku kraj.dbf"
    index on knazwa to k_naz
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku kraj.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
if file("granice.dbf")
  if kj_use("granice",.t.,3)
    do skom with " Indeksacja pliku granice.dbf"
    index on gnazwa to g_naz
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku delegac.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
if file("kursy.dbf")
  if kj_use("kursy",.t.,3)
    do skom with " Indeksacja pliku kursy.dbf"
    index on wnazwa to w_naz
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku kursy.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif

if file("delegac.dbf")
  if kj_use("delegac",.t.,3)
    do skom with " Indeksacja pliku delegac.dbf"
    index on start_dat to d_dat
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku delegac.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif

if file("przekroc.dbf")
  if kj_use("przekroc",.t.,3)
    do skom with " Indeksacja pliku przekroc.dbf"
    index on pd_id to pd_id
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku przekroc.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif
set default to &lset_serwer 
if file("buf.dbf")
  if kj_use("buf",.t.,3)
    do skom with " Indeksacja pliku buf.dbf"
    index on bkraj to b_naz
	use
  else
    if kj_gkom(12," Uwaga! ","Brak dostepu do pliku buf.dbf","Przerwac indeksacje ?",.t.,5)
	  restore screen from ek
      setcolor(lcolor)
	  return
	endif 	
  endif
endif

close all
buf_use()
kj_tkom(12," Ok! ","","Indeksacja zakonczona pomyslnie","Nacisnij dowolny klawisz",5)
restore screen from ek
setcolor(lcolor)
RETURN

*************************************Sekcja _LAD

FUNCTION DELEGAC_LAD()
zd_id=d_id
zdpnazwisko=dpnazwisko
zdp_id=dp_id
zstart_dat=start_dat
zstart_godz=start_godz
zstart_min=start_min
zend_dat=end_dat
zend_godz=end_godz
zend_min=end_min
zdkraj=dkraj
zdzalicz=dzalicz
zdtabela=dtabela
zdtab_dat=dtab_dat
zdkoszty=dkoszty
zdwaluta=dwaluta
zdkurs=dkurs
zdkoszt_co=dkoszt_co
zdwyroznik=dwyroznik
ztyp_del=typ_del
zdopis=dopis
zdanul=danul
if substr(ztyp_del,1,1)="Z"
  zkrajowa=.f.	    
else
  zkrajowa=.t.	    
endif		
RETURN

FUNCTION KOSZTY_LAD()
zsd_id=sd_id
zskraj=skraj
zsmin_il=smin_il
zdiet_il=diet_il
znocleg_il=nocleg_il
zdiet_cen=diet_cen
znoc_limit=noc_limit
zswalut=swalut
zskurs=skurs
znocf_il=nocf_il
znocf_wart=nocf_wart
zpaliwo=paliwo
zautostrady=autostrady
zinne=inne
zswyroznik=swyroznik
zsanul=sanul
RETURN

FUNCTION PRACOW_LAD()
zp_id=p_id
znazwisko=nazwisko
zimie=imie
zpesel=pesel
zpwyroznik=pwyroznik
zpukryj=pukryj
zpopis=popis
RETURN

FUNCTION KRAJ_LAD()
zk_id=k_id
zknazwa=knazwa
zkwaluta=kwaluta
zkdieta=kdieta
zknocleg=knocleg
zkwyroznik=kwyroznik
zkukryj=kukryj
zkopis=kopis
RETURN

FUNCTION GRANIC_LAD()
zgnazwa=gnazwa
zgkraj1=gkraj1
zgkraj2=gkraj2
zgwyroznik=gwyroznik
zgukryj=gukryj
zgopis=gopis
RETURN

FUNCTION KURSY_LAD()
zwnazwa=wnazwa
zwskrot=wskrot
zwkurs=wkurs
zwwyroznik=wwyroznik
zwukryj=wukryj
zwopis=wopis
RETURN

FUNCTION ZDOK_DEF_LAD()
zdokdef_recno=recno()
ztyp_dok=typ_dok
zznak_dok=znak_dok
znaz_dok=naz_dok
zopis_dok=opis_dok
zukryj=ukryj
RETURN NIL

FUNCTION PRZEKROC_LAD()
zpd_id=pd_id
zprzejscie=przejscie
zpdata=pdata
zpgodz=pgodz
zpmin=pmin
zkrocz_opis=krocz_opis
zbefor_kraj=befor_kraj
zlast_kraj=last_kraj
zpanul=panul
RETURN

FUNCTION BUF_LAD()
zbkraj=bkraj
zbczas=bczas
zbnocleg=bnocleg
RETURN

***************************************Sekcja _ZER

FUNCTION DELEGAC_ZER()
local select:=select()
zd_id=0
zdpnazwisko=space(20) 
zdp_id=0
zstart_dat=date()
zstart_godz=0
zstart_min=0
zend_dat=date()
zend_godz=0
zend_min=0
zdkraj=space(15)
zdzalicz=0
zdtabela=ztabela
zdtab_dat=ztabel_dat
zdkoszty=0
zdwaluta=space(15)
zdkurs=0
zdkoszt_co=space(37)
zdwyroznik=space(1)
ztyp_del=space(2)
zdopis=space(60)
zdanul=.f.
select &select
RETURN

FUNCTION KOSZTY_ZER()
zsd_id=0
zskraj=space(20)
zsmin_il=0
zdiet_il=0
znocleg_il=0
zdiet_cen=0
znoc_limit=0
zswalut=space(15)
zskurs=1
znocf_il=0
znocf_wart=0
zpaliwo=0
zautostrady=0
zinne=0
zswyroznik=space(1)
zsanul=.f.
RETURN

FUNCTION PRACOW_ZER()
zp_id=0
znazwisko=space(20)
zimie=space(20)
zpesel=space(11)
zpwyroznik=space(1)
zpukryj=.f.
zpopis=space(60)
RETURN

FUNCTION KRAJ_ZER()
zk_id=0
zknazwa=space(20)
zkwaluta=space(15)
zkdieta=0
zknocleg=0
zkwyroznik=space(1)
zkukryj=.f.
zkopis=space(60)
RETURN

FUNCTION GRANIC_ZER()
zgnazwa=space(20)
zgkraj1=space(20)
zgkraj2=space(20)
zgwyroznik=space(1)
zgukryj=.f.
zgopis=space(60)
RETURN

FUNCTION KURSY_ZER()
zwnazwa=space(13)
zwskrot=space(3)
zwkurs=0
zwwyroznik=space(1)
zwukryj=.f.
zwopis=space(60)
RETURN

FUNCTION PRZEKROC_ZER()
zpd_id=0
zprzejscie=space(20)
zpdata=date()
zpgodz=0
zpmin=0
zkrocz_opis=space(60)
zbefor_kraj=space(20)
zlast_kraj=space(20)
zpanul=.f.
RETURN

FUNCTION BUF_ZER()
zbkraj=space(20)
zbczas=0
zbnocleg=0
RETURN
****************************************Sekcja _USE
FUNCTION PRACOW_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &pracow_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("pracow",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to p_naz, p_id
endif
RETURN lsukces

FUNCTION KRAJ_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &kraj_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("kraj",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to k_naz
endif
RETURN lsukces

FUNCTION KOSZTY_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &koszty_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("koszty",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to sd_id
endif
RETURN lsukces

FUNCTION KURSY_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &kursy_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("kursy",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to w_naz
  set filter to wukryj=.f.
  go top
endif
RETURN lsukces

FUNCTION GRANIC_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &granic_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("granice",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to g_naz
endif
RETURN lsukces

FUNCTION PRZEKROC_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &przekroc_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("przekroc",.f.,3)
    lsukces:=.f.
	return
  endif
  set index to pd_id
endif
RETURN lsukces

FUNCTION BUF_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"set"
select &buf_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("buf",.t.,3)
    lsukces:=.f.
	return
  endif
endif
RETURN lsukces

FUNCTION DELEGAC_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &delegac_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("delegac",.f.,3)
    lsukces:=.f.
	return
  endif
endif
RETURN lsukces

FUNCTION CEL_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &cel_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("cel",.f.,3)
    lsukces:=.f.
	return
  endif
endif
RETURN lsukces

FUNCTION PARAM_USE()
local lsukces:=.t.
local ldserwer:=zd_serwer+"bazy"
select &param_sel
set default to &ldserwer
if.not.used()
  if.not.kj_use("param",.f.,3)
    lsukces:=.f.
	return
  endif
endif
RETURN lsukces

****************************************Sekcja _REPLAC

FUNCTION DELEGAC_REPLAC()
ztyp_del=ztyp_dok
replace d_id with zd_id
replace dpnazwisko with zdpnazwisko
replace dp_id with zdp_id
replace start_dat with zstart_dat
replace start_godz with zstart_godz
replace start_min with zstart_min
replace end_dat with zend_dat
replace end_godz with zend_godz
replace end_min with zend_min
replace dkraj with zdkraj
replace dzalicz with zdzalicz
replace dtabela with zdtabela
replace dtab_dat with zdtab_dat
replace dkoszty with zdkoszty
replace dwaluta with zdwaluta
replace dkurs with zdkurs
replace dkoszt_co with zdkoszt_co
replace dwyroznik with zdwyroznik
replace typ_del with ztyp_del
replace dopis with zdopis
replace danul with zdanul
RETURN

FUNCTION KOSZTY_REPLAC()
replace sd_id with zsd_id
replace skraj with zskraj
replace smin_il with zsmin_il
replace diet_il with zdiet_il
replace nocleg_il with znocleg_il
replace diet_cen with zdiet_cen
replace noc_limit with znoc_limit
replace swalut with zswalut
replace skurs with zskurs
replace nocf_il with znocf_il
replace nocf_wart with znocf_wart
replace paliwo with zpaliwo
replace autostrady with zautostrady
replace inne with zinne
replace swyroznik with zswyroznik
replace sanul with zsanul
RETURN

FUNCTION PRACOW_REPLAC()
replace p_id with zp_id
replace nazwisko with znazwisko
replace imie with zimie
replace pesel with zpesel
replace pwyroznik with zpwyroznik
replace pukryj with zpukryj
replace popis with zpopis
RETURN

FUNCTION KRAJ_REPLAC()
replace k_id with zk_id
replace knazwa with zknazwa
replace kwaluta with zkwaluta
replace kdieta with zkdieta
replace knocleg with zknocleg
replace kwyroznik with zkwyroznik
replace kukryj with zkukryj
replace kopis with zkopis
RETURN

FUNCTION GRANIC_REPLAC()
replace gnazwa with zgnazwa
replace gkraj1 with zgkraj1
replace gkraj2 with zgkraj2
replace gwyroznik with zgwyroznik
replace gukryj with zgukryj
replace gopis with zgopis
RETURN

FUNCTION KURSY_REPLAC()
replace wnazwa with zwnazwa
replace wskrot with zwskrot
replace wkurs with zwkurs
replace wwyroznik with zwwyroznik
replace wukryj with zwukryj
replace wopis with zwopis
RETURN

FUNCTION PRZEKROC_REPLAC()
replace pd_id with zpd_id
replace przejscie with zprzejscie
replace pdata with zpdata
replace pgodz with zpgodz
replace pmin with zpmin
replace krocz_opis with zkrocz_opis
replace befor_kraj with zbefor_kraj
replace last_kraj with zlast_kraj
replace panul with zpanul
RETURN

FUNCTION BUF_REPLAC()
replace bkraj with zbkraj
replace bczas with zbczas
replace bnocleg with zbnocleg
RETURN

********************************MENU

FUNCTION INNE_MENU(ppoz)
local ltnaz[4],ltlit[4],ltopis[4],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Hasào      "
ltnaz[2]:=" Indeksacja "
ltnaz[3]:=" Drukarka   "
ltnaz[4]:=" O programie"
ltlit[1]:=" H "
ltlit[2]:=" I "
ltlit[3]:=" D "
ltlit[4]:=" O "
ltopis[1]:="Edycja hasàa dost©pu"
ltopis[2]:="Odtworzenie baz indeksowych"
ltopis[3]:="Wyb¢r drukarki"
ltopis[4]:="Autor progarmu, Uæytkownik"
  lpoz=men_pion(1,53,4,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION KOSZT_MENU(ppoz)
local ltnaz[4],ltlit[4],ltopis[4],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Noclegi    "
ltnaz[2]:=" Autostrady "
ltnaz[3]:=" Paliwo     "
ltnaz[4]:=" Inne       "
ltlit[1]:=" N "
ltlit[2]:=" A "
ltlit[3]:=" P "
ltlit[4]:=" I "
ltopis[1]:="Rejestracja faktur za noclegi w tym kraju - wprowadzaÜ pojedynczo!"
ltopis[2]:="Rejestracja faktur za autostrady - à•czna wartoòÜ w tym kraju"
ltopis[3]:="Rejestracja faktur za paliwo - à•czna wartoòÜ w tym kraju"
ltopis[4]:="Rejestracja faktur na cele inne - à•czna wartoòÜ w tym kraju"
  lpoz=men_pion(6,17,4,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION KWOTA_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Zatwierd´ do wysokoòci limitu "
ltnaz[2]:=" Zatwierd´ peàn• kwot©         "
ltlit[1]:="   "
ltlit[2]:="   "
ltopis[1]:="Zatwierd´ wartoòÜ faktury tylko do wysokoòci limitu."
ltopis[2]:="Zatwierd´ peàn• wartoòÜ faktury z przekroczeniem limitu."
  lpoz=men_pion(14,33,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz


FUNCTION WALUT_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Tabela  "
ltnaz[2]:=" Kursy   "
ltlit[1]:=" T "
ltlit[2]:=" K "
ltopis[1]:="Edycja tabeli kurs¢w"
ltopis[2]:="Kursy walut"
  lpoz=men_pion(1,44,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

FUNCTION DELEG_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz
ltnaz[1]:=" Nowy dokument"
ltnaz[2]:=" Archiwum     "
ltlit[1]:=" N            "
ltlit[2]:=" A            "
ltopis[1]:="Tworzenie i wydruk nowego dokumentu sprzedazy "
ltopis[2]:="Przeglad wczesniej zarejestrowanych dokumentow"
save screen to ek
  lpoz=men_pion(5,13,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
RETURN lpoz

*******************************************************************************
* Tlo zgloszeniowe programu SH                                                *
*******************************************************************************
FUNCTION D_TLO()
local lcolor:=setcolor()
set color to "gr+/n,n/gr+"
@ 11,0 say "∞     ÕÀ …Õ   …ÕÕÕª                                                            ∞"
@ 12,0 say "∞      ∫…º        ∫                                                            ∞"
@ 13,0 say "∞      Ã ª        ∫   ÕÕÕ    D   E   L   E   G   A   T                         ∞"
@ 14,0 say "∞     Õ  »Õ       ∫                                                            ∞"
@ 15,0 say "∞             …ÕÕÕŒÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ     ∞"
@ 16,0 say "∞             »ÕÕÕº                                                            ∞"
@ 17,0 say "∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞"
if.not.zl123
  @ 14,0 say "∞     Õ  »Õ       ∫              wersja    D E M O                             ∞"
endif
setcolor(lcolor)	
RETURN NIL

*******************************************************************************
* Drukuje na ekranie kilka aktualnych parametrow programu SH                  *
*******************************************************************************
FUNCTION D_PARAMSAY()
setcolor("n/w,w/n")
@ 19,2 say " Aktualna data ..........."
@ 19,30 say date()
*@ 19,25 say space(20)
@ 20,2 say " Numer TABELI KURS‡W ....." 
@ 20,30 say ztabela
@ 21,2 say " Data TABELI KURS‡W ......"
@ 21,30 say ztabel_dat
@ 22,2 say " Katalog roboczy ....."
@ 22,26 say SUBSTR(curdir(),1,30)
setcolor("w/b/b/w")
@ 5,58 to 7,76
@ 6,60 say "Soft-KJ-Service"
RETURN (NIL)

**************************************PRACOW
FUNCTION PRACOW()
local t[3],q[3]
t[1]:="nazwisko"
t[2]:="imie"
t[3]:="pesel"
q[1]:="Nazwisko"
q[2]:="Imi©"
q[3]:="PESEL"
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Lista pracownik¢w"
s_kom("Dopisz   Popraw   Kasuj")
pracow_use()

set filter to &prac_war
go top
*set color to gr+/b
kj_okno(2,2,17, " P R A C O W N I C Y                                       ",5)
*set color to n/w,w/n
set color to
dbedit(3,3,18,59,t,"P_FU","",q,"ƒ",,"ƒ")
close
RETURN

FUNCTION P_FU()
local last:=lastkey(),ek,lcolor:=setcolor()
save screen to ek
pracow_lad()
do case
  case last=27
    return 0
  case chr(last)$"Dd"
  	pracow_zer()
	set filter to
	go top
	set order to 2
	go bottom
	zp_id=p_id+1
	set filter to &prac_war
	set order to 1
	pracow_say()
	if pracow_get()
      if kj_append(3)
	    pracow_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
	pracow_say()
	if pracow_get()
	  if reclock(5)      
        pracow_replac()
        unlock
      endif			      	  
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2
  case chr(last)$"Kk"
	pracow_say()
    if kj_gkom(5," Uwaga! ","Pracownik zostanie usuni©ty z listy.","WykonaÜ  ?",.t.,5)
	  if reclock(5)      
        replace pukryj with .t.
        unlock
      endif			      	  	
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
set color to gr+/b
if.not.empty(zpopis)
  @ 21,3 say "Uwagi :"
  @ 22,3 say zpopis
else
  @ 21,3 say "       "
  @ 22,3 say space(60)
endif
setcolor(lcolor)
RETURN 1

FUNCTION PRACOW_SAY()
local lcolor:=setcolor()
kj_okno(12,42,10, " Dane pracownika                    ",5)
set color to n/w,w/n
@ 14,44 say "Nazwisko .."
@ 16,44 say "Imi© ......"
@ 18,44 say "PESEL ....."
@ 20,44 say "Uwagi ....." 
@ 14,56 say znazwisko
@ 16,56 say zimie
@ 18,56 say zpesel
@ 20,56 say substr(zpopis,1,20)
setcolor(lcolor)
RETURN

FUNCTION PRACOW_GET()
local lcolor:=setcolor(),recno:=recno(),lzapis:=.t.,lpesel:=zpesel
set color to n/w,w/n
set cursor on
@ 14,56 get znazwisko picture "@!" when s_kom("Nazwisko pracownika")
@ 16,56 get zimie picture "@!" when s_kom("Imi© pracownika")
@ 18,56 get zpesel picture "@!" when s_kom("Numer PESEL pracownika")
@ 20,56 get zpopis picture "@S20" when s_kom("Uwagi dotycz•ce pracownika")
read
if lastkey()=27
  lzapis=.f.
else
  if.not.zpesel==lpesel
    if pesel_byl()
      lzapis=.f.
    endif
  endif
endif
set cursor off
setcolor(lcolor)
RETURN lzapis

FUNCTION PESEL_BYL()
local lbyl:=.f.,recno:=recno()
if.not.empty(zpesel)
  locate for pesel=zpesel
  if found()
    kj_tkom(8," Uwaga! "," Taki PESEL juæ istnieje!","Dotyczy pracownika: "+alltrim(nazwisko),"Zapis nie zostanie zapami©tany.",5)
    lbyl=.t.
  endif
  go recno
endif  
RETURN lbyl


**************************************KRAJE
FUNCTION KRAJ()
local t[4],q[4]
t[1]:="knazwa"
t[2]:="kwaluta"
t[3]:="kdieta"
t[4]:="knocleg"
q[1]:="Nazwa"
q[2]:="Waluta"
q[3]:="Dieta" 
q[4]:="Limit"
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Kraje obj©te rozliczeniem"
s_kom("Dopisz   Popraw   Kasuj")
kraj_use()
set filter to &kraj_war
go top
*set color to gr+/b
kj_okno(2,2,17, " K  R  A  J  E                                                              ",5)
*set color to n/w,w/n
set color to
dbedit(3,3,18,76,t,"KR_FU","",q,"ƒ",,"ƒ")
close
RETURN

FUNCTION KR_FU()
local last:=lastkey(),ek,lcolor:=setcolor()
save screen to ek
kraj_lad()
do case
  case last=27
    return 0
  case chr(last)$"Dd"
  	kraj_zer()
	kraj_say()
	if kraj_get()
        if kj_append(3)
	      kraj_replac()
          unlock
	    endif
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
*	if substr(knazwa,1,7)==" POLSKA"
*      kj_tkom(8," Uwaga! ",""," Pozycja nie moæe byÜ poprawiana!","",5)	
*	else
	  kraj_say()
	  if kraj_get()
	    if reclock(5)      
          kraj_replac()
          unlock
        endif			      	  
	  endif
*	endif
	restore screen from ek
	keyboard chr(205)	
	return 2
  case chr(last)$"Kk"
	if substr(knazwa,1,7)==" POLSKA"
      kj_tkom(8," Uwaga! ",""," Pozycja nie moæe byÜ usuni©ta!","",5)	
	else
	  kraj_say()
      if kj_gkom(5," Uwaga! ","Kraj zostanie usuni©ty z listy.","WykonaÜ  ?",.t.,5)
	    if reclock(5)      
          replace kukryj with .t.
          unlock
        endif			      	  	
	  endif
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
set color to gr+/b
if.not.empty(zkopis)
  @ 21,3 say "Uwagi :"
  @ 22,3 say zkopis
else
  @ 21,3 say "       "
  @ 22,3 say space(60)
endif
setcolor(lcolor)
RETURN 1

FUNCTION KRAJ_SAY()
local lcolor:=setcolor()
kj_okno(14,42,8, " Dane kraju                         ",5)
set color to n/w,w/n
@ 16,44 say "Nazwa ....."
@ 17,44 say "Waluta ...."
@ 18,44 say "Dieta ....."
@ 19,44 say "Limit ....."
@ 20,44 say "Uwagi ....." 
@ 16,56 say zknazwa  
@ 17,56 say zkwaluta 
@ 18,56 say zkdieta
@ 19,56 say zknocleg
@ 20,56 say substr(zkopis,1,20)
setcolor(lcolor)
RETURN

FUNCTION KRAJ_GET()
local lzapis:=.t.,recno:=recno(),lknazwa:=zknazwa
public vrow:=16
zk_5=16       &&Wiersz pierwszy
zk_24=20     &&Wiersz ostatni
set key 5 to koncz5()
set key 24 to koncz24()
set color to n/w,w/n	

do skom with "Strzalki-ruch kursora    [Enter]-zatwierdzenie " 
do while.t.
  set cursor on
  do case
    case vrow=16
	  @ 16,56 get zknazwa picture "@!"
	case vrow=17
	 * @ 17,56 get zkwaluta picture "@!"
	 walut_wybierz()
    case vrow=18
	  @ 18,56 get zkdieta picture "@!"
*      zmstawka=m_stawka(k_w+6,k_k+33)
    case vrow=19
	  @ 19,56 get zknocleg picture "@!"
    case vrow=20
	  @ 20,56 get zkopis picture "@S20"
  endcase
  read

  tone(1000,0.5)
  
  do case
    case lastkey()=27
      if kj_gkom(12," Uwaga! ","PrzerwaÜ edycj© ?","",.t.,5)
        lzapis=.f.
	    exit
	  endif  

	case substr(lknazwa,1,7)==" POLSKA".and..not.lknazwa==zknazwa
      kj_tkom(8," Uwaga! ",""," Pozycja nie moæe byÜ poprawiana!","",5)	
    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
    *case ((lastkey()=13.or.lastkey()=3).and.vrow=20).or.lastkey()=18.or.lastkey()=10
	case ((lastkey()=13.and.vrow>=20.or.lastkey()=3.and.vrow>20)).or.lastkey()=18.or.lastkey()=10
	  exit  
    case (lastkey()=13.or.lastkey()=24)   &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+5
		  vrow=vrow-1
	  endif		  
  endcase
  kraj_say()
enddo
if.not.alltrim(zknazwa)=="POLSKA"
  zknazwa=stuff(space(20),1,len(alltrim(zknazwa)),alltrim(zknazwa))
endif  
if lzapis.and..not.lknazwa==zknazwa
  if kraj_byl()
    lzapis=.f.
  endif
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
RETURN lzapis



FUNCTION KRAJ_BYL()
local lbyl:=.f.,recno:=recno()
seek zknazwa
if found()
  kj_tkom(8," Uwaga! "," Kraj o tej nazwie juæ zdefiniowano!","Zapis nie zostanie zapami©tany.","",5)
  lbyl=.t.
endif
if alltrim(zknazwa)=="POLSKA"
  kj_tkom(8," Uwaga! "," Kraj o tej nazwie juæ zdefiniowano!","Zapis nie zostanie zapami©tany.","",5)
  lbyl=.t.
endif
go recno
RETURN lbyl



**************************************GRANICE  PRZEJSCIA
FUNCTION GRANIC()
local t[3],q[3]
t[1]:="gnazwa"
t[2]:="gkraj1"
t[3]:="gkraj2"
q[1]:="Nazwa przejòcia"
q[2]:="Kraj graniczny 1"
q[3]:="Kraj graniczny 2"
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Lista przejòÜ granicznych"
s_kom("Dopisz   Popraw   Kasuj")
granic_use()
set filter to &granic_war
go top
*set color to gr+/b
kj_okno(2,2,17, " P R Z E J ó C I A     G R A N I C Z N E                              ",5)
*set color to n/w,w/n
set color to
dbedit(3,3,18,70,t,"G_FU","",q,"ƒ",,"ƒ")
close
RETURN

FUNCTION G_FU()
local last:=lastkey(),ek,lcolor:=setcolor()
save screen to ek
granic_lad()
do case
  case last=27
    return 0
  case chr(last)$"Dd"
  	granic_zer()
	granic_say()
	if granic_get()
      if kj_append(3)
	    granic_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
	granic_say()
	if granic_get()
	  if reclock(5)      
        granic_replac()
        unlock
      endif			      	  
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2
  case chr(last)$"Kk"
	kraj_say()
    if kj_gkom(5," Uwaga! ","Kraj zostanie usuni©ty z listy.","WykonaÜ  ?",.t.,5)
	  if reclock(5)      
        replace gukryj with .t.
        unlock
      endif			      	  	
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
set color to gr+/b
if.not.empty(zgopis)
  @ 21,3 say "Uwagi :"
  @ 22,3 say zgopis
else
  @ 21,3 say "       "
  @ 22,3 say space(60)
endif
setcolor(lcolor)
RETURN 1

FUNCTION GRANIC_SAY()
local lcolor:=setcolor()
kj_okno(15,42,7, " Opis przejòcia granicznego         ",5)
set color to n/w,w/n
@ 17,44 say "Nazwa ....."
@ 18,44 say "Kraj 1 ...."
@ 19,44 say "Kraj 2 ...."
@ 20,44 say "Uwagi ....." 
@ 17,56 say zgnazwa  
@ 18,56 say zgkraj1
@ 19,56 say zgkraj2 
@ 20,56 say substr(zgopis,1,20)
setcolor(lcolor)
RETURN

FUNCTION GRANIC_GET()
local lzapis:=.t.,recno:=recno(),lgnazwa:=zgnazwa
public vrow:=17
zk_5=17       &&Wiersz pierwszy
zk_24=20     &&Wiersz ostatni
set key 5 to koncz5()
set key 24 to koncz24()
set color to n/w,w/n	

do skom with "[Enter]-zatwierdzenie    [D]-Dopisz nowy kraj     [Esc]-rezygnacja" 
do while.t.
  set cursor on
  do case
    case vrow=17
	  @ 17,56 get zgnazwa picture "@!"
    case vrow=18
	  kraj_wybierz(1)
    case vrow=19
	  kraj_wybierz(2)
    case vrow=20
	  @ 20,56 get zgopis picture "@S20"
  endcase
  read

  tone(1000,0.5)
  
  do case
    case lastkey()=27
      if kj_gkom(12," Uwaga! ","PrzerwaÜ edycj© ?","",.t.,5)
        lzapis=.f.
	    exit
	  endif  


	case ((lastkey()=13.and.vrow>=20.or.lastkey()=3.and.vrow>20)).or.lastkey()=18.or.lastkey()=10
	  exit  
    case (lastkey()=13.or.lastkey()=24)   &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+5
		  vrow=vrow-1
	  endif		  
  endcase
  granic_say()
enddo
if lzapis.and..not.lgnazwa==zgnazwa
  if granic_byl()
    lzapis=.f.
  endif
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
RETURN lzapis



FUNCTION GRANIC_BYL()
local lbyl:=.f.,recno:=recno()
seek zgnazwa
if found()
  kj_tkom(8," Uwaga! "," Przejòcie graniczne o tej nazwie juæ zdefiniowano!","Zapis nie zostanie zapami©tany.","",5)
  lbyl=.t.
endif
go recno
RETURN lbyl




**************************************KURSY WALUT
FUNCTION KURSY()
local t[3],q[3]
t[1]:="wnazwa"
t[2]:="wskrot"
t[3]:="wkurs"
q[1]:="Nazwa"
q[2]:="Skr¢r"
q[3]:="Kurs" 
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Kursy walut zgodnie z tabel• NBP"
s_kom("Dopisz   Popraw   [Enter]-zmie‰ kurs    Kasuj")
kursy_use()
set filter to &kursy_war
go top
*set color to gr+/b
kj_okno(2,2,17, " K U R S Y   W A L U T                                  ",5)
*set color to n/w,w/n
set color to
dbedit(3,3,18,56,t,"W_FU","",q,"ƒ",,"ƒ")
close
RETURN

FUNCTION W_FU(tryb,numer)
local last:=lastkey(),ek,lcolor:=setcolor()
local lrow:=row(),lcol:=col(),lkurs:=1
save screen to ek
kursy_lad()
do case
  case last=27
    return 0
  case chr(last)$"Dd"
  	kursy_zer()
	kursy_say()
	if kursy_get()
      if kj_append(3)
	    kursy_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
	kursy_say()
	if kursy_get()
	  if reclock(5)      
        kursy_replac()
        unlock
      endif			      	  
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2
  
  *case chr(last)$"Pp".and.numer=3
  case last=13.and.numer=3
    lkurs=wkurs
	set cursor on
	@ lrow,lcol get lkurs
	read
	if.not.lastkey()=27
	  if reclock(5)      
        replace wkurs with lkurs
        unlock
      endif			      	  	  
	endif
	set cursor off
  
  case chr(last)$"Kk"
	kursy_say()
    if kj_gkom(5," Uwaga! ","Kraj zostanie usuni©ty z listy.","WykonaÜ  ?",.t.,5)
	  if reclock(5)      
        replace wukryj with .t.
        unlock
      endif			      	  	
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
set color to gr+/b
if.not.empty(zwopis)
  @ 21,3 say "Uwagi :"
  @ 22,3 say zwopis
else
  @ 21,3 say "       "
  @ 22,3 say space(60)
endif
setcolor(lcolor)
RETURN 1

FUNCTION KURSY_SAY()
local lcolor:=setcolor()
kj_okno(12,42,10, " Kursy walut                        ",5)
set color to n/w,w/n
@ 14,44 say "Nazwa ....."
@ 16,44 say "Skr¢t ....."
@ 18,44 say "Kurs ......"
@ 20,44 say "Uwagi ....." 
@ 14,56 say zwnazwa  
@ 16,56 say zwskrot  
@ 18,56 say zwkurs picture "99999.9999"
@ 20,56 say substr(zwopis,1,20)
setcolor(lcolor)
RETURN

FUNCTION KURSY_GET()
local lcolor:=setcolor(),lwnazwa:=zwnazwa,lzapis:=.t.
set color to n/w,w/n
set cursor on
@ 14,56 get zwnazwa picture "@!" 
@ 16,56 get zwskrot picture "@!"
@ 18,56 get zwkurs picture "99999.9999"
@ 20,56 get zwopis picture "@S20"
read
if lastkey()=27
  lzapis=.f.
endif
if.not.zwnazwa==lwnazwa
  if kursy_byl()
    lzapis=.f.
  endif
endif
set cursor off
setcolor(lcolor)
RETURN lzapis

FUNCTION KURSY_BYL()
local lbyl:=.f.,recno:=recno()
seek zwnazwa
if found()
  kj_tkom(8," Uwaga! "," Walut© o tej nazwie juæ zdefiniowano!","Zapis nie zostanie zapami©tany.","",5)
  lbyl=.t.
endif
go recno
RETURN lbyl

FUNCTION WALUT_WYBIERZ()
local t[1],q[1],ek,select:=select()
t[1]:="wnazwa"
q[1]:=""
set key 24 to
set key 5 to
save screen to ek
if kursy_use()
  set filter to &kursy_war
  go top
  keyboard chr(205)
  kj_okno(14,22,8, "  Wybierz walut©   ",5)
  s_kom("[Enter]-zatwierdzenie wyboru  [D]-Dopisz now• walut©  [Esc]-rezygnacja ")
  set color to n/w,w/n
  dbedit(15,23,21,39 ,t,"WW_FU","",q,"",,"")
endif
close
set key 5 to koncz5()
set key 24 to koncz24()
select &select
restore screen from ek
RETURN 

FUNCTION WW_FU()
local last:=lastkey(),ek
save screen to ek
do case
  case last=27
    return 0
  case last=13
    zkwaluta=wnazwa	
    zwkurs=wkurs
	return 0	
  case chr(last)$"Dd"
  	kursy_zer()
	kursy_say()
	if kursy_get()
      if kj_append(3)
	    kursy_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case last=5.and.bof()
    return 0	
  case last=24.and.eof()
    return 0		
endcase
RETURN 1

FUNCTION KRAJ_WYBIERZ(pkraj)
local t[1],q[1],ek,select:=select()
vkraj=pkraj
t[1]:="knazwa"
q[1]:=""
set key 24 to
set key 5 to
save screen to ek
if kraj_use()
  set filter to &kraj_war
  go top
  keyboard chr(205)
  do case
    case pkraj=1
	  locate for alltrim(knazwa)==alltrim(zgkraj1)
      kj_okno(15,22,7, "  Wybierz kraj 1   ",5)
    case pkraj=2
	  locate for alltrim(knazwa)==alltrim(zgkraj2)
      kj_okno(15,22,7, "  Wybierz kraj 2   ",5)	  
  endcase
  if.not.found()
    go top
  endif
  set color to n/w,w/n
  dbedit(16,23,21,39 ,t,"KK_FU","",q,"",,"")
endif
close
set key 5 to koncz5()
set key 24 to koncz24()
select &select
restore screen from ek
RETURN 

FUNCTION KK_FU()
local last:=lastkey(),ek
save screen to ek
do case
  case last=27
    return 0
  case last=13
    if vkraj=1
	  zgkraj1=knazwa
	else
	  zgkraj2=knazwa
	endif
    return 0	
  case chr(last)$"Dd"
	kraj_zer()
    kraj_say()
	  if kraj_get()
        if kj_append(3)
	      kraj_replac()
          unlock
	    endif	  
	  endif    
    restore screen from ek
    keyboard chr(205)	
    return 2
  case last=5.and.bof()
    return 0	
  case last=24.and.eof()
    return 0		
endcase
RETURN 1

FUNCTION PRACOW_WYBIERZ()
local t[1],q[1],ek,select:=select()
t[1]:="nazwisko"
q[1]:=""
set key 24 to
set key 5 to
save screen to ek
if pracow_use()
  set filter to &prac_war
  go top
  keyboard chr(205)
  s_kom("[Enter]-zatwierdzenie    [D]-Dopisz nowego pracownika    [Esc]-rezygnacja")
  kj_okno(9,17,13,"  Pracownik            " ,5)  
  set color to n/w,w/n
  locate for nazwisko==zdpnazwisko
  if.not.found()
    go top
  endif
  dbedit(10,18,21,37 ,t,"WP_FU","",q,"",,"")
endif
close
set key 5 to koncz5()
set key 24 to koncz24()
select &select
restore screen from ek
RETURN 

FUNCTION WP_FU()
local last:=lastkey(),ek
save screen to ek
do case
  case last=27
    return 0
  case last=13
    zdpnazwisko=nazwisko
	zdp_id=p_id
    return 0	
  case chr(last)$"Dd"
  	pracow_zer()
	set filter to
	go top
	set order to 2
	go bottom
	zp_id=p_id+1
	set filter to &prac_war
	set order to 1
	pracow_say()
	if pracow_get()
      if kj_append(3)
	    pracow_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case last=5.and.bof()
    return 0	
  case last=24.and.eof()
    return 0		
endcase
RETURN 1


FUNCTION CEL_WYBIERZ()
local t[1],q[1],ek,select:=select()
t[1]:="del_cel"
q[1]:=""
set key 24 to
set key 5 to
save screen to ek
if cel_use()
  keyboard chr(205)
  s_kom("[Enter] - zatwierd´   Dopisz   Popraw   Kasuj")
  kj_okno(9,23,13,"  Kraj docelowy  " ,5)  
  set color to n/w,w/n
  locate for del_cel==zdkraj
  if.not.found()
    go top
  endif
  dbedit(10,24,21,38 ,t,"WC_FU","",q,"",,"")
endif
close
set key 5 to koncz5()
set key 24 to koncz24()
select &select
restore screen from ek
RETURN 

FUNCTION WC_FU()
local last:=lastkey(),lcel:=space(15),ek
save screen to ek
do case
  case last=27
    return 0
  case last=13
    zdkraj=del_cel 
    return 0	
  case chr(last)$"Dd"
    @ 22,23 to 24,39
	@ 22,25 say "Nowy:"
	set cursor on    
	@ 23,24 get lcel
	read
	if.not.lastkey()=27
      if kj_append(3)
	    replace del_cel with lcel
        unlock
	  endif	  	
	endif
	set cursor off
	restore screen from ek
	keyboard chr(205)
	return 2
  case chr(last)$"Pp"
    lcel=del_cel
	@ 22,23 to 24,39
	@ 22,25 say "Popraw:"
	set cursor on    
	@ 23,24 get lcel
	read
	if.not.lastkey()=27
      if reclock(5)      
	    replace del_cel with lcel
        unlock
	  endif	  	
	endif
	set cursor off
	restore screen from ek
	keyboard chr(205)
	return 2    	
  case chr(last)$"Kk"
    lcel=del_cel
	if kj_gkom(12,"","Usun•Ü pozycj©",lcel,.t.,5)

			if.not.lastkey()=27	
				if reclock(5)      
	              delete
                  unlock
				endif		
			endif		  	  
	endif    	
	restore screen from ek
	keyboard chr(205)
	return 2    		
  case last=5.and.bof()
    return 0	
  case last=24.and.eof()
    return 0		
endcase
RETURN 1

FUNCTION PRZEKROC_WYBIERZ()
local t[1],q[1],ek,select:=select()
t[1]:="gnazwa"
q[1]:=""
set key 24 to
set key 5 to
save screen to ek
if granic_use()
  if.not.zkrocz_popraw
    set filter to &wybor_granic_war
  else
    set filter to &wybor1_granic_war
  endif	
  go top
  keyboard chr(205)
  kj_okno(14,22,8, " Wybierz przejòcie ",5)
  set color to n/w,w/n
  s_kom("[Enter] - zatwierd´   [D] - dopisz    [Esc] - zrezygnuj")
  dbedit(15,23,21,39 ,t,"WPG_FU","",q,"",,"")
endif
close
*set key 5 to koncz5()
*set key 24 to koncz24()
select &select
restore screen from ek
RETURN 

FUNCTION WPG_FU()
local last:=lastkey(),lcolor:=setcolor(),ek
save screen to ek
set color to gr+/b
@ 23,22 say space(50)
@ 23,22 say alltrim(gkraj1)+" - "+alltrim(gkraj2)
setcolor(lcolor)
do case
  case last=27
    return 0
  case last=13
    zprzejscie=gnazwa	
    if.not.zkrocz_popraw
	  aktual_kraj()
	endif  
	return 0	
  case chr(last)$"Dd"
  	granic_zer()
	granic_say()
	if granic_get()
      if kj_append(3)
	    granic_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case last=5.and.bof()
    keyboard chr(205)
	return 0	
  case last=24.and.eof()
    keyboard chr(205)
    return 0		
endcase
RETURN 1


FUNCTION AKTUAL_KRAJ()
zkrocz_opis="Z kraju  "+alltrim(aktual_kraj)+"  do kraju  "
	if alltrim(aktual_kraj)==alltrim(gkraj1)
	 zbefor_kraj=gkraj1
	 zlast_kraj=gkraj2
	 zkrocz_opis=zkrocz_opis+alltrim(zlast_kraj)
	else
 	  zbefor_kraj=gkraj2
	  zlast_kraj=gkraj1
	  zkrocz_opis=zkrocz_opis+alltrim(zlast_kraj)

*	  zbefor_kraj=gkraj2
	endif
aktual_kraj=zlast_kraj
RETURN	


**************************************DELEGAC
FUNCTION DELEGAC()
local t[4],q[4]
t[1]:="start_dat"
t[2]:="end_dat"
t[3]:="dpnazwisko"
t[4]:="dkraj"
q[1]:="Od dnia"
q[2]:="Do dnia"
q[3]:="Pracownik"
q[4]:="Kraj docelowy"
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Archiwum delegacji rozliczonych"
s_kom("Dopisz   Popraw   Kasuj   dRukuj  [Enter] - rozliczenie  [Esc] - rezygnacja")
delegac_use()
set filter to &delegac_war
go top
*set color to gr+/b
kj_okno(2,2,17, " D E L E G A C J E                                                   ",5)
*set color to n/w,w/n
set color to
keyboard chr(205)
dbedit(3,3,18,69,t,"D_FU","",q,"ƒ",,"ƒ")
close
RETURN

FUNCTION D_FU()
local last:=lastkey(),ek,lcolor:=setcolor(),lpoz:=1
save screen to ek
delegac_lad()
do case
  case last=13
    koszty()
	keyboard chr(205)
	return 2
  case last=27
    return 0
  case chr(last)$"Rr".and.zdruk_2	
    lpoz=w2_menu(lpoz)
	if.not.lastkey()=27
	  do case
	    case lpoz=1
	      del2wydruk(lpoz)			  
	    case lpoz=2
		  zprac_druk=prac_druk_menu(zprac_druk)
	      del2wydruk(lpoz)
	    case lpoz=3
	      del2wydruk(lpoz)		
	  endcase
	endif
	restore screen from ek

  case chr(last)$"Rr".and..not.zdruk_2	
    lpoz=dopliku_menu(lpoz)
	if.not.lastkey()=27
	  do case
	    case lpoz=1
	      zprac_druk=prac_druk_menu(zprac_druk)
		  delwydruk(.f.)
	    case lpoz=2
	      delwydruk(.t.)		
	  endcase
	endif
	restore screen from ek	
  case chr(last)$"Dd"
  	delegac_zer()
	set filter to
	go top
	go bottom
	zd_id=d_id+1
	set filter to &delegac_war
	go top
	delegac_say()
	if delegac_get()
      if kj_append(3)
	    delegac_replac()
        unlock
	  endif	  
	  if substr(ztyp_del,1,1)="Z"
        zkrajowa=.f.	    
      	** Dane do kontroli poprawnoòci dat
    		astart_dat=zstart_dat    
			astart_godz=zstart_godz
			astart_min=zstart_min    
		**	
		przekroc()
	  else
	    zkrajowa=.t.	    
	  endif	
	  koszty_licz(.f.)
	endif    
	
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
	delegac_say()
	if delegac_get()
	  if reclock(5)      
        delegac_replac()
        unlock
      endif	
	  if substr(ztyp_del,1,1)="Z"
	    zkrajowa=.f.	    
		przekroc()
	  else
	    zkrajowa=.t.	    
	  endif		  	
	  koszty_licz(.t.)	      	  
	endif
	
	restore screen from ek
	keyboard chr(205)	
	return 2
  case chr(last)$"Kk"
	delegac_say()
    if kj_gkom(5," Uwaga! ","Delegacja zostanie usuni©ta z archiwum.","WykonaÜ  ?",.t.,5)
	  if reclock(5)      
        replace danul with .t.
        unlock
      endif			      	  	
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
set color to gr+/b
if.not.empty(zdopis)
  @ 21,3 say "Uwagi :"
  @ 22,3 say zdopis
else
  @ 21,3 say "       "
  @ 22,3 say space(60)
endif
setcolor(lcolor)
RETURN 1

FUNCTION DELEGAC_SAY()
local lcolor:=setcolor()
local ld_txt:=delegac_txt(ztyp_dok)
local ltxt:=stuff(space(36),3,len(alltrim(ld_txt)),alltrim(ld_txt))
kj_okno(9,42,13,ltxt ,5)
set color to n/w,w/n
@ 11,44 say "Od dnia ..."
@ 12,44 say "   godz. .."
@ 13,44 say "   min. ..."
@ 14,44 say "Do dnia ..."
@ 15,44 say "   godz. .."
@ 16,44 say "   min. ..."
@ 17,44 say "Pracownik ."
@ 18,44 say "Kraj docel."
@ 19,44 say "Zaliczka .." 
@ 20,44 say "Uwagi ....." 
@ 11,56 say zstart_dat
@ 12,56 say zstart_godz picture "99"
@ 13,56 say zstart_min picture "99"
@ 14,56 say zend_dat
@ 15,56 say zend_godz picture "99"
@ 16,56 say zend_min picture "99"
@ 17,56 say zdpnazwisko
@ 18,56 say zdkraj    
@ 19,56 say zdzalicz picture "9999999.99"
@ 20,56 say substr(zdopis,1,20) 
setcolor(lcolor)
RETURN

FUNCTION DELEGAC_GET()
local lzapis:=.t.,recno:=recno(),lknazwa:=zknazwa
public vrow:=11
zk_5=11       &&Wiersz pierwszy
zk_24=20     &&Wiersz ostatni
set key 5 to koncz5()
set key 24 to koncz24()
set color to n/w,w/n	

do skom with "Strzalki-ruch kursora    [Enter]-zatwierdzenie" 
do while.t.
  set cursor on
  do case
    case vrow=11
	  @ 11,56 get zstart_dat when s_kom("Wpisz dat© rozpocz©cia delegacji.  dd.mm.rr")
    case vrow=12
	  @ 12,56 get zstart_godz picture "99" range 0,23  when s_kom("Wpisz godzin© rozpocz©cia delegacji.")
    case vrow=13
	  @ 13,56 get zstart_min picture "99" range 0,59 when s_kom("Wpisz minut© rozpocz©cia delegacji.")
    case vrow=14
	  @ 14,56 get zend_dat when s_kom("Wpisz dat© zako‰czenia delegacji.")
    case vrow=15
	  @ 15,56 get zend_godz picture "99" range 0,23 when s_kom("Wpisz godzin© zako‰czenia delegacji.")
    case vrow=16
	  @ 16,56 get zend_min picture "99" range 0,59 when s_kom("Wpisz minut© zako‰czenia delegacji.")
	case vrow=17
	 * @ 17,56 get zdpnazwisko picture "@!" when s_kom("Wybierz oddelegowanego pracownika.")
	  pracow_wybierz()
    case vrow=18
	 * @ 18,56 get zdkraj when s_kom("Wpisz cel delegacji.")
	 cel_wybierz()
    case vrow=19
	  @ 19,56 get zdzalicz picture "9999999.99" when s_kom("Wpisz kwot© wypàaconej zaliczki w zàot¢wkach.")
    case vrow=20
	  @ 20,56 get zdopis picture "@S20" when s_kom("Wpisz informacje dodatkowe dotycz•ce delegacji.")
  endcase
  read

  tone(1000,0.5)
  
  do case
	  
    case lastkey()=27
      if kj_gkom(12," Uwaga! ","PrzerwaÜ edycj© ?","",.t.,5)
        lzapis=.f.
	    exit
	  endif  

    case lastkey()=3.and.zkey10=.t.
	  zkey10=.f.
	  exit
    *case ((lastkey()=13.or.lastkey()=3).and.vrow=20).or.lastkey()=18.or.lastkey()=10
	case ((lastkey()=13.and.vrow>=20.or.lastkey()=3.and.vrow>20)).or.lastkey()=18.or.lastkey()=10
	  exit  
    case (lastkey()=13.or.lastkey()=24)   &&nastepna
	  vrow=vrow+1
    case lastkey()=5                   &&poprzednia
      if vrow>k_w+5
		  vrow=vrow-1
	  endif		  
    
  endcase
  delegac_say()
enddo
	  if.not.kontrol1_dat(zstart_dat,zstart_godz,zstart_min,zend_dat,zend_godz,zend_min)
	    kj_tkom(8," Uwaga! ","Bà©dnie podana data rozpocz©cia","lub zako‰czenia delegacji","",5)
        lzapis=.f.
	  endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
RETURN lzapis

FUNCTION DELEGAC_TXT(ptyp_dok)
local ldeleg_txt:=""
do case
  case ptyp_dok="KT"
    ldeleg_txt="Delegacja krajowa    "
  case ptyp_dok="ZT"
    ldeleg_txt="Delegacja zagraniczna"	
endcase
RETURN ldeleg_txt


**************************************PRZEKROC
FUNCTION PRZEKROC()
local t[5],q[5],select:=select()
t[1]:="pdata"
t[2]:="pgodz"
t[3]:="pmin"
t[4]:="przejscie"
t[5]:="krocz_opis"
q[1]:="Data"
q[2]:="Godzina" 
q[3]:="Minuta"
q[4]:="Przejòcie graniczne"
q[5]:="Kraje graniczne:  przed przekroczeniem granicy - po przekroczeniu"
      	** Dane do kontroli poprawnoòci dat
    		astart_dat=zstart_dat    
			astart_godz=zstart_godz
			astart_min=zstart_min    
		**	

w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Przekraczane granice"
s_kom("Dopisz   Popraw   Kasuj  [Enter] - zako‰cz")
przekroc_use()
set filter to &przekroc_war
go top
*set color to gr+/b
kj_okno(2,2,17, " P R Z E J ó C I A    G R A N I C Z N E                 ",7)
*set color to n/w,w/n
set color to
keyboard chr(205)
dbedit(3,3,18,56,t,"PG_FU","",q,"ƒ",,"ƒ")
close
select &select
RETURN

FUNCTION PG_FU()
local last:=lastkey(),ek,lcolor:=setcolor()
save screen to ek
zkrocz_popraw:=.f.
if.not.empty(pdata)
  przekroc_lad()
endif  

do case
  case last=27.or.lastkey()=13
    go bottom
	if.not.alltrim(last_kraj)=="POLSKA"
      if kj_gkom(5," Uwaga! ","Delegacja musi zako‰czyÜ si© w Polsce.","Czy nadal chcesz przerwaÜ definiowanie przejòÜ ?",.t.,5)	
        return 0
	  endif
	else
	  return 0
	endif
	
  case chr(last)$"Dd"
	go bottom
	if.not.empty(pdata)
	  astart_dat=pdata
	  astart_godz=pgodz
	  astart_min=pmin    
	endif
*	przekroc_zer()
*zpdata=date()
*zpgodz=0
*zpmin=0
	przekroc_say()
	if przekroc_get()
      zpd_id=zd_id
	  if kj_append(3)
	    przekroc_replac()
        unlock
	  endif	  
	endif    
	restore screen from ek
    keyboard chr(205)	
	return 2
  case chr(last)$"Pp"
	przekroc_say()
	zkrocz_popraw=.t.
*	zbefor_kraj=zbefor_kraj
	if przekroc_get()
	  if reclock(5)      
        przekroc_replac()
        unlock
      endif			      	  
	endif
	zkrocz_popraw=.f.
	restore screen from ek
	keyboard chr(205)	
	return 2
  case chr(last)$"Kk"
	*przekroc_say()
    if kj_gkom(5," Uwaga! ","Usun•Ü moæna tylko ostatniu wpis.","WykonaÜ  ?",.t.,5)
	  go bottom
	  if reclock(5)      
        delete
        unlock
      endif			      	  	
	endif
	restore screen from ek
	keyboard chr(205)	
	return 2	
endcase
if.not.empty(zkrocz_opis)
  @ 21,2 say substr(zkrocz_opis,1,56)
else
  @ 21,2 say space(56)
endif

set color to gr+/b
setcolor(lcolor)
RETURN 1

FUNCTION PRZEKROC_SAY()
local lcolor:=setcolor()
kj_okno(15,42,7, " Przekroczenie granicy              ",5)
set color to n/w,w/n
@ 17,44 say "Data ......"
@ 18,44 say "Godzina ..."
@ 19,44 say "Minuta ...."
@ 20,44 say "Nazwa ....."
@ 17,56 say zpdata
@ 18,56 say zpgodz picture "99"
@ 19,56 say zpmin picture "99"
@ 20,56 say zprzejscie
setcolor(lcolor)
RETURN

FUNCTION PRZEKROC_GET()
local lzapis:=.t.,recno:=recno(),lknazwa:=zknazwa
local lstart_dat:=zstart_dat,lstart_godz:=zstart_godz,lstart_min:=zstart_min
local lend_dat:=zend_dat,lend_godz:=zend_godz,lend_min:=zend_min
public vrow:=17
zk_5=17       &&Wiersz pierwszy
zk_24=20     &&Wiersz ostatni
set key 5 to koncz5()
set key 24 to koncz24()
set color to n/w,w/n	

do skom with "Strzalki-ruch kursora    [Enter]-zatwierdzenie " 
do while.t.
  set cursor on
  do case

    case vrow=17
	  @ 17,56 get zpdata
    case vrow=18
	  @ 18,56 get zpgodz range 0,23 picture "99"
    case vrow=19
	  @ 19,56 get zpmin range 0,59 picture "99"
	case vrow=20
	 * @ 17,56 get zkwaluta picture "@!"
	 przekroc_wybierz()	  
  endcase
  read

  tone(1000,0.5)
  
  if vrow=19.and..not.lastkey()=27
	if.not.zkrocz_popraw
	  if.not.kontrol_dat(astart_dat,astart_godz,astart_min,zend_dat,zend_godz,zend_min)
	    kj_tkom(8," Uwaga! ","Nie zachowana kolejnoòÜ wpis¢w ","lub bàednie podana data","",5)
	    vrow=17
	  endif
	else
      recno=recno()
	  skip -1
	  if.not.bof()
	    lstart_dat=pdata
		lstart_godz=pgodz
		lstart_min=pmin
	  endif      	  
	  go recno
	  skip
	  if.not.eof()
	    lend_dat=pdata
		lend_godz=pgodz
		lend_min=pmin
	  endif
	  go recno
	  if.not.kontrol_dat(lstart_dat,lstart_godz,lstart_min,lend_dat,lend_godz,lend_min)
	    kj_tkom(8," Uwaga! ","Nie zachowana kolejnoòÜ wpis¢w ","lub bàednie podana data","",5)
	    vrow=17
	  endif	  
	endif  
  endif
    do case
      case lastkey()=27
        if kj_gkom(12," Uwaga! ","PrzerwaÜ edycj© ?","",.t.,5)
          lzapis=.f.
	      exit
	    endif  

      case lastkey()=3.and.zkey10=.t.
	    zkey10=.f.
	    exit
	  case ((lastkey()=13.and.vrow>=20.or.lastkey()=3.and.vrow>20)).or.lastkey()=18.or.lastkey()=10
	    exit  
      case (lastkey()=13.or.lastkey()=24)   &&nastepna
	    vrow=vrow+1
      case lastkey()=5                   &&poprzednia
        if vrow>k_w+5
		    vrow=vrow-1
	    endif		  
    endcase
    przekroc_say()
enddo
**tu
*	astart_dat=zpdata
*	astart_godz=zpgodz
*	astart_min=zpmin
if lzapis.and..not.lknazwa==zknazwa
  *if kraj_byl()
  *  lzapis=.f.
  *endif
endif
set cursor off
setcolor(lcolor)
set key 24 to
set key 5 to
RETURN lzapis

**************************************KOSZTY
FUNCTION KOSZTY()
local t[12],q[12],select:=select(),ek,lcolor:=setcolor()
t[1]:="skraj"
t[2]:="diet_il"
t[3]:="diet_cen"
t[4]:="nocleg_il"
*t[5]:="kj_round(noc_limit/4,2)"
t[5]:="noc_rycz()"
t[6]:="swalut"
t[7]:="skurs"
t[8]:="nocf_il"
t[9]:="nocf_wart"
t[10]:="paliwo"
t[11]:="autostrady"
t[12]:="inne"
q[1]:="Kraj"
q[2]:="Diety" 
q[3]:="Ryczaàt d."
q[4]:="Nocl."
q[5]:="Ryczaàt n."
q[6]:="Waluta"
q[7]:="Kurs"
q[8]:="Il. faktur za nocleg"
q[9]:="Wartoòc faktur za nocleg"
q[10]:="Za paliwo"
q[11]:="Za autostrady"
q[12]:="Inne wydatki"
save screen to ek
w_tlo(.t.,4)
set color to n/w,w/n
@ 0,0 say space(80)
@ 0,2 say "Koszty delegacji"
s_kom("[Enter]-inne koszty   [Ctrl-Enter]-inne koszty z rozbiciem na kraje  [Esc]-rez.")
koszty_use()
set filter to &koszty_war
go top
*set color to gr+/b
kj_okno(2,1,15, " K O S Z T Y   D E L E G A C J I                                              ",5)
*set color to n/w,w/n
set color to
keyboard chr(205)
dbedit(3,2,17,77,t,"KD_FU","",q,"ƒ",,"ƒ")
close
select &select
setcolor(lcolor)
restore screen from ek
RETURN

FUNCTION NOC_RYCZ()
local lrycz:=kj_round(noc_limit/4,2)
if alltrim(skraj)=="POLSKA"
  lrycz=kj_round(1.5*diet_cen,2)
endif
RETURN lrycz

FUNCTION KD_FU()
local last:=lastkey(),ek,lcolor:=setcolor()
save screen to ek
koszty_lad()
do case
  case last=27
    return 0
  case last=13
    innekoszty_get()
	
	  
  case last=10         &&Ctrl-Enter
	  oknokoszt_get()

endcase
koszt_okno()
set color to gr+/b
setcolor(lcolor)
RETURN 1

FUNCTION KOSZT_OKNO()
local lcolor:=setcolor()
set color to n/w,w/n
@ 17,1 clear to 22,78
set color to r/w
@ 17,1 to 22,78
*set color to gr+/b
set color to n/w,w/n
@ 18,2 say "Inne koszty ... "+alltrim(zdkoszt_co)+"  "+str(zdkoszty)+"  "+alltrim(zdwaluta)
*@ 19,2 say "Wybrany kraj : " 
@ 19,2 say skraj
@ 19,18 say "Waluta ...               "
@ 19,30 say swalut
@ 19,46 say "Kurs ...             "  
@ 19,54 say skurs
*@ 19,2 say "Wydatki udokumentowane fakturami:"
@ 20,2 say "Noclegi ......"
@ 21,2 say "Autostrady ..."
@ 20,40 say "Paliwo ......."
@ 21,40 say "Inne ........."
@ 20,17 say nocf_wart
@ 21,17 say autostrady
@ 20,55 say paliwo
@ 21,55 say inne
setcolor(lcolor)
RETURN

FUNCTION OKNOKOSZT_GET()
local ek,ek1,ek2,lpoz:=1,lnoc_il:=0,lwartosc:=0,lwartosc_sum:=znocf_wart,lcolor:=setcolor()
local lkwot:=1,lautostrady:=zautostrady,lpaliwo:=zpaliwo,linne:=zinne
save screen to ek
kj_okno(4,15,10, " Udokumentowane fakturami koszty delegacji        ",5)
do while .t.
  koszty_lad()
  lwartosc_sum=znocf_wart
  lautostrady=zautostrady
  lpaliwo=zpaliwo
  linne=zinne
  lpoz=koszt_menu(lpoz)
  save screen to ek2
  if.not.lastkey()=27
    set color to n/w,w/n  
    do case
      case lpoz=1.and.nocleg_il=0
        kj_tkom(16," Uwaga! ","W tym kraju nie przysàuguje nocleg","Faktura nie moæe byÜ zarejestrowana.","",5)	    	    
        
      case lpoz=1
*        w_tlo(.f.,4)
		lnoc_il=0
		do while .t.
	      lnoc_il=lnoc_il+1
		  if lnoc_il>nocleg_il
		    lnoc_il=lnoc_il-1
		    kj_tkom(16," Uwaga! ","Limit nocleg¢w w tym kraju zostaà wyczerpany","Faktura nie moæe byÜ zarejestrowana.","",5)	    	    
		    exit
		  endif
		
		  @ 7,35 say "Faktura za nocleg:"
*		  @ 7,44 say lnoc_il picture "999"
		  set cursor on
		  @ 9,35 say "WartoòÜ:"
		  @ 9,44 get lwartosc picture "9999999.99"
		  read
		  set cursor off
		  if lastkey()=27
		    lnoc_il=lnoc_il-1
		    
			exit
		  endif
		  if lwartosc>noc_limit
		    save screen to ek1
		    @ 13,17 say "Uwaga!  Przekroczony limit!"
            lkwot=kwota_menu(lkwot)
		    restore screen from ek1
		    do case
		      case lkwot=1
			    lwartosc=noc_limit
		    endcase            		
		  endif
		  lwartosc_sum=lwartosc_sum+lwartosc
		  @ 11,35 say "Razem:"
		  @ 11,44 say lwartosc_sum picture "9999999.99"
          keyboard chr(205)	    
	    enddo
	    if reclock(5)      
            replace nocf_wart with lwartosc_sum,nocleg_il with znocleg_il-lnoc_il
            replace nocf_il with lnoc_il
			unlock
        endif		 
	
	  case lpoz=2  
		@ 9,35 say "Koszt autostrad:"
		set cursor on
		@ 11,40 get lautostrady picture "9999999.99" when s_kom("ù•czna wartoòÜ poniesionych koszt¢w na opàacenie autostrad.")	  
		read
		set cursor off
		if.not.lastkey()=27
	      if reclock(5)      
            replace autostrady with lautostrady
            unlock
          endif		 		
		endif
		
	  case lpoz=3  
		@ 9,35 say "Koszt paliwa:"
		set cursor on
		@ 11,40 get lpaliwo picture "9999999.99" when s_kom("ù•czna wartoòÜ poniesionych koszt¢w na paliwo.")	  
		read
		set cursor off
		if.not.lastkey()=27
	      if reclock(5)      
            replace paliwo with lpaliwo
            unlock
          endif		 		
		endif		
	  case lpoz=4  
		@ 9,35 say "Koszty inne: "
		set cursor on
		@ 11,40 get linne picture "9999999.99" when s_kom("ù•czna wartoòÜ poniesionych koszt¢w innych.")	  
		read
		set cursor off
		if.not.lastkey()=27
	      if reclock(5)      
            replace inne with linne
            unlock
          endif		 		
		endif		
    endcase
    restore screen from ek2	
    koszt_okno()
  else
    exit
  endif
enddo
setcolor(lcolor)
restore screen from ek
RETURN

FUNCTION INNEKOSZTY_GET()
local ek,select:=select(),lkwota:=zdkoszty,lcolor:=setcolor()
local lkoszt_co:=zkoszt_co,lwaluta:=zdwaluta,ldkurs:=zdkurs
if.not.empty(zdkoszt_co)
  lkoszt_co=zdkoszt_co
endif
save screen to ek
kj_okno(4,15,10, " Inne koszty delegacji                            ",5)      	
set color to n/w, w/n
do while .t.
  set cursor on
  @ 6,17 say "Koszty .......                         "
  @ 8,17 say "Kwota ........                         "
  @ 10,17 say "Waluta .......                         "
  @ 10,31 say lwaluta
  @ 6,31 get lkoszt_co picture "@S30"
  @ 8,31 get lkwota picture "9999999.99" when s_kom("Wpisz à•czn• kwot© wydatk¢w innych")
  read
  if .not. lastkey()=27
    walut_wybierz()
    set key 24 to
    set key 5 to    
	@ 10,31 say zkwaluta
	lwaluta=zkwaluta
	ldkurs=zwkurs
  endif
  if .not. lastkey()=27
    if kj_gkom(16,"","ZatwierdziÜ wprowadzone dane ?","",.t.,5)
      zdkoszty=lkwota
      zdwaluta=zkwaluta
	  zdkoszt_co=lkoszt_co
	  zdkurs=ldkurs
	  select &delegac_sel
				if reclock(5)      
	              replace dkoszty with zdkoszty, dwaluta with zdwaluta
                  replace dkoszt_co with zdkoszt_co,dkurs with zdkurs
				  unlock
	            endif			      	  
	  exit
	else
	  select &select
	endif
  else
	exit
  endif
enddo
restore screen from ek
select &select
setcolor(lcolor)
set cursor off
RETURN

FUNCTION KONTROL_DAT(pstart_dat,pstart_godz,pstart_min,pend_dat,pend_godz,pend_min)
local ldata_ok:=.f.,lmin_il:=0,lnoc_il:=0
local lrok:=year(pstart_dat),lmiesiac:=month(pstart_dat)
local ldzien:=day(pstart_dat),lgodz:=pstart_godz,lmin:=pstart_min
local lend_rok:=year(pend_dat),lend_miesiac:=month(pend_dat)
local lend_dzien:=day(pend_dat),lend_godz:=zend_godz,lend_min:=pend_min
local lkrocz_rok:=year(zpdata),lkrocz_miesiac:=month(zpdata)
local lkrocz_dzien:=day(zpdata),lkrocz_godz:=zpgodz,lkrocz_min:=zpmin
local select:=select()


if zpdata=pstart_dat
  if zpgodz<pstart_godz
    return .f.
  endif
  if zpgodz=pstart_godz
    if zpmin<=pstart_min
	  return .f.
	endif
  endif
endif
if zpdata=pend_dat
  if zpgodz>zend_godz
    return .f.
  endif
  if zpgodz=zend_godz
    if zpmin>=pend_min
	  return .f.
	endif
  endif
endif
* Jeòli daty nie s• r¢wne datom granicznym to :
if.not.zpdata=pstart_dat.and..not.zpdata=pend_dat
  if max(pstart_dat,zpdata)=pstart_dat
    return .f.
  endif
  if max(zpdata,pend_dat)=zpdata
    return .f.
  endif
endif
RETURN .t.

FUNCTION KONTROL1_DAT(pstart_dat,pstart_godz,pstart_min,pend_dat,pend_godz,pend_min)
local ldata_ok:=.f.,lmin_il:=0,lnoc_il:=0
local lrok:=year(pstart_dat),lmiesiac:=month(pstart_dat)
local ldzien:=day(pstart_dat),lgodz:=pstart_godz,lmin:=pstart_min
local lend_rok:=year(pend_dat),lend_miesiac:=month(pend_dat)
local lend_dzien:=day(pend_dat),lend_godz:=zend_godz,lend_min:=pend_min
local lkrocz_rok:=year(zpdata),lkrocz_miesiac:=month(zpdata)
local lkrocz_dzien:=day(zpdata),lkrocz_godz:=zpgodz,lkrocz_min:=zpmin
local select:=select()


if pstart_dat=pend_dat
  if pstart_godz>pend_godz
    return .f.
  endif
  if pstart_godz=pend_godz
    if pstart_min>=pend_min
	  return .f.
	endif
  endif
endif
* Jeòli daty nie s• r¢wne datom granicznym to :
if.not.pstart_dat=pend_dat
  if max(pstart_dat,pend_dat)=pstart_dat
    return .f.
  endif
endif
RETURN .t.


FUNCTION PARAM_LAD()
do while.not.eof()
  do case
    case alltrim(co)=="TABELA"
      ztabela=alltrim(jak)	
    case alltrim(co)=="TABEL_DAT"
      ztabel_dat=ctod(alltrim(jak))		  
    case alltrim(co)=="EDIT"
      edit=alltrim(jak)	  	  
    case alltrim(co)=="MARGINES"
      zmargines=val(jak)	
    case alltrim(co)=="ZKOSZT_CO"
      zkoszt_co=stuff(space(40),1,len(alltrim(jak)),alltrim(jak))	
    case alltrim(co)=="ZDRUK_2"
	  if alltrim(jak)="1"
	    zdruk_2=.t.
	  else
	    zdruk_2=.f.
	  endif
    case alltrim(co)=="ZPRACDRUK"
	  if alltrim(jak)="1"
	    zpracdruk=.t.
	  else
	    zpracdruk=.f.
	  endif	  
    case alltrim(co)=="ZNUMER_DRUK"
	  if alltrim(jak)="1"
	    znumer_druk=.t.
	  else
	    znumer_druk=.f.
	  endif	  	  
  endcase
  skip
enddo
RETURN nil

FUNCTION TABELA()
local ek,ltabela:=stuff(space(40),1,len(alltrim(ztabela)),alltrim(ztabela)),ltabel_dat:=ztabel_dat
save screen to ek
kj_okno(6,11,6, " TABELA KURS‡W WALUT                                     ",5)
@ 8,13 say "Numer ...."
@ 10,13 say "Data ....."
set cursor on
@ 8,24 get ltabela
@ 10,24 get ltabel_dat
read
set cursor off
ztabela=ltabela
ztabel_dat=ltabel_dat
if.not.lastkey()=27
  if param_use()
	locate for alltrim(co)=="TABELA"
	if found()
	  if reclock(5)      
        replace jak with ltabela
        unlock
      endif	
	endif
    locate for alltrim(co)=="TABEL_DAT"
	if found()
	  if reclock(5)      
	    replace jak with dtoc(ltabel_dat)
	    unlock
	  endif
	endif	  		      	      
  endif
endif
restore screen from ek
RETURN

*******************************************************************************
* Funkcja oblicza iloòÜ minut zawart• mi©dzy datami (zmin_il), iloòÜ minut    *
* w porze nocnej (znocmin_il) oraz iloòÜ naleænych w tym opkresie nocleg¢w    *
*******************************************************************************
FUNCTION ZEGAR(pstart_dat,pstart_godz,pstart_min,pend_dat,pend_godz,pend_min)
local lstart_rok:=year(pstart_dat),lstart_mies:=month(pstart_dat)
local lstart_dzien:=day(pstart_dat),lstart_godz:=pstart_godz,lstart_min:=pstart_min
local lend_rok:=year(pend_dat),lend_mies:=month(pend_dat)
local lend_dzien:=day(pend_dat),lend_godz:=pend_godz,lend_min:=pend_min
local ldat:=pstart_dat,lrok:=year(pstart_dat),lmies:=month(pstart_dat)
local ldzien:=day(pstart_dat),lgodz:=pstart_godz,lmin:=pstart_min
local lskok:=1
znoc_il=0
zmin_il=0
*znocmin_il - z przeniesienia z poprzednich okres¢w
do while .t..and..not.inkey()=27
  **
*  @ 17,2 say lstart_rok
*  @ 18,2 say lstart_mies
*  @ 19,2 say lstart_dzien
*  @ 20,2 say lstart_godz
*  @ 21,2 say lstart_min
*  @ 17,22 say lend_rok
*  @ 18,22 say lend_mies
*  @ 19,22 say lend_dzien
*  @ 20,22 say lend_godz
*  @ 21,22 say lend_min
*  @ 23,2 say lmin
  **
  zmin_il=zmin_il+lskok
  if lgodz>=21.or.lgodz<=7        &&Jeòli godziny nocne
    if.not.znocleg_byl            
	  znocmin_il=znocmin_il+lskok    
	  if znocmin_il=480
	    znocmin_il=0
		znoc_il=znoc_il+1	    
		znocleg_byl=.t.
	  endif
	endif
  endif
  lmin=lmin+lskok
  if lmin>=60
	lmin=0
	lgodz=lgodz+1
	if lgodz=21
	  znocleg_byl=.f.   && rozpoczyna odliczanie min. dla nowego noclegu
	endif
	if lgodz=24
	  lgodz=0
	  ldzien=ldzien+1
	  do case
	    case ldzien=29.and.lmies=2.and..not.(lrok=2004.or.lrok=2008.or.lrok=2012.or.lrok=2016.or.lrok=2020.or.lrok=2024.or.lrok=2028)
          ldzien=1
		  lmies=lmies+1
        case ldzien=30.and.lmies=2.and.(lrok=2004.or.lrok=2008.or.lrok=2012.or.lrok=2016.or.lrok=2020.or.lrok=2024.or.lrok=2028)
          ldzien=1
		  lmies=lmies+1
		case ldzien=31.and.(lmies=4.or.lmies=6.or.lmies=9.or.lmies=11)
		  ldzien=1
		  lmies=lmies+1
		case ldzien=32
		  ldzien=1
		  lmies=lmies+1    
	  endcase
	  if lmies=13
	    lmies=1
		lrok=lrok+1
	  endif
	endif
  endif
  if lrok=lend_rok.and.lmies=lend_mies.and.ldzien=lend_dzien.and.lgodz=lend_godz.and.lmin=lend_min
    exit
  endif
enddo

RETURN 


FUNCTION KOSZTY_LICZ(ppopraw)
local lstart_dat:=zstart_dat,lstart_godz:=zstart_godz,lstart_min:=zstart_min
local lend_dat:=zend_dat,lend_godz:=zend_godz,lend_min:=zend_min
local lpopraw:=ppopraw,select:=select(),ldiet_il:=0
local sel:=0
if ppopraw
  if koszty_use()
    set filter to sd_id=zd_id
    go top
      do while.not.eof()
				if reclock(5)      
	              delete
                  unlock
	            endif			  	  
	  skip
	enddo
  endif
  close
endif
if zkrajowa
  zegar(lstart_dat,lstart_godz,lstart_min,lend_dat,lend_godz,lend_min)
  koszty_wyp()
else
  if przekroc_use()
    set filter to &przekroc_war
	go top
	aktual_kraj=befor_kraj

	do while.not.eof()
	  lend_dat=pdata
	  lend_godz=pgodz
	  lend_min=pmin	
      zegar(lstart_dat,lstart_godz,lstart_min,lend_dat,lend_godz,lend_min)
      koszty_wyp()
	  lstart_dat=pdata
	  lstart_godz=pgodz
	  lstart_min=pmin	
	  aktual_kraj=last_kraj
	  skip
	enddo
	lend_dat=zend_dat
	lend_godz=zend_godz
	lend_min=zend_min	
    zegar(lstart_dat,lstart_godz,lstart_min,lend_dat,lend_godz,lend_min)
    koszty_wyp()	
	close
  endif
endif
if koszty_use()
  set filter to &koszty_war
  go top
  do while.not.eof()
    koszty_lad()
	if substr(skraj,1,7)==" POLSKA"
	  *zkrajowa=.t.
	  zpolska=.t.
	else
	  *zkrajowa=.f.
	  zpolska=.f.
	endif
    if kraj_use()
      locate for alltrim(knazwa)==alltrim(zskraj)
	  if found()
	    zdiet_cen=kdieta
		znoc_limit=knocleg
		zswalut=kwaluta
		close
	  else
        kj_tkom(8," Uwaga! ","Nie odnaleziono danych kraju",zskraj,"",5)	    
		close
		select &select
		return .f.
	  endif	  
      close
	  if kursy_use()	  
	    locate for alltrim(wnazwa)==alltrim(zswalut)
		if found()
		  zskurs=wkurs
		else
          kj_tkom(8," Uwaga! ","Nie odnaleziono kursu waluty",zswalut,"",5)	    
		  close
		  select &select
		  return .f.		
		endif
	  endif
	  close
	endif	
	select &koszty_sel	
	zdiet_il=diet_il()    
	  if reclock(5)      
        koszty_replac()
        unlock
      endif			      	  
    skip
  enddo
  close
endif  
select &select
RETURN

FUNCTION DIET_IL()
local ldiet_il:=0,lskok:=1440,lmin_il:=0,lkoncowka:=0
do while .t.
  lmin_il=lmin_il+lskok

  if lmin_il<=smin_il
    ldiet_il=ldiet_il+1
  else
    lmin_il=lmin_il-lskok
	lkoncowka=smin_il-lmin_il
    if zkrajowa
	  if ldiet_il=0        && pierwsza doba
	    do case
	      case lkoncowka>=720       &&powyæej 12 godz
	        ldiet_il=ldiet_il+1
	      case lkoncowka>=480       &&powyæej 8 godz
	  	     ldiet_il=ldiet_il+0.5
	    endcase			  
	  else                 && nast©pne doby
	    do case
	      case lkoncowka>=480       &&powyæej 8 godz
	  	     ldiet_il=ldiet_il+1
	      case lkoncowka>0
	         ldiet_il=ldiet_il+0.5	 
	    endcase			  	  
	  endif
	else             && zagraniczna
	  if.not.zpolska
	    do case
	      case lkoncowka>=720       &&powyæej 12 godz
	        ldiet_il=ldiet_il+1
	      case lkoncowka>=480       &&powyæej 8 godz
	  	     ldiet_il=ldiet_il+0.5
	      case lkoncowka>0 .and..not.zkrajowa
	         ldiet_il=ldiet_il+0.33	 
	    endcase	
	  else           && cz©òÜ krajowa delegacji zagranicznej
	    do case
	      case lkoncowka>=480       &&powyæej 8 godz
	  	     ldiet_il=ldiet_il+1
	      case lkoncowka>0
	         ldiet_il=ldiet_il+0.5	 
	    endcase			  	  	  
	  endif	
	endif

	exit   
  endif
enddo

RETURN ldiet_il

FUNCTION KOSZTY_WYP()
local select:=select()
if koszty_use()
  set filter to &koszty_war
  go top
  locate for skraj=aktual_kraj
  if.not.found()
      if kj_append(3)
	    replace sd_id with zd_id
		replace skraj with aktual_kraj,smin_il with zmin_il
		replace nocleg_il with znoc_il
        unlock
	  endif	      
  else
	  if reclock(5)      
	    replace smin_il with smin_il+zmin_il
		replace nocleg_il with nocleg_il+znoc_il
        unlock
      endif			      	    
  endif
  close
endif
select &select
RETURN

FUNCTION W2_MENU(ppoz)
local ltnaz[3],ltlit[3],ltopis[3],lbelka:="",lpoz:=ppoz,lcolor:=setcolor()
ltnaz[1]:=" Wzorzec  LPT"
ltnaz[2]:=" Standard LPT"
ltnaz[3]:=" Do pliku    "
ltlit[1]:=" N "
ltlit[2]:=" N "
ltlit[3]:=" D "
ltopis[1]:="Wydruk z wykorzystaniem wzorca skierowany na drukark©"
ltopis[2]:="Wydruk standardowy skierowany na drukark©"
ltopis[3]:="Wydruk standardowy skierowany do pliku"
set color to
  lpoz=men_pion(18,63,3,lbelka,ltnaz,ltlit,ltopis,lpoz)
setcolor(lcolor)
RETURN lpoz

FUNCTION DOPLIKU_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz,lcolor:=setcolor()
ltnaz[1]:=" Na drukark© "
ltnaz[2]:=" Do pliku    "
ltlit[1]:=" N "
ltlit[2]:=" D "
ltopis[1]:="Wydruk skierowany na drukark©"
ltopis[2]:="Wydruk skierowany do pliku"
set color to
  lpoz=men_pion(19,63,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
setcolor(lcolor)
RETURN lpoz

FUNCTION PRAC_DRUK_MENU(ppoz)
local ltnaz[2],ltlit[2],ltopis[2],lbelka:="",lpoz:=ppoz,lcolor:=setcolor()
ltnaz[1]:=" Drukuj dane pracownika         "
ltnaz[2]:=" Pomi‰ wydruk danych pracownika "
ltlit[1]:=" D "
ltlit[2]:=" P "
ltopis[1]:="Wydruk rozliczenia delegacji z uwzgl©dnieniem danych pracownika"
ltopis[2]:="Wydruk rozliczenia delegacji z pomini©ciem danych pracownika"
set color to
  lpoz=men_pion(19,28,2,lbelka,ltnaz,ltlit,ltopis,lpoz)
setcolor(lcolor)
RETURN lpoz

FUNCTION DELWYDRUK(pplik)
local ek, select:=select(),k:=0,lnoc:=0,lsum:=0,llicz:=0,ldkraj_sum:=0
local lzkraj_sum:=0
save scree to ek
delegac_lad()
if.not.pracow_use()
  select &select
  return    
endif
locate for p_id=zdp_id
if.not.found()
  kj_tkom(8," Uwaga! ",""," Wykryto problem w bazie pracownik¢w !","",5)	
  select &select
  return    
else
  pracow_lad()
endif

go top
if pplik
  k=0
  plik="wydruki\delegac.txt"
  set printer to &plik
else
  k=zmargines
  if.not.pstart_druk()
    set device to screen
 	restore screen from ek
	return .f.
  endif
endif
set device to printer
w=prow()
if.not.pplik
  k=zmargines
  @ w,0 say &zdr_kond
  @ w,k+19 say "R O Z L I C Z E N I E    D E L E G A C J I"
  w=w+1
  @ w,k+13 say "============================================"
  w=w+2
  if zprac_druk=1
    @ w,k say "Pracownik ......... "+&zdr_grubo+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel+&zdr_kgrubo
  endif	
else
  @ w,k say "Pracownik ......... "+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel
endif

w=w+2
if.not.pplik
  if.not.empty(zdkraj).and..not.zkrajowa
    @ w,k say "Kraj docelowy ..... "+alltrim(zdkraj)
    w=w+2
  endif
endif
@ w,k say "Data rozpocz©cia delegacji:      Dn. "+dtoc(zstart_dat)+"  godz. "+alltrim(str(zstart_godz))+"  min. "+alltrim(str(zstart_min))
w=w+1
@ w,k say "Data zako‰czenia delegacji:      Dn. "+dtoc(zend_dat)+"  godz. "+alltrim(str(zend_godz))+"  min. "+alltrim(str(zend_min))
if.not.zkrajowa
  w=w+2
  @ w,k say "Przejòcia graniczne:"
  if.not.przekroc_use()
    select &select
    set device to screen
    return    
  endif
  set filter to &przekroc_war
  go top
  do while.not.eof()
    w=w+1
    @ w,k+10 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
    skip  
  enddo
endif

if.not.koszty_use()
  select &select
  set device to screen
  return    
endif
set filter to &koszty_war
go top

w=w+2
@ w,k say "Koszty delegacji:"
do while.not.eof()
  ldkraj=0
  lzkraj_sum=0
  if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
    w=w+1
    if .not. pplik
	  @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
    else
      @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	endif
	if.not.diet_il=0
	  w=w+1
      llicz=kj_round(diet_il*diet_cen,2)
	  @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"
	  @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(llicz*skurs,2)
	endif  
    if.not.nocleg_il=0
	  if alltrim(skraj)=="POLSKA" 
	    lnoc=kj_round(diet_cen*1.5,2)
	  else
	    lnoc=kj_round(noc_limit/4,2)
	  endif	
	  w=w+1
      llicz=kj_round(nocleg_il*lnoc,2)
	  @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  
	  @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	  @ w,k+73 say"PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	endif    
   if.not.nocf_il=0
	  w=w+1
      llicz=nocf_wart
	  if nocf_il=1
        @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	  else
	    @ w,k say "   Noclegi z faktur  .....     na kwot© "
	  endif
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  
	  @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	  lsum=lsum+kj_round(nocf_wart*skurs,2)
	endif    	
   if.not.autostrady=0
	  w=w+1
	  llicz=autostrady
      @ w,k say "   Opàaty za autoatrady...     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(autostrady*skurs,2)
	endif    		
   if.not.paliwo=0
	  w=w+1
      llicz=paliwo
	  @ w,k say "   Opàaty za paliwo ......     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(paliwo*skurs,2)
	endif    		  
   if.not.inne=0
	  w=w+1
	  llicz=inne
      @ w,k say "   Inne wydatki ..........     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(inne*skurs,2)
	endif    			
    w=w+1
	@ w,k+44 say "----------"
	@ w,k+62 say "---------------"
	w=w+1
    @ w,k+34 say "Razem"
	@ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	@ w,k+62 say lzkraj_sum picture "9999999.99"
	@ w,k+73 say  "PLN"
	w=w+1
  endif	
  skip
enddo
w=w+1
if.not.pplik
  @ w,k+44 say "ù•czna wartoòÜ = "+&zdr_grubo
@ w,k+62 say lsum picture "9999999.99"
@ w,k+73 say  "PLN"+&zdr_kgrubo  
else
  @ w,k+44 say "ù•czna wartoòÜ = "
@ w,k+62 say lsum picture "9999999.99"
@ w,k+73 say  "PLN"
endif  

if.not.zdzalicz=0
  w=w+1
  @ w,k+44 say "Zaliczka ....... "
  @ w,k+62 say zdzalicz picture "9999999.99"
  @ w,k+73 say  "PLN"
  w=w+1
  do case
    case lsum>zdzalicz
	  @ w,k+44 say "Do wypàaty ..... "
	  @ w,k+62 say lsum-zdzalicz picture "9999999.99"
	  @ w,k+73 say  "PLN"
    case lsum=zdzalicz
	  @ w,k+44 say "Del. rozliczona  "
    case lsum<zdzalicz
	  @ w,k+44 say "Do zwrotu  ..... "
	  @ w,k+62 say zdzalicz-lsum picture "9999999.99"
	  @ w,k+73 say  "PLN"
  endcase
endif
if.not.zkrajowa
  w=w+2
  @ w,k say "Kursy walut: TABELA NBP Nr "+alltrim(ztabela)+" z dnia "+dtoc(zdtab_dat)
endif
eject
set device to screen
if pplik
  save screen to ek
  edi=edit+" wydruki\delegac.txt"
  run &edi 
  restore screen from ek
  set cursor off   
endif

select &select
RETURN

FUNCTION DEL2WYDRUK(pdruk)
local ek, select:=select(),k:=0,lnoc:=0,lsum:=0,llicz:=0,ldkraj_sum:=0
local lzkraj_sum:=0,lkraj:=.t.
local ldkoszty:=kj_round(zdkoszty*zdkurs,2)
if pdruk=3
  pplik=.t.
else  
  pplik=.f.
endif
save scree to ek
delegac_lad()
if.not.pracow_use()
  select &select
  return    
endif
locate for p_id=zdp_id
if.not.found()
  kj_tkom(8," Uwaga! ",""," Wykryto problem w bazie pracownik¢w !","",5)	
  select &select
  return    
else
  pracow_lad()
endif
go top
w=0


if pplik
  k=0
  plik="wydruki\delegac.txt"
  set printer to &plik
else
  k=zmargines
  if.not.pstart_druk()
    set device to screen
 	restore screen from ek
	return .f.
  endif
endif
set device to printer

if pdruk=1
  druk_k_wzor()
  if.not.zkrajowa
    druk_z_wzor()
  endif
  set device to screen
  select &select
  return  
endif

********************************Cz©òÜ krajowa
if.not.pplik
  k=zmargines
  @ w,0 say &zdr_kond
endif
  @ w,k+19 say "ROZLICZENIE DELEGACJI KRAJOWEJ  Nr"
  if znumer_druk
    @ w,k+54 say zd_id picture "9999"
    @ w,k+58 say "/"+alltrim(str(year(date())))+"/PL"
  endif
  w=w+1
if.not.pplik
  @ w,k+13 say "================================================="
  w=w+2
  if zprac_druk=1
    @ w,k say "Pracownik ......... "+&zdr_grubo+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel+&zdr_kgrubo
  endif	
else
  @ w,k say "Pracownik ......... "+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel
endif
w=w+2
@ w,k say "Data rozpocz©cia delegacji:      Dn. "+dtoc(zstart_dat)+"  godz. "+alltrim(str(zstart_godz))+"  min. "+alltrim(str(zstart_min))
w=w+1
@ w,k say "Data zako‰czenia delegacji:      Dn. "+dtoc(zend_dat)+"  godz. "+alltrim(str(zend_godz))+"  min. "+alltrim(str(zend_min))
if.not.zkrajowa
  w=w+2
  @ w,k say "Przejòcia graniczne:"
  if.not.przekroc_use()
    select &select
    set device to screen
    return    
  endif
  set filter to &przekroc_war
  go top
** tylko pierwsze i ostatnie przejòcie graniczne
  w=w+1
  @ w,k+10 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
  go bottom
  w=w+1
  @ w,k+10 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin)   
**  
endif

if.not.koszty_use()
  select &select
  set device to screen
  return    
endif
set filter to &koszty_war
go top

w=w+2
@ w,k say "Koszty delegacji:"
  if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
    w=w+1
    if .not. pplik
	  @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
    else
      @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	endif
	if.not.diet_il=0
	  w=w+1
      llicz=kj_round(diet_il*diet_cen,2)
	  @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"
	  @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(llicz*skurs,2)
	endif  
    if.not.nocleg_il=0
	  if alltrim(skraj)=="POLSKA" 
	    lnoc=kj_round(diet_cen*1.5,2)
	  else
	    lnoc=kj_round(noc_limit/4,2)
	  endif	
	  w=w+1
      llicz=kj_round(nocleg_il*lnoc,2)
	  @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  
	  @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	  @ w,k+73 say"PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	endif    
   if.not.nocf_il=0
	  w=w+1
      llicz=nocf_wart
	  if nocf_il=1
        @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	  else
	    @ w,k say "   Noclegi z faktur  .....     na kwot© "
	  endif
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  
	  @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	  lsum=lsum+kj_round(nocf_wart*skurs,2)
	endif    	
   if.not.autostrady=0
	  w=w+1
	  llicz=autostrady
      @ w,k say "   Opàaty za autoatrady...     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(autostrady*skurs,2)
	endif    		
   if.not.paliwo=0
	  w=w+1
      llicz=paliwo
	  @ w,k say "   Opàaty za paliwo ......     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(paliwo*skurs,2)
	endif    		  
   if.not.inne=0
	  w=w+1
	  llicz=inne
      @ w,k say "   Inne wydatki ..........     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(inne*skurs,2)
	endif    			
    w=w+1
	@ w,k+44 say "----------"
	@ w,k+62 say "---------------"
	w=w+1
    @ w,k+34 say "Razem"
	@ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	@ w,k+62 say lzkraj_sum picture "9999999.99"
	@ w,k+73 say  "PLN"
	w=w+1
  else
    w=w+2
	@ w,k say "W cz©òci krajowej delegacji nie przysàuguj• æadne koszty."
  endif	
w=w+1
if.not.pplik
  @ w,k+44 say "ù•czna wartoòÜ = "+&zdr_grubo
@ w,k+62 say lsum picture "9999999.99"
@ w,k+73 say  "PLN"+&zdr_kgrubo  
else
  @ w,k+44 say "ù•czna wartoòÜ = "
@ w,k+62 say lsum picture "9999999.99"
@ w,k+73 say  "PLN"
endif  

*if.not.zkrajowa
  w=w+2
*  @ w,k say "Kursy walut: TABELA NBP Nr "+alltrim(ztabela)+" z dnia "+dtoc(zdtab_dat)
*endif
if.not.pplik
  w=w+3
  @ w,k say "Podpis skàadaj•cego rozliczenie  .................."
  w=w+2
  @ w,k say "Zatwierdzam koszty na kwot©: "+ alltrim(str(lsum))+" zà            Podpis dyrektora .................."
  eject
  w=prow()  
  k=zmargines
  @ w,0 say &zdr_kond
else
  if .not. zkrajowa
    w=w+2
    @ w,k+25 say "*  *  *  *  *"
    w=w+1
  endif	
endif
********************************Cz©òÜ zagraniczna
if .not. zkrajowa
  @ w,k+11 say "ROZLICZENIE ZAGRANICZNEJ PODR‡ΩY SùUΩBOWEJ  Nr "
  if znumer_druk
    @ w,k+58 say zd_id picture "9999"
    @ w,k+62 say "/"+alltrim(str(year(date())))
  endif
  w=w+1
  if.not.pplik
    @ w,k+5 say "=========================================================="
    w=w+2
    if zprac_druk=1
	  @ w,k say "Pracownik ......... "+&zdr_grubo+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel+&zdr_kgrubo
	endif  
  else
    @ w,k say "Pracownik ......... "+alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel
  endif
  w=w+2
  if.not.pplik
    if.not.empty(zdkraj).and..not.zkrajowa
      @ w,k say "Kraj docelowy ..... "+alltrim(zdkraj)
      w=w+2
    endif
  endif
  @ w,k say "Data rozpocz©cia delegacji:      Dn. "+dtoc(zstart_dat)+"  godz. "+alltrim(str(zstart_godz))+"  min. "+alltrim(str(zstart_min))
  w=w+1
  @ w,k say "Data zako‰czenia delegacji:      Dn. "+dtoc(zend_dat)+"  godz. "+alltrim(str(zend_godz))+"  min. "+alltrim(str(zend_min))
  if.not.zkrajowa
    w=w+2
    @ w,k say "Przejòcia graniczne:"
    if.not.przekroc_use()
      select &select
      set device to screen
      return    
    endif
    set filter to &przekroc_war
    go top
    do while.not.eof()
      w=w+1
      @ w,k+10 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
      skip  
    enddo
  endif

  if.not.koszty_use()
    select &select
    set device to screen
    return    
  endif
  set filter to &koszty_war
  go top

  w=w+2
  @ w,k say "Koszty delegacji:"
  go top
  skip      && omini©cie Poski
  do while.not.eof()
    ldkraj_sum=0
    lzkraj_sum=0
    if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
      w=w+1
      if .not. pplik
	    @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
      else
        @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	  endif
	  if.not.diet_il=0
	    w=w+1
        llicz=kj_round(diet_il*diet_cen,2)
	    @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"
	    @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(llicz*skurs,2)
	  endif  
      if.not.nocleg_il=0
	    if alltrim(skraj)=="POLSKA" 
	      lnoc=kj_round(diet_cen*1.5,2)
	    else
	      lnoc=kj_round(noc_limit/4,2)
	    endif	
	    w=w+1
        llicz=kj_round(nocleg_il*lnoc,2)
	    @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  
	    @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	    @ w,k+73 say"PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	  endif    
      if.not.nocf_il=0
	    w=w+1
        llicz=nocf_wart
	    if nocf_il=1
          @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	    else
	      @ w,k say "   Noclegi z faktur  .....     na kwot© "
	    endif
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  
	    @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	    lsum=lsum+kj_round(nocf_wart*skurs,2)
	  endif    	
      if.not.autostrady=0
	    w=w+1
	    llicz=autostrady
        @ w,k say "   Opàaty za autoatrady...     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(autostrady*skurs,2)
	  endif    		
      if.not.paliwo=0
	    w=w+1
        llicz=paliwo
	    @ w,k say "   Opàaty za paliwo ......     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(paliwo*skurs,2)
	  endif    		  
      if.not.inne=0
	    w=w+1
	    llicz=inne
        @ w,k say "   Inne wydatki ..........     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(inne*skurs,2)
	  endif    			
      w=w+1
	  @ w,k+44 say "----------"
	  @ w,k+62 say "---------------"
	  w=w+1
      @ w,k+34 say "Razem"
	  @ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	  @ w,k+62 say lzkraj_sum picture "9999999.99"
	  @ w,k+73 say  "PLN"
	  w=w+1
    endif	
    skip
  enddo
  w=w+1

**
      if.not.zdkoszty=0
        w=w+1
        if .not. pplik
	      @ w,k say &zdr_grubo+"INNE KOSZTY ù§CZNIE           "+&zdr_kgrubo+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
        else
          @ w,k say "INNE KOSZTY ù§CZNIE           "+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
	    endif
	    w=w+1
	    llicz=inne
        @ w,k say zdkoszt_co
	    @ w,k+44 say "="
	    @ w,k+45 say zdkoszty picture "99999.99"	  	  	  
	    @ w,k+62 say ldkoszty picture "9999999.99"
	    @ w,k+73 say "PLN"          
	    lsum=lsum+ldkoszty
		w=w+1
		@ w,k+62 say "---------------"
		w=w+1
        @ w,k+44 say " Razem koszty  : "+&zdr_grubo
        @ w,k+62 say lsum picture "9999999.99"
        @ w,k+73 say  "PLN"+&zdr_kgrubo  
	  endif    			

**

*if.not.zkrajowa
  w=w+2
  @ w,k say "Kursy walut: TABELA NBP Nr "+alltrim(ztabela)+" z dnia "+dtoc(zdtab_dat)
*endif
*

*
  if.not.pplik
    w=w+3
    @ w,k say "Podpis skàadaj•cego rozliczenie  .................."
    w=w+2
    @ w,k say "Zatwierdzam à•czne koszty na kwot©: "+ alltrim(str(lsum))+" zà            Podpis dyrektora .................."
    if.not.zdzalicz=0
      w=w+1
      @ w,k say "Wypàacono zaliczk© .... "
      @ w,k+32 say zdzalicz picture "9999999.99"
      @ w,k+39 say  "PLN"
    endif
    eject
    setprc(0,0)
  endif  
endif
set device to screen
if pplik
  save screen to ek
  edi=edit+" wydruki\delegac.txt"
  run &edi 
  restore screen from ek
  set cursor off   
endif

select &select
RETURN

FUNCTION DRUK_K_WZOR()
********************************Cz©òÜ krajowa
local ek, select:=select(),k:=0,lnoc:=0,lsum:=0,llicz:=0,ldkraj_sum:=0
local lzkraj_sum:=0,lkraj:=.t.
local ldkoszty:=kj_round(zdkoszty*zdkurs,2)
k=0
w=0
if znumer_druk
  @ w,0 say &zdr_kkond
  @ w,k+60 say alltrim(str(zd_id))+ "/"+alltrim(str(year(date())))+&zdr_kond
else
  @ w,0 say &zdr_kond
endif
w=3
@ w,k+60 say alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel
w=5
if.not.empty(zdkraj).and..not.zkrajowa
  @ w,k+60 say alltrim(zdkraj)
endif
w=7  
@ w,60 say dtoc(zstart_dat)+"  godz. "+alltrim(str(zstart_godz))+"  min. "+alltrim(str(zstart_min))
w=8
@ w,60 say dtoc(zend_dat)+"  godz. "+alltrim(str(zend_godz))+"  min. "+alltrim(str(zend_min))



if.not.zkrajowa
  w=14
  *@ w,k say "Przejòcia graniczne:"
  if.not.przekroc_use()
    select &select
    set device to screen
    return    
  endif
  set filter to &przekroc_war
  go top
** tylko pierwsze i ostatnie przejòcie graniczne
  w=15
  @ w,50 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
  go bottom
  w=16
  @ w,50 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin)   
**  
endif


if.not.koszty_use()
  select &select
  set device to screen
  return    
endif
set filter to &koszty_war
go top

w=26
k=30
*@ w,k say "Koszty delegacji:"
  if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
    w=w+1
    if .not. pplik
	  @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
    else
      @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	endif
	if.not.diet_il=0
	  w=w+1
      llicz=kj_round(diet_il*diet_cen,2)
	  @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"
	  @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(llicz*skurs,2)
	endif  
    if.not.nocleg_il=0
	  if alltrim(skraj)=="POLSKA" 
	    lnoc=kj_round(diet_cen*1.5,2)
	  else
	    lnoc=kj_round(noc_limit/4,2)
	  endif	
	  w=w+1
      llicz=kj_round(nocleg_il*lnoc,2)
	  @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  
	  @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	  @ w,k+73 say"PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	  lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	endif    
   if.not.nocf_il=0
	  w=w+1
      llicz=nocf_wart
	  if nocf_il=1
        @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	  else
	    @ w,k say "   Noclegi z faktur  .....     na kwot© "
	  endif
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  
	  @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	  lsum=lsum+kj_round(nocf_wart*skurs,2)
	endif    	
   if.not.autostrady=0
	  w=w+1
	  llicz=autostrady
      @ w,k say "   Opàaty za autoatrady...     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(autostrady*skurs,2)
	endif    		
   if.not.paliwo=0
	  w=w+1
      llicz=paliwo
	  @ w,k say "   Opàaty za paliwo ......     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(paliwo*skurs,2)
	endif    		  
   if.not.inne=0
	  w=w+1
	  llicz=inne
      @ w,k say "   Inne wydatki ..........     na kwot© "
	  @ w,k+44 say "="
	  @ w,k+45 say llicz picture "99999.99"	  	  	  
	  @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	  @ w,k+73 say "PLN"          
      ldkraj_sum=ldkraj_sum+llicz
	  lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	  lsum=lsum+kj_round(inne*skurs,2)
	endif    			
    w=w+1
	@ w,k+44 say "----------"
	@ w,k+62 say "---------------"
	w=w+1
    @ w,k+34 say "Razem"
	@ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	@ w,k+62 say lzkraj_sum picture "9999999.99"
	@ w,k+73 say  "PLN"
	w=w+1
  else
    w=w+2
	@ w,k say "W cz©òci krajowej delegacji nie przysàuguj• æadne koszty."
  endif	
w=57
k=0
@ w,k+80 say "ZATWIERDZAM KOSZTY NA KWOT® :  "+&zdr_grubo+alltrim(str(lsum))+"PLN"+&zdr_kgrubo  	
*k=110
*@ w,k say &zdr_grubo
*@ w,k+1 say lsum picture "9999999.99"
*@ w,k+12 say  "PLN"+&zdr_kgrubo  

eject
RETURN

FUNCTION DRUK_Z_WZOR()
********************************Cz©òÜ zagraniczna
local ek, select:=select(),k:=0,lnoc:=0,lsum:=0,llicz:=0,ldkraj_sum:=0
local lzkraj_sum:=0,lkraj:=.t.
local ldkoszty:=kj_round(zdkoszty*zdkurs,2)
k=0
w=0
if znumer_druk
  @ w,0 say &zdr_kkond
  @ w,k+60 say alltrim(str(zd_id))+ "/"+alltrim(str(year(date())))+&zdr_kond
else
  @ w,0 say &zdr_kond
endif
*@ w,0 say &zdr_kkond
*@ w,k+65 say alltrim(str(zd_id))+ "/"+alltrim(str(year(date())))+&zdr_kond
w=3
@ w,k+60 say alltrim(zimie)+"  "+alltrim(znazwisko)+"    PESEL: "+zpesel
w=5
if.not.empty(zdkraj).and..not.zkrajowa
  @ w,k+60 say alltrim(zdkraj)
endif
w=7  
@ w,60 say dtoc(zstart_dat)+"  godz. "+alltrim(str(zstart_godz))+"  min. "+alltrim(str(zstart_min))
w=8
@ w,60 say dtoc(zend_dat)+"  godz. "+alltrim(str(zend_godz))+"  min. "+alltrim(str(zend_min))

if.not.zkrajowa
  w=13
  k=50
    if.not.przekroc_use()
      select &select
      set device to screen
      return    
    endif
    set filter to &przekroc_war
    go top
    do while.not.eof()
      w=w+1
      @ w,k say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
      skip  
    enddo
endif

if.not.koszty_use()
  select &select
  set device to screen
  return    
endif
set filter to &koszty_war
go top

w=25
k=30

  go top
  skip      && omini©cie Poski
  do while.not.eof()
    ldkraj_sum=0
    lzkraj_sum=0
    if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
      w=w+1
      if .not. pplik
	    @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
      else
        @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	  endif
	  if.not.diet_il=0
	    w=w+1
        llicz=kj_round(diet_il*diet_cen,2)
	    @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"
	    @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(llicz*skurs,2)
	  endif  
      if.not.nocleg_il=0
	    if alltrim(skraj)=="POLSKA" 
	      lnoc=kj_round(diet_cen*1.5,2)
	    else
	      lnoc=kj_round(noc_limit/4,2)
	    endif	
	    w=w+1
        llicz=kj_round(nocleg_il*lnoc,2)
	    @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  
	    @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	    @ w,k+73 say"PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	  endif    
      if.not.nocf_il=0
	    w=w+1
        llicz=nocf_wart
	    if nocf_il=1
          @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	    else
	      @ w,k say "   Noclegi z faktur  .....     na kwot© "
	    endif
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  
	    @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	    lsum=lsum+kj_round(nocf_wart*skurs,2)
	  endif    	
      if.not.autostrady=0
	    w=w+1
	    llicz=autostrady
        @ w,k say "   Opàaty za autoatrady...     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(autostrady*skurs,2)
	  endif    		
      if.not.paliwo=0
	    w=w+1
        llicz=paliwo
	    @ w,k say "   Opàaty za paliwo ......     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(paliwo*skurs,2)
	  endif    		  
      if.not.inne=0
	    w=w+1
	    llicz=inne
        @ w,k say "   Inne wydatki ..........     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(inne*skurs,2)
	  endif    			
      w=w+1
	  @ w,k+44 say "----------"
	  @ w,k+62 say "---------------"
	  w=w+1
      @ w,k+34 say "Razem"
	  @ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	  @ w,k+62 say lzkraj_sum picture "9999999.99"
	  @ w,k+73 say  "PLN"
	  w=w+1
    endif	
    skip
  enddo

      if.not.zdkoszty=0
        w=w+2
        if .not. pplik
	      @ w,k say &zdr_grubo+"INNE KOSZTY ù§CZNIE           "+&zdr_kgrubo+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
        else
          @ w,k say "INNE KOSZTY ù§CZNIE           "+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
	    endif
	    w=w+1
	    llicz=inne
        @ w,k say zdkoszt_co
	    @ w,k+44 say "="
	    @ w,k+45 say zdkoszty picture "99999.99"	  	  	  
	    @ w,k+62 say ldkoszty picture "9999999.99"
	    @ w,k+73 say "PLN"          
	    lsum=lsum+ldkoszty
		w=w+1
		@ w,k+62 say "---------------"
		w=w+1
        @ w,k+44 say " Razem koszty  : "+&zdr_grubo
        @ w,k+62 say lsum picture "9999999.99"
        @ w,k+73 say  "PLN"+&zdr_kgrubo  
	  endif    			
  w=54
  k=11
  @ w,k say "Kursy walut: TABELA  "+ alltrim(ztabela)+" z dnia "+dtoc(zdtab_dat)

    w=56

    if.not.zdzalicz=0
      w=w+1
      @ w,k say "Wypàacono zaliczk©: "+ALLTRIM(STR(zdzalicz,7,2))+"PLN" 
    endif
	k=0
    @ w,k+80 say "ZATWIERDZAM KOSZTY NA KWOT® :  "+&zdr_grubo+alltrim(str(lsum))+"PLN"+&zdr_kgrubo  	
    setprc(0,0)

eject
RETURN


if .not. zkrajowa
  if.not.zkrajowa
    w=w+2
    @ w,k say "Przejòcia graniczne:"
    if.not.przekroc_use()
      select &select
      set device to screen
      return    
    endif
    set filter to &przekroc_war
    go top
    do while.not.eof()
      w=w+1
      @ w,k+10 say przejscie + "   Dn. "+dtoc(pdata)+"  godz. "+str(pgodz)+"  min. "+str(pmin) 
      skip  
    enddo
  endif

  if.not.koszty_use()
    select &select
    set device to screen
    return    
  endif
  set filter to &koszty_war
  go top

  w=w+2
  @ w,k say "Koszty delegacji:"
  go top
  skip      && omini©cie Poski
  do while.not.eof()
    ldkraj_sum=0
    lzkraj_sum=0
    if .not.(diet_il=0.and.nocleg_il=0.and.nocf_il=0.and.paliwo=0.and.autostrady=0.and.inne=0) 
      w=w+1
      if .not. pplik
	    @ w,k say &zdr_grubo+skraj+&zdr_kgrubo+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))
      else
        @ w,k say skraj+space(1)+"Waluta: "+swalut+space(3)+"Kurs: "+alltrim(str(skurs,14,4))	
	  endif
	  if.not.diet_il=0
	    w=w+1
        llicz=kj_round(diet_il*diet_cen,2)
	    @ w,k say "   Diety ................."+str(diet_il) +" X "+alltrim(str(diet_cen))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"
	    @ w,k+62 say kj_round(diet_il*diet_cen*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(llicz*skurs,2)
	  endif  
      if.not.nocleg_il=0
	    if alltrim(skraj)=="POLSKA" 
	      lnoc=kj_round(diet_cen*1.5,2)
	    else
	      lnoc=kj_round(noc_limit/4,2)
	    endif	
	    w=w+1
        llicz=kj_round(nocleg_il*lnoc,2)
	    @ w,k say "   Nocleg ryczaàtowy ....."+str(nocleg_il) +" X "+alltrim(str(lnoc))
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  
	    @ w,k+62 say kj_round(nocleg_il*lnoc*skurs,2) picture "9999999.99"
	    @ w,k+73 say"PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)
	    lsum=lsum+kj_round(nocleg_il*lnoc*skurs,2)
	  endif    
      if.not.nocf_il=0
	    w=w+1
        llicz=nocf_wart
	    if nocf_il=1
          @ w,k say "   Nocleg z faktury  .....     na kwot© " 
	    else
	      @ w,k say "   Noclegi z faktur  .....     na kwot© "
	    endif
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  
	    @ w,k+62 say kj_round(nocf_wart*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  
	    lsum=lsum+kj_round(nocf_wart*skurs,2)
	  endif    	
      if.not.autostrady=0
	    w=w+1
	    llicz=autostrady
        @ w,k say "   Opàaty za autoatrady...     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(autostrady*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(autostrady*skurs,2)
	  endif    		
      if.not.paliwo=0
	    w=w+1
        llicz=paliwo
	    @ w,k say "   Opàaty za paliwo ......     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(paliwo*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(paliwo*skurs,2)
	  endif    		  
      if.not.inne=0
	    w=w+1
	    llicz=inne
        @ w,k say "   Inne wydatki ..........     na kwot© "
	    @ w,k+44 say "="
	    @ w,k+45 say llicz picture "99999.99"	  	  	  
	    @ w,k+62 say kj_round(inne*skurs,2) picture "9999999.99"
	    @ w,k+73 say "PLN"          
        ldkraj_sum=ldkraj_sum+llicz
	    lzkraj_sum=lzkraj_sum+kj_round(llicz*skurs,2)	  	  
	    lsum=lsum+kj_round(inne*skurs,2)
	  endif    			
      w=w+1
	  @ w,k+44 say "----------"
	  @ w,k+62 say "---------------"
	  w=w+1
      @ w,k+34 say "Razem"
	  @ w,k+45 say ldkraj_sum picture "99999.99"	  	  	   
	  @ w,k+62 say lzkraj_sum picture "9999999.99"
	  @ w,k+73 say  "PLN"
	  w=w+1
    endif	
    skip
  enddo

  w=w+1

**
      if.not.zdkoszty=0
        w=w+1
        if .not. pplik
	      @ w,k say &zdr_grubo+"INNE KOSZTY ù§CZNIE           "+&zdr_kgrubo+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
        else
          @ w,k say "INNE KOSZTY ù§CZNIE           "+space(1)+"Waluta: "+zdwaluta+space(3)+"Kurs: "+alltrim(str(zdkurs,14,4))
	    endif
	    w=w+1
	    llicz=inne
        @ w,k say zdkoszt_co
	    @ w,k+44 say "="
	    @ w,k+45 say zdkoszty picture "99999.99"	  	  	  
	    @ w,k+62 say ldkoszty picture "9999999.99"
	    @ w,k+73 say "PLN"          
	    lsum=lsum+ldkoszty
		w=w+1
		@ w,k+62 say "---------------"
		w=w+1
        @ w,k+44 say " Razem koszty  : "+&zdr_grubo
        @ w,k+62 say lsum picture "9999999.99"
        @ w,k+73 say  "PLN"+&zdr_kgrubo  
	  endif    			

**

  w=54
  @ w,k say alltrim(ztabela)+" z dnia "+dtoc(zdtab_dat)
*

*
  if.not.pplik
    w=w+3
    @ w,k say "Podpis skàadaj•cego rozliczenie  .................."
    w=w+2
    @ w,k say "Zatwierdzam à•czne koszty na kwot©: "+ alltrim(str(lsum))+" zà            Podpis dyrektora .................."
    if.not.zdzalicz=0
      w=w+1
      @ w,k say "Wypàacono zaliczk© .... "
      @ w,k+32 say zdzalicz picture "9999999.99"
      @ w,k+39 say  "PLN"
    endif
    eject
    setprc(0,0)
  endif  
endif
RETURN



FUNCTION PODPIS(pkwota)

RETURN

FUNCTION O_PROGRAMIE()
local ek
save screen to ek
kj_okno(3,15,18, " O programie                                         ",2)
@ 5,17 say  "Autorem programu jest                             "
@ 6,17 say  "            mgr inæ. Krzysztof Jaworski           "
@ 8 ,17 say "Soft-KJ-Service   Hetma‰ska 63   05-120 Legionowo "
@ 9 ,17 say "Tel. (022) 784 59 19  lub  0 604 219 784          "
@ 10,17 say "           www.kj.z.pl         kj@z.pl            "

if.not.zl123
  @ 13,17 say "                                                  "
  @ 15,17 say "                                                  "
  @ 16,17 say "                Wersja  D E M O                   "
  @ 17,17 say "                                                  "
  @ 17,25 say "                                                  "
  @ 18,17 say "                                                  "
  @ 19,17 say "                                                  "
else
  @ 13,17 say "Licencjonowany UΩYTKOWNIK :                       "
  @ 15,17 say zlic1
  @ 16,17 say zlic2
  @ 17,17 say zlic3
  @ 17,25 say zlic4
  @ 18,17 say zlic5
  @ 19,17 say zlic6
endif
inkey(0)
restore screen from ek
RETURN