      PARAMETER (NL=30,NQ=101) 
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT
      DIMENSION PP(NQ),G(NL),WC(NL)
      CHARACTER *64 TITLE

      OPEN(5,FILE='VDIN1.DAT')
      OPEN(6,FILE='VDOU.DAT') 
      READ(5,'(A)')     TITLE
      WRITE(6,'(1X,A)') TITLE

      GAW=0.03125
      PII=3.14159265
      NP=1

      READ(5,*) NPROB,NOPT,NBPRES,NNP,NBX,NMAT,DX
      WRITE(6,3) NPROB,NNP,NBX,NMAT,DX
 
      IF(NOPT.EQ.0)WRITE(6,4)
      IF(NOPT.EQ.1)WRITE(6,5)
      IF(NOPT.EQ.2)WRITE(6,6)
      IF(NOPT.EQ.3)WRITE(6,7)
      IF(NOPT.EQ.4)WRITE(6,8)
      IF(NBPRES.EQ.1)WRITE(6,9)
      IF(NBPRES.EQ.2)WRITE(6,10)

      DEPF=DX*FLOAT(NBX-1)       
      WRITE(6,11)DEPF
      DEPPR = DX*FLOAT(NNP-1)
      WRITE(6,12)DEPPR
      NEL=NNP-1
      L=0
      WRITE(6,21)
   22 READ(5,*)N,IE(N,1)
   25 L=L+1
      IF(N-L .gt. 0) GOTO 30
   35 WRITE(6,32)L,IE(L,1) 
      IF(NEL-L .gt. 0) GOTO 22
   40 CONTINUE 
      WRITE(6,390)
      GOTO 400
   30 IE(L,1)=IE(L-1,1) 
      WRITE(6,32)L,IE(L,1)
      GOTO 25
  400 READ(5,*) M,G(M),WC(M),EO(M)
  401 FORMAT(I5,3F10.3) 
      IF(NMAT-M .lt. 0) GOTO 403
      IF(NMAT-M .eq. 0) GOTO 405
      GOTO 400
  403 WRITE(6,404) M

  405 DO M=1,NMAT
        WRITE(6,407) M,G(M),WC(M),EO(M)
      ENDDO

 1000 READ(5,*) DGWT,IOPTION,NOUT
      READ(5,*)Q,BLEN,BWID,MRECT
      WRITE(6,50) DGWT
      IF(NOUT.EQ.1)WRITE(6,51)
      IF(NOUT.EQ.0)WRITE(6,52)
      IF(IOPTION.EQ.0.OR.NOPT.EQ.1)WRITE(6,61)
      IF(IOPTION.EQ.1.AND.NOPT.EQ.0)WRITE(6,62)
      WRITE(6,90)Q,BLEN,BWID
      IF(MRECT.EQ.0)WRITE(6,91)
      IF(MRECT.EQ.1)WRITE(6,92)

C	CALCULATION OF EFFECTIVE OVERBURDEN PRESSURE

  105 P(1)=0.0
      PP(1)=0.0
      DXX=DX
      DO I=2,NNP 
        MTYP=IE(I-1,1) 
        WCC=WC(MTYP)/100.
        GAMM=G(MTYP)*GAW*(1.+WCC)/(1.+EO(MTYP))
        IF(DXX.GT.DGWT)GAMM=GAMM-GAW
        P(I)=P(I-1)+DX*GAMM 
        PP(I)=P(I) 
        DXX=DXX+DX
      ENDDO

      IF(NOPT.NE.0.OR.IOPTION.EQ.0)GOTO 120
      MO=IFIX(DGWT/DX) 
      IF(MO.GT.NNP)MO=NNP 
C     Line below previously had type (no space b/w DO I)
      DO I=1,MO
      BN=DGWT/DX-FLOAT(I-1) 
      P(I)=P(I)+BN*DX*GAW
      ENDDO

  120 CALL SLAB(Q,BLEN,BWID,MRECT,NBPRES,PP(NBX)) 
C	CALCULATION OF MOVEMENT FROM MODELS
      IF(NOPT.EQ.0) CALL MECH(NMAT)
      IF(NOPT.EQ.1) CALL LEON(Q,NMAT,DGWT,BWID,PP,NBPRES)
      IF(NOPT.EQ.2) CALL SCHMERT(Q,NMAT,DGWT,BWID,PP,NBPRES,2) 
      IF(NOPT.EQ.3) CALL COLL(NMAT)
      IF(NOPT.EQ.4) CALL SCHMERT(Q,NMAT,DGWT,BWID,PP,NBPRES,4) 
      NP=NP+1
      IF(NP.GT.NPROB) GOTO 200
      GOTO 1000
  200 CLOSE(5) 
      CLOSE(6) 
      STOP
    2 FORMAT(6I5,F10.2)
    3 FORMAT (/,1X,'NUMBER OF PROBLEMS=',I5,5X,'NUMBER OF NODAL POINTS='
     +,I5,/,1X,'NUMBR OF NODAL POINT AT BOTTOM OF FOUNDATION=',I11,/,1X
     +,'NUMBER OF DIFFERENT SOIL LAYERS=',I5,5X,'INCRMENT DEPTH=',F10.2
     +,'	FT',/) 
    4 FORMAT(10X,'CONSOLIDATION SWELL MODEL',/) 
    5 FORMAT(10X,'LEONARDS AND FROST MODEL',/) 
    6 FORMAT(10X,'SCHMERTMANN MODEL',/) 
    7 FORMAT(10X,'COLLAPSIBLE SOIL',/) 
    8 FORMAT(10X,'ELASTIC SOIL',/) 
    9 FORMAT(10X,'RECTANGULAR SLAB FOUNDATION',/) 
   10 FORMAT(10X,'LONG CONTINUOUS STRIP FOUNDATION',/) 
   11 FORMAT(1X,'DEPTH OF FOUNDATION =',12X,F10.2,'	FEET') 
   12 FORMAT(1X,'TOTAL DEPTH OF THE SOIL PROFILE =',F10.2,'     FEET') 
   21 FORMAT(1X,'ELEMENT	NUMBER OF SOIL',/)
   32 FORMAT(I5,8X,I5) 
   45 FORMAT(F10.2,2I5) 
   46 FORMAT(3F10.2,I5) 
   50 FORMAT(1X,'DEPTH TO WATER TABLE =',11X,F10.2,'	FEET',/) 
   51 FORMAT(1X,'DISPLACEMENTS AT EACH DEPTH OUTPUT',/)
   52 FORMAT(1X,'TOTAL DISPLACEMENTS ONLY',/) 
   61 FORMAT(1X,'EQUILIBRIUM SATURATED PROFILE ABOVE WATER TABLE',/)
   62 FORMAT(1X,'EQUILIBRIUM HYDROSTATIC PROFILE ABOVE WATER TABLE',/) 
   90 FORMAT(/,1X,'APPLIED PRESSURE ON FOUNDATION=',F10.2,' TSF',/,1X,
     1'LENGTH =',F10.2,'	FEET',5X,'WIDTH =',F10.2,'	FEET',/)
   91 FORMAT(9X,'CENTER OF FOUNDATION',/) 
   92 FORMAT(9X,'CORNER OF SLAB OR EDGE OF LONG STRIP FOOTING',/) 
  390 FORMAT(/,1X,'MATERIAL   SPECIFIC GRAVITY   WATER CONTENT,%	',
     1'VOID RATIO',/)
  404 FORMAT(/,5X,'ERROR IN MATERIAL', I5) 
  407 FORMAT(I5,3F18.3)
      END
C
C***********************************************************
C
      SUBROUTINE MECH(NMAT) 
      PARAMETER(NL=30,NQ=101)
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT 
      DIMENSION SP(NL),CS(NL),CC(NL),PM(NL)
      WRITE(6,5)
      DO 10 I = 1,NMAT
      READ(5,*) M,SP(M),CS(M),CC(M),PM(M) 
      IF(PM(M).LT.SP(M)) WRITE(6,14) SP(M),PM(M) 
      IF(PM(M).LT.SP(M)) PM(M)=SP(M) 
      WRITE(6,24)M,SP(M),CS(M),CC(M),PM(M)
   10 CONTINUE
C
      READ(5,*)XA,XF
      WRITE(6,31) XA,XF
      DELH1=0.0
      DXX=0.0
      CALL PSAD(N1,N2,XA,XF,DXX,DX,NBX) 
      IF(N1.GE.N2) GOTO 50
      IF(NOUT.EQ.0) GOTO 50
      WRITE(6,32)
      DO 40 I=N1,N2
      MTYP=IE(I,1) 
      PR=(P(I)+P(I+1))/2. 
      CA=SP(MTYP)/PR 
      CB=SP(MTYP)/PM(MTYP) 
      CBB=PM(MTYP)/PR 
      E=EO(MTYP)+CS(MTYP)*ALOG10(CA)
      IF(PR.GT.PM(MTYP)) E=EO(MTYP)+CS(MTYP)*ALOG10(CB)+CC(MTYP)*ALOG10
     1(CBB)
      DEL=(E-EO(MTYP))/(1.+EO(MTYP)) 
      IF(NOUT.EQ.0) GOTO 36
      DELP=SP(MTYP)-PR 
      WRITE(6,110) I,DXX,DEL,DELP
   36 DELH1=DELH1+DX*DEL 
      DXX=DXX+DX
   40 CONTINUE
   50 DELH2=0.0
      IF(NBX.GT.NEL) GOTO 120
      DXX=FLOAT(NBX)*DX-DX/2. 
      IF(NOUT.EQ.0) GOTO 65
      WRITE(6,60)
   65 DO 100 I=NBX,NEL 
      MTYP=IE(I,1)
      PR=(P(I)+P(I+1))/2. 
      CA=SP(MTYP)/PR 
      CB=SP(MTYP)/PM(MTYP) 
      CBB=PM(MTYP)/PR 
      E=EO(MTYP)+CS(MTYP)*ALOG10(CA)
      IF(PR.GT.PM(MTYP))E=EO(MTYP)+CS(MTYP)*ALOG10(CB)+CC(MTYP)*ALOG10
     1(CBB)
      DEL=(E-EO(MTYP))/(1.+EO(MTYP))
      IF(NOUT.EQ.0) GOTO 80
      DELP=SP(MTYP)-PR 
      WRITE(6,110) I,DXX,DEL,DELP
   80 DELH2=DELH2+DX*DEL 
      DXX=DXX+DX
  100 CONTINUE
      DEL1=DELH1+DELH2
      WRITE(6,305) DELH1,DELH2,DEL1
  120 RETURN 
    5 FORMAT(/,1X,'MATERIAL SWELL PRESSURE, SWELL COMPRESSION
     1	MAXIMUM PAST',/,1X,'	TSF	INDEX
     2	INDEX	PRESSURE,TSF',/) 
   11 FORMAT(I5,4F10.4)
   14 FORMAT(/,1X,'SWELL PRESSURE',F10.2,'	WAS SET GREATER THAN MAXIM',
     1'UM PAST PRESSURE',F10.2,/,1X,'WHICH IS NOT POSSIBLE; SWELL PRESSU
     2RESET EQUAL TO MAXIMUM PAST PRESSURE',/)
   24 FORMAT(1X,I5,4F15.3) 
   30 FORMAT(2F10.2) 
   31 FORMAT(/,8X,'ACTIVE ZONE DEPTH (FT) =',F10.2,/,1X,'DEPTH ACTIVE ZO
     1NE BEGINS (FT) =',F10.2,/) 
   32 FORMAT(/,1X,'HEAVE DISTRIBUTION ABOVE FOUNDATION DEPTH',/,1X,'ELEM
     1ENT	DEPTH,FT	DELTA HEAVE,FT	EXCESS PORE PRESSURE,TSF',/) 
   60 FORMAT(/,1X,'HEAVE DISTRIBUTION BELOW FOUNDATION',/,1X,'ELEMENT
     1 DEPTH,FT	DELTA HEAVE,FT	EXCESS PORE PRESSURE,TSF',/)
  110 FORMAT(I5,F13.2,F18.5,5X,F18.5) 
  305 FORMAT(/,1X,'SOIL HEAVE NEXT TO FOUNDATION EXCLUDING HEAVE',/,1X,
     1'IN SUBSOIL BENEATH FOUNDATION =',F8.5,'	FEET',//,14X,'SUBSOIL',
     2'MOVEMENT =',F8.5,'	FEET',/,19X,'TOTAL HEAVE =',F8.5,'	FEET')
      END
C
C*******************************************************************
C
      SUBROUTINE SLAB(Q,BLEN,BWID,MRECT,NBPRES,WT) 
      PARAMETER (NL=30,NQ=101) 
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT
C
C	CALCULATION OF SURCHARGE PRESSURE FROM STRUCTURE
C
      NNP=NEL+1
      ANBX=FLOAT(NBX)*DX 
      DXX=0.0
      BPRE1=Q-WT 
      BPRES=BPRE1
      DO 100 I=NBX,NNP 
      IF(DXX.LT.0.01) GOTO 80
      MTYP=IE(I-1,1) 
      IF(NBPRES.EQ.2) GOTO 70
      BL=BLEN 
      BW=BWID 
      BPR=BPRES
      IF(MRECT.EQ.1) GOTO 50
      BL=BLEN/2. 
      BW=BWID/2.
   50 VE2=(BL**2.+BW**2.+DXX**2.)/(DXX**2.) 
      VE=VE2**0.5
      AN=BL*BW/(DXX**2.) 
      AN2=AN**2. 
      ENM=(2.*AN*VE/(VE2+AN2))*(VE2+1.)/VE2
      FNM=2.*AN*VE/(VE2-AN2) 
      IF(MRECT.EQ.1)BPR=BPRES/4. 
      AB=ATAN(FNM)
      IF(FNM.LT.0.) AB=PII+AB 
      P(I)=P(I)+BPR*(ENM+AB)/PII 
      GOTO 90
   70 DB=DXX/BWID
      PS=-0.157-0.22*DB 
      IF(MRECT.EQ.0.AND.DB.LT.2.5)PS=-0.28*DB 
      PS=10.**PS
      P(I)=P(I)+BPRES*PS 
      GOTO 90
   80 P(I)=P(I)+BPRES
   90 DXX=DXX+DX
  100 CONTINUE 
      RETURN 
      END
C 
C******************************************************************* 
C
      SUBROUTINE PSAD(N1,N2,XA,XF,DXX,DX,NBX) 
      AN1=XF/DX
      AN2=XA/DX
      N1=IFIX(AN1)+1
      N2=AN2
      DXX=XF+DX/2. 
      N3=NBX-1
      IF(N2.GT.N3)N2=N3
      CONTINUE 
      RETURN 
      END
C
C*******************************************************************
C
      SUBROUTINE LEON(Q,NMAT,DGWT,BWID,PP,NBPRES) 
      PARAMETER(NL=30,NQ=101) 
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT 
      DIMENSION PO(NL),P1(NL),QC(NL),PP(NQ)
      WRITE(6,5)
    5 FORMAT(/,1X,'MATERIAL A PRESSURE, TSF B PRESSURE, TSF CONE
     1RESISTANCE, TSF',/)
      DO 10 I = 1,NMAT 
      READ(5,*)M,PO(M),P1(M),QC(M) 
      WRITE(6,20)M,PO(M),P1(M),QC(M)
   10 CONTINUE
      CALL SPLINE 
      NNP=NEL+1
      GAW=0.03125
      DELH=0.0
      DEL=0.0
      QNET=Q-PP(NBX) 
      WRITE(6,17)QNET
   17 FORMAT(/,1X,'QNET=',F10.5) 
      DXX=DX*FLOAT(NBX) - DX/2.
      C1=1 - 0.5*PP(NBX)/QNET 
      IF(C1.LT.0.5) C1=0.5
      IF(NOUT.EQ.0) GOTO 30
      WRITE(6,25)
   30 DO 300 I=NBX,NEL 
      MTYP=IE(I,1) 
      PR1=(PP(I+1)+PP(I))/2. 
      PR=(P(I+1)+P(I))/2. 
      UW=0.0
      IF(DXX.GT.DGWT) UW=(DXX-DGWT)*GAW 
      AKD = (PO(MTYP)-UW)/PR1
      AID = (P1(MTYP)-PO(MTYP))/(PO(MTYP)-UW) 
      ED = 34.7*(P1(MTYP)-PO(MTYP))
      RQC = QC(MTYP)/PR1
      AKO=0.376+0.095*AKD-0.0017*RQC 
      EC = AKO
      S3 = RQC 
      MM=0
      UC=0.0
      CALL BICUBE(UC,EC,S3) 
      S3=RQC 
      PHIPS=UC*PII/180.
      AKA = (1-SIN(PHIPS))/(1+SIN(PHIPS)) 
      AKP = (1+SIN(PHIPS))/(1-SIN(PHIPS)) 
      AAK = AKO
      IF(AKO.LE.AKA)AAK=AKA 
      IF(AKO.GE.AKP)AAK=AKP 
      IF(ABS(AAK-AKO).GT.0.01)EC=AAK
      IF(ABS(AAK-AKO).GT.0.01) CALL BICUBE(UC,EC,S3) 
      S3=RQC
      PHIAX=UC
      IF(UC.GT.32.0) PHIAX=UC-((UC-32.)/3.) 
      PHI=PHIAX*PII/180.
      OCR=(AAK/(1-SIN(PHI)))**(1./(0.8*SIN(PHI))) 
      PM=OCR*PR1
      ROC=(PM-PR1)/(PR-PR1) 
      IF(ROC.LT.0.0)ROC=0.0
      RNC=(PR-PM)/(PR-PR1) 
      IF(RNC.LT.0.0)RNC=0.0
      IF(NBPRES.EQ.2) GOTO 100
      ANN=0.5*BWID/DX + DX*FLOAT(NBX-1) 
      NN=IFIX(ANN)
      SIGM=PR1
      AIZP=0.5+0.1*(QNET/SIGM)**0.5
      DEPT=DXX-FLOAT(NBX-1)*DX 
      AIZ=0.1+(AIZP-0.1)*DEPT/(0.5*BWID) 
      IF(DEPT.GT.0.5*BWID)AIZ=AIZP+AIZP/3.0-AIZP*DEPT/(1.5*BWID) 
      IF(DEPT.GT.2*BWID)AIZ=0.0
      GOTO 200
  100 ANN=BWID/DX + DX*FLOAT(NBX-1) 
      NN=IFIX(ANN)
      SIGM=PR1
      AIZP=0.5+0.1*(QNET/SIGM)**0.5
      DEPT=DXX-FLOAT(NBX-1)*DX 
      AIZ=0.2+(AIZP-0.2)*DEPT/BWID 
      IF(DEPT.GT.BWID)AIZ=AIZP+AIZP/3.-AIZP*DEPT/(3.*BWID) 
      IF(DEPT.GT.4*BWID)AIZ=0.0
  200 F=0.7
      IF(ROC.LE.0.0)F=0.9
      DEL=-C1*QNET*AIZ*DX*(ROC/(3.5*ED)+RNC/(F*ED)) 
      DELH=DELH+DEL 
      IF(NOUT.EQ.1)WRITE(6,310)I,DXX,DEL,EC,S3,UC 
      DXX=DXX+DX
  300 CONTINUE
      WRITE(6,320) DELH
      RETURN
   15 FORMAT(I5,3F10.2)
   20 FORMAT(I5,3F18.2) 
   25 FORMAT(/,1X,'ELEMENT	DEPTH,	SETTLEMENT,	KO	QC/SIGV	PHI,
     1 DEGREES',/,1X,'	FT	FT',/)
  310 FORMAT(I5,F10.2,F13.5,3F10.2) 
  320 FORMAT(/,1X,'SETTLEMENT BENEATH FOUNDATION=',F10.5,'  FEET',/) 
      END 
C
C*******************************************************************
C
      BLOCK DATA
      DIMENSION XX(100),YY(100),U(100) 
      COMMON/SPL/XX,YY,U 
      DATA(XX(I),I=1,99,11)/9*10./,(XX(I),I=2,99,11)/9*20./,(XX(I),I=3,
     199,11)/9*30./,(XX(I),I=4,99,11)/9*50./,(XX(I),I=5,99,11)/9*100./,
     2(XX(I),I=6,99,11)/9*200./,(XX(I),I=7,99,11)/9*300./,(XX(I),I=8,99,
     311)/9*500./,(XX(I),I=9,99,11)/9*1000./,(XX(I),I=10,99,11)/9*2000./
     4,(XX(I),I=11,99,11)/9*3000./ 
      DATA(YY(I),I=1,11)/11*0.16/,(YY(I),I=12,22)/11*0.20/,(YY(I),I=23,
     133)/11*0.4/,(YY(I),I=34,44)/11*0.6/,(YY(I),I=45,55)/11*0.8/,(YY(I)
     2,I=56,66)/11*1.0/,(YY(I),I=67,77)/11*2.0/,(YY(I),I=78,88)/11*4./,
     3(YY(I),I=89,99)/11*6./ 
      DATA(U(I),I=1,99)/25.,30.1,33.2,36.4,39.9,42.8,44.4,46.,48.5,50.5,
     152.,24.8,30.,33.,36.2,39.7,42.6,44.2,45.8,48.2,50.2,51.5,24.5,29.7
     2,32.6,35.6,39.3,42.1,43.7,45.4,47.5,49.7,51.,24.2,29.5,32.2,35.1,
     338.8,41.7,43.3,45.,47.2,49.,50.,24.,29.2,31.7,34.7,38.4,41.4,42.9,
     444.6,46.8,48.6,49.7,23.8,28.8,31.5,34.4,38.,41.,42.5,44.3,46.5,48.
     54,49.5,23.,27.5,30.,33.,36.6,39.6,41.2,43.,45.4,47.2,48.4,22.,26.,
     628.3,31.2,34.5,37.7,39.7,41.5,43.7,45.7,47.,21.,25.,27.2,30.,33.8,
     736.,38.2,40.3,42.7,44.8,46.1/ 
      END
C 
C
      SUBROUTINE SPLINE
C	SPLINE TO CALCULATE VARIABLES 
      DIMENSION XX(100),YY(100),U(100) 
      COMMON/SPL/XX,YY,U 
      COMMON/SPLIN/X(100),Y(100),S(100) 
      COMMON/BICUB/UX(100),UY(100),UXY(100) 
      NCONF=11
      NSTR=9
      NCT=1
      N=NCONF
  210 ID=NCONF*NCT 
      II=ID-NCONF+1
      JJ=NCONF-1
      DO I=II,ID 
      J=NCONF-JJ 
      X(J)=XX(I) 
      Y(J)=U(I)
      JJ=JJ-1
      ENDDO
      CALL SOLV(N) 
      IC=1
      DO I=II,ID 
      UX(I)=S(IC)
      IC=IC+1
      ENDDO
      NCT=NCT+1
      IF(NCT.LE.NSTR)GO TO 210
      NCT=1
      N=NSTR
  230 IT=NCONF*(NSTR-1) 
      ID=IT+NCT
      II=ID-IT 
      JJ=NSTR-1
      DO I=II,ID,NCONF 
      J=NSTR-JJ
      X(J)=YY(I) 
      Y(J)=U(I)
      JJ=JJ-1
      ENDDO
      CALL SOLV(N) 
      IC=1
      DO I=II,ID,NCONF 
      UY(I)=S(IC)
      IC=IC+1
      ENDDO
      NCT=NCT+1
      IF(NCT.LE.NCONF)GO TO 230
      NCT=1
      N=NCONF
  243 ID=NCONF*NCT 
      II=ID-NCONF+1
      JJ=NCONF-1
      DO I=II,ID 
      J=NCONF-JJ 
      X(J)=XX(I) 
      Y(J)=UY(I)
      JJ=JJ-1
      ENDDO
      CALL SOLV(N) 
      IC=1
      DO I=II,ID 
      UXY(I)=S(IC)
      IC=IC+1
      ENDDO
      NCT=NCT+1
      IF(NCT.LE.NSTR)GO TO 243
      RETURN 
  300 FORMAT(I5,F15.5) 
      END
C 
C******************************************************************* 
C
      SUBROUTINE SOLV(N) 
      COMMON/SPLIN/X(100),Y(100),S(100)
      DIMENSION A(100),B(100),C(100),D(100),F(100),GG(100),H(100) 
      N1=N-1
      DO I=2,N
      H(I)=X(I)-X(I-1)
      ENDDO
      DO I=2,N
      A(I)=1./H(I) 
      ENDDO
      A(1)=0.
      DO I=2,N1
      T1=1./H(I)+1./H(I+1)
      B(I)=2.*T1
      ENDDO
      B(1)=2.*(1./H(2)) 
      B(N)=2.*(1./H(N)) 
      DO I=1,N1
      C(I)=1./H(I+1) 
      ENDDO
      C(N)=0.
      DO I=2,N1
      T1=(Y(I)-Y(I-1))/(H(I)*H(I)) 
      T2=(Y(I+1)-Y(I))/(H(I+1)*H(I+1))
      D(I)=3.*(T1+T2)
      ENDDO
      T1=(Y(2)-Y(1))/(H(2)*H(2)) 
      D(1)=3.*T1
      T2=(Y(N)-Y(N-1))/(H(N)*H(N)) 
      D(N)=3.*T2     
C	FORWARD PASS 
      GG(1)=C(1)/B(1) 
      DO I=2,N1
      T1=B(I)-A(I)*GG(I-1)
      GG(I)=C(I)/T1
      ENDDO
      F(1)=D(1)/B(1) 
      DO I=2,N 
      TEM=D(I)-A(I)*F(I-1) 
      T1=B(I)-A(I)*GG(I-1)
      F(I)=TEM/T1
      ENDDO
C	BACK SOLUTION 
      S(N)=F(N)
      I=N-1
 2120 S(I)=F(I)-GG(I)*S(I+1) 
      IF(I.EQ.1) GOTO 2150
      I=I-1
      GO TO 2120
 2150 CONTINUE 
      RETURN 
      END
C 
C*******************************************************************
C
      SUBROUTINE BICUBE(UC,EC,S3) 
      DIMENSION XX(100),YY(100),U(100) 
      COMMON/SPL/XX,YY,U 
      COMMON/BICUB/UX(100),UY(100),UXY(100) 
      DIMENSION H(16),KE(100,4)
      DATA((KE(K,I),I=1,4),K=1,10)/1,2,13,12,2,3,14,13,3,4,15,14,4,5,16,
     115,5,6,17,16,6,7,18,17,7,8,19,18,8,9,20,19,9,10,21,20,10,11,22,21/ 
      DATA((KE(K,I),I=1,4),K=11,20)/12,13,24,23,13,14,25,24,14,15,26,25,
     115,16,27,26,16,17,28,27,17,18,29,28,18,19,30,29,19,20,31,30,20,21,
     232,31,21,22,33,32/ 
      DATA((KE(K,I),I=1,4),K=21,30)/23,24,35,34,24,25,36,35,25,26,37,36,
     126,27,38,37,27,28,39,38,28,29,40,39,29,30,41,40,30,31,42,41,31,32,
     243,42,32,33,44,43/ 
      DATA((KE(K,I),I=1,4),K=31,40)/34,35,46,45,35,36,47,46,36,37,48,47,
     137,38,49,48,38,39,50,49,39,40,51,50,40,41,52,51,41,42,53,52,42,43,
     254,53,43,44,55,54/ 
      DATA((KE(K,I),I=1,4),K=41,50)/45,46,57,56,46,47,58,57,47,48,59,58,
     148,49,60,59,49,50,61,60,50,51,62,61,51,52,63,62,52,53,64,63,53,54,
     265,64,54,55,66,65/ 
      DATA((KE(K,I),I=1,4),K=51,60)/56,57,68,67,57,58,69,68,58,59,70,69,
     159,60,71,70,60,61,72,71,61,62,73,72,62,63,74,73,63,64,75,74,64,65,
     276,75,65,66,77,76/ 
      DATA((KE(K,I),I=1,4),K=61,70)/67,68,79,78,68,69,80,79,69,70,81,80,
     170,71,82,81,71,72,83,82,72,73,84,83,73,74,85,84,74,75,86,85,75,76,
     287,86,76,77,88,87/ 
      DATA((KE(K,I),I=1,4),K=71,80)/78,79,90,89,79,80,91,90,80,81,92,91,
     181,82,93,92,82,83,94,93,83,84,95,94,84,85,96,95,85,86,97,96,86,87,
     298,97,87,88,99,98/ 
      DO 400 M=1,80
      I=KE(M,1) 
      J=KE(M,2) 
      K=KE(M,3) 
      L=KE(M,4)
      IF(S3.GE.XX(I).AND.S3.LE.XX(J))GOTO 410
      GOTO 400
  410 IF(EC.GE.YY(I).AND.EC.LE.YY(L))GOTO 420
  400 CONTINUE
  420 CONTINUE 
      AA=XX(J)-XX(I) 
      BB=YY(L)-YY(I) 
      S3N=S3-XX(I) 
      ECN=EC-YY(I) 
      SL=S3N/AA 
      T=ECN/BB 
      S2=SL*SL 
      S3=SL*SL*SL 
      T2=T*T
      T3=T2*T
      F1=1.-3.*S2+2.*S3
      F2=S2*(3.-2.*SL) 
      F3=AA*SL*(1.-SL)*(1.-SL) 
      F4=AA*S2*(SL-1.)
      DO 430 KJ=1,2
      G1=1.-3.*T2+2.*T3
      G2=T2*(3.-2.*T) 
      G3=BB*T*(1.-T)*(1.-T) 
      G4=BB*T2-2.*T 
      H(1)=F1*G1*U(I) 
      H(2)=F2*G1*U(J)
      H(3)=F2*G2*U(K) 
      H(4)=F1*G2*U(L) 
      H(5)=F3*G1*UX(I) 
      H(6)=F4*G1*UX(J) 
      H(7)=F4*G2*UX(K) 
      H(8)=F3*G2*UX(L) 
      H(9)=F1*G3*UY(I) 
      H(10)=F2*G3*UY(J) 
      H(11)=F2*G4*UY(K) 
      H(12)=F1*G4*UY(L) 
      H(13)=F3*G3*UXY(I) 
      H(14)=F4*G4*UXY(J) 
      H(15)=F4*G4*UXY(K) 
      H(16)=F3*G4*UXY(L) 
      UC=0.0
      DO KK=1,16
      UC=UC+H(KK)
      ENDDO
  430 CONTINUE 
      RETURN 
      END
C
C*******************************************************************
C
      SUBROUTINE SCHMERT(Q,NMAT,DGWT,BWID,PP,NBPRES,JOPT) 
      PARAMETER(NL=30,NQ=101) 
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT 
      DIMENSION QC(NL),PP(NQ)
      IF(JOPT.EQ.2)WRITE(6,5)
      IF(JOPT.EQ.4)WRITE(6,6)
      DO 10 I = 1,NMAT
      READ(5,*)M,QC(M) 
      WRITE(6,20)M,QC(M)
   10 CONTINUE
      READ(5,*)TIME
      WRITE(6,35)TIME
      NNP=NEL+1
      DELH=0.0
      DEL=0.0
      QNET=Q-PP(NBX) 
      DXX=DX*FLOAT(NBX) - DX/2. 
      C1=1 - 0.5*PP(NBX)/QNET 
      IF(C1.LT.0.5) C1=0.5
      FF=TIME/0.1
      CT=1+0.2*ALOG10(FF) 
      IF(NOUT.EQ.0) GOTO 40
      WRITE(6,25)
   40 DO 300 I=NBX,NEL 
      MTYP=IE(I,1) 
      PR1=(PP(I+1)+PP(I))/2. 
      ESI=QC(MTYP)
      IF(NBPRES.EQ.1.AND.JOPT.EQ.2)ESI=2.5*QC(MTYP) 
      IF(NBPRES.EQ.2.AND.JOPT.EQ.2)ESI=3.5*QC(MTYP) 
      IF(NBPRES.EQ.2) GOTO 100
      ANN=0.5*BWID/DX + DX*FLOAT(NBX-1) 
      NN=IFIX(ANN)
      SIGM=PR1
      AIZP=0.5+0.1*(QNET/SIGM)**0.5
      DEPT=DXX-FLOAT(NBX-1)*DX 
      AIZ=0.1+(AIZP-0.1)*DEPT/(0.5*BWID) 
      IF(DEPT.GT.0.5*BWID)AIZ=AIZP+AIZP/3.0-AIZP*DEPT/(1.5*BWID) 
      IF(DEPT.GT.2*BWID)AIZ=0.0
      GOTO 200
  100 ANN=BWID/DX + DX*FLOAT(NBX-1) 
      NN=IFIX(ANN)
      SIGM=PR1
      AIZP=0.5+0.1*(QNET/SIGM)**0.5
      DEPT=DXX-FLOAT(NBX-1)*DX 
      AIZ=0.2+(AIZP-0.2)*DEPT/BWID 
      IF(DEPT.GT.BWID)AIZ=AIZP+AIZP/3.-AIZP*DEPT/(3.*BWID) 
      IF(DEPT.GT.4*BWID)AIZ=0.0
  200 DEL=-C1*CT*QNET*AIZ*DX/ESI 
      DELH=DELH+DEL 
      IF(NOUT.EQ.1)WRITE(6,310)I,DXX,DEL 
      DXX=DXX+DX
  300 CONTINUE
      WRITE(6,320) DELH
      RETURN
    5 FORMAT(/,1X,'MATERIAL	CONE RESISTANCE, TSF',/) 
    6 FORMAT(/,1X,'MATERIAL	ELASTIC MODULUS, TSF',/) 
   15 FORMAT(I5,F10.2)
   20 FORMAT(I5,F18.2) 
   30 FORMAT(F10.2) 
   35 FORMAT(/,1X,'TIME AFTER CONSTRUCTION IN YEARS=',F10.2,/) 
   25 FORMAT(/,1X,'ELEMENT	DEPTH, FT   SETTLEMENT, FT ',/)
  310 FORMAT(I5,F13.2,F18.5) 
  320 FORMAT(/,1X,'SETTLEMENT BENEATH FOUNDATION=',F10.5,'     FEET',/) 
      END
C
C*******************************************************************
C
      SUBROUTINE COLL(NMAT) 
      PARAMETER(NL=30,NQ=101) 
      COMMON/SLA/P(NQ),IE(NQ,1),EO(NL),DX,NBX,NEL,PII,NOUT 
      DIMENSION PRES(NL,5),STRA(NL,5)
      WRITE(6,5)
      DO 10 I = 1,NMAT
      READ(5,*) M,(PRES(M,J),J=1,5) 
      WRITE(6,11)M,(PRES(M,J),J=1,5)
   10 CONTINUE
      WRITE(6,15)
      DO 20 I=1,NMAT
      READ(5,*) M,(STRA(M,J),J=1,5) 
      WRITE(6,21)M,(STRA(M,J),J=1,5) 
      DO 19 K=1,5
      STRA(M,K) = STRA(M,K)/100.
   19 CONTINUE
   20 CONTINUE
      DELH1=0.0
      DXX=DX/2. 
      IF(NBX.EQ.1) GOTO 50
      IF(NOUT.EQ.0) GOTO 50
      WRITE(6,32)
      DO 40 I=1,NBX-1
      MTY=IE(I,1) 
      PR=(P(I)+P(I+1))/2. 
      PRA=PRES(MTY,2)/PRES(MTY,1) 
      PRB=PRES(MTY,3)/PRES(MTY,2) 
      PRC=PRES(MTY,4)/PRES(MTY,1) 
      PRD=PRES(MTY,5)/PRES(MTY,4) 
      PRE=PRES(MTY,1)/PR 
      PRF=PRES(MTY,2)/PR 
      PRG=PRES(MTY,4)/PR
      SA=(STRA(MTY,2)-STRA(MTY,1))/ALOG10(PRA) 
      SB=(STRA(MTY,3)-STRA(MTY,2))/ALOG10(PRB) 
      SC=(STRA(MTY,4)-STRA(MTY,1))/ALOG10(PRC) 
      SD=(STRA(MTY,5)-STRA(MTY,4))/ALOG10(PRD) 
      IF(PR.LE.PRES(MTY,2))DEB=-STRA(MTY,1)+SA*ALOG10(PRE) 
      IF(PR.GT.PRES(MTY,2))DEB=-STRA(MTY,2)+SB*ALOG10(PRF) 
      IF(PR.LE.PRES(MTY,4))DEA=-STRA(MTY,1)+SC*ALOG10(PRE) 
      IF(PR.GT.PRES(MTY,4))DEA=-STRA(MTY,4)+SD*ALOG10(PRG) 
      DEL=DEA-DEB
      IF(NOUT.EQ.0) GOTO 36
      WRITE(6,110) I,DXX,DEL
   36 DELH1=DELH1+DX*DEL 
      DXX=DXX+DX
   40 CONTINUE
   50 DELH2=0.0
      IF(NBX.GT.NEL) GOTO 120
      DXX=FLOAT(NBX)*DX-DX/2. 
      IF(NOUT.EQ.0) GOTO 65
      WRITE(6,60)
   65 DO 100 I=NBX,NEL
      MTY=IE(I,1) 
      PR=(P(I)+P(I+1))/2. 
      PRA=PRES(MTY,2)/PRES(MTY,1) 
      PRB=PRES(MTY,3)/PRES(MTY,2) 
      PRC=PRES(MTY,4)/PRES(MTY,1) 
      PRD=PRES(MTY,5)/PRES(MTY,4) 
      PRE=PRES(MTY,1)/PR 
      PRF=PRES(MTY,2)/PR 
      PRG=PRES(MTY,4)/PR
      SA=(STRA(MTY,2)-STRA(MTY,1))/ALOG10(PRA) 
      SB=(STRA(MTY,3)-STRA(MTY,2))/ALOG10(PRB) 
      SC=(STRA(MTY,4)-STRA(MTY,1))/ALOG10(PRC) 
      SD=(STRA(MTY,5)-STRA(MTY,4))/ALOG10(PRD) 
      IF(PR.LE.PRES(MTY,2))DEB=-STRA(MTY,1)+SA*ALOG10(PRE) 
      IF(PR.GT.PRES(MTY,2))DEB=-STRA(MTY,2)+SB*ALOG10(PRF) 
      IF(PR.LE.PRES(MTY,4))DEA=-STRA(MTY,1)+SC*ALOG10(PRE) 
      IF(PR.GT.PRES(MTY,4))DEA=-STRA(MTY,4)+SD*ALOG10(PRG) 
      DEL=DEA-DEB
      IF(NOUT.EQ.0) GOTO 80
      WRITE(6,110) I,DXX,DEL
   80 DELH2=DELH2+DX*DEL 
      DXX=DXX+DX
  100 CONTINUE
      DEL1=DELH1+DELH2
      WRITE(6,305) DELH1,DELH2,DEL1
  120 RETURN 
    5 FORMAT(/,10X,'APPLIED PRESSURE AT 5 POINTS IN UNITS OF TSF',/,1X,'
     1MATERIAL	A	BB	B	C	D',/) 
   11 FORMAT(I5,5F10.2)
   15 FORMAT(/,10X,'STRAIN AT 5 POINTS IN PERCENT',/1X,'MATERIAL	A
     1	         BB	B	C	D',/)
   21 FORMAT(I5,5F10.2) 
   32 FORMAT(/,1X,'COLLAPSE DISTRIBUTION ABOVE FOUNDATION DEPTH',/,1X,'E
     1LEMENT	DEPTH,FT	DELTA,FT',/) 
   60 FORMAT(/,1X,'COLLAPSE DISTRIBUTION BELOW FOUNDATION',/,1X,'ELEMENT
     1	 DEPTH,FT	DELTA,FT',/)
  110 FORMAT(I5,F13.2,F18.5) 
  305 FORMAT(/,1X,'SOIL COLLAPSE NEXT TO FOUNDATION EXCLUDING COLLAPSE',
     1/,1X,'IN SUBSOIL BENEATH FOUNDATION =',F10.5,' FEET',/,1X,'SUBSOIL
     2 COLLAPSE =',F10.5,' FEET',/,1X,'TOTAL COLLAPSE =',F10.5,' FEET')
      END
      
