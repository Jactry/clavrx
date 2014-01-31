c$Id: tranmts101.f,v 1.6.2.2 2014/01/26 04:51:39 heidinger Exp $
c--------------------------------------------------------------------------
c Clouds from AVHRR Extended (CLAVR-x) 1b PROCESSING SOFTWARE Version 5.3
c
c NAME: tranmts101.f (src)
c
c PURPOSE: 
c * Transmittance for MTSAT at 101 levels
c
c DESCRIPTION:  (see below)
c
c AUTHORS:
c  Andrew Heidinger, Andrew.Heidinger@noaa.gov
c  Andi Walther, CIMSS, andi.walther@ssec.wisc.edu
c  Denis Botambekov, CIMSS, denis.botambekov@ssec.wisc.edu
c  William Straka, CIMSS, wstraka@ssec.wisc.edu
c
c COPYRIGHT
c THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
c DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
c FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
c INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
c EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
c DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
c THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
c SUPPORT TO USERS.
c
c--------------------------------------------------------------------------
        subroutine tranmts101(ancil_data_path,temp,wvmr,ozmr,theta,
     &                       isat,kan,taut,*)
c * Transmittance for MTSAT at 101 levels
c .... version of 20.08.07

c * LarrabeeStrow/HalWoolf/PaulVanDelst regression model based on
c *        LBLRTM line-by-line transmittances.
c * Input temperatures, and water-vapor and ozone mixing ratios, must
c *        be defined at the 101 pressure levels in array 'pstd' (see block
c *        data 'reference_atmosphere').
c * Units: temperature, deg-K; water vapor, g/kg; ozone, ppmv.
c * Logical unit numbers 71-75 are used for coefficient files.

c * Input
c        temp = profile of temperature ........ degK
c        wvmr = profile of H2O mixing ratio ... g/kg
c        ozmr = profile of  O3 mixing ratio ... ppmv
c        theta = local zenith angle ............ deg
c        isat = spacecraft number ............. 1, 2
c        kan = channel number ................ 2 - 5

c * Output
c        taut = profile of total transmittance (components are returned through common)
c           * = error return in case of coefficient-file I/O trouble

      parameter (lfac=4,nk=5,nl=101,nm=nl-1,nr=5)
      parameter (nxc= 4,ncc=nxc+1,lencc=ncc*nm,lenccb=lencc*lfac)
      parameter (nxd= 8,ncd=nxd+1,lencd=ncd*nm,lencdb=lencd*lfac)
      parameter (nxo= 9,nco=nxo+1,lenco=nco*nm,lencob=lenco*lfac)
      parameter (nxl= 2,ncl=nxl+1,lencl=ncl*nm,lenclb=lencl*lfac)
      parameter (nxs=11,ncs=nxs+1,lencs=ncs*nm,lencsb=lencs*lfac)
      parameter (nxw=nxl+nxs)
      common/stdatm/pstd(nl),tstd(nl),wstd(nl),ostd(nl)
      common/taudwo/taud(nl),tauw(nl),tauo(nl)
      dimension temp(*),wvmr(*),ozmr(*),taut(*)
      dimension coefd(ncd,nm,nr),coefo(nco,nm,nr),coefc(ncc,nm,nr)
      dimension coefl(ncl,nm,nr),coefs(ncs,nm,nr),iuc(nk)
      dimension pavg(nm),tref(nm),wref(nm),oref(nm)
      dimension tavg(nm),wamt(nm),oamt(nm),secz(nm)
      dimension tauc(nl),tlas(nl),wlas(nl),olas(nl)
      dimension xdry(nxd,nm),xozo(nxo,nm),xcon(nxc,nm),xwet(nxw,nm)
   
      character*16 cfile
      character*72 ancil_data_path,pfast_path
      character*3 comp(nk)
      data comp /'dry','ozo','wco','wtl','wts'/
      integer lencf(nk)
      data lencf /lencdb,lencob,lenccb,lenclb,lencsb/
      logical newang,newatm
      data init/0/,tlas/nl*0./,wlas/nl*0./,olas/nl*0./,zlas/-999./
      integer*4 get_lun   !needed by Get_lun() call by AKH     
    
    
C        character*3 comp(nk) /'dry','ozo','wco','wtl','wts'/
C        integer*4 lencf(nk)
C        data lencf /lencdb,lencob,lenccb,lenclb,lencsb/
C        logical newang,newatm
    
C        character*72 ancil_data_path,pfast_path   
C        data init/0/,tlas/nl*0./,wlas/nl*0./,olas/nl*0./,zlas/-999./
       
    
        secant(z)=1./cos(0.01745329*z)

        cfile = 'mtsatccc_101.dat'
        pfast_path = trim(ancil_data_path)//"pfast/"


        if(init.ne.isat) then
c * define and open the coefficient files
           !iux=70             !akh commented 
           do l=1,nk
              cfile(6:8)=comp(l)
              !iux=iux+1       !akh commented 
              iux=get_lun()    !akh added
C   WCS3 - Line 55 edited to edit file name correctly
              open(iux,file=trim(pfast_path)//cfile,recl=lencf(l),
     +           access='direct',
     +           status='old',err=200)
              iuc(l)=iux
           enddo
c * read in coefficients
           koff=nr*(isat-1)
           do k=1,nr
              krec=k+koff
              read(iuc(1),rec=krec) ((coefd(i,j,k),i=1,ncd),j=1,nm)
              read(iuc(2),rec=krec) ((coefo(i,j,k),i=1,nco),j=1,nm)
              read(iuc(3),rec=krec) ((coefc(i,j,k),i=1,ncc),j=1,nm)
              read(iuc(4),rec=krec) ((coefl(i,j,k),i=1,ncl),j=1,nm)
              read(iuc(5),rec=krec) ((coefs(i,j,k),i=1,ncs),j=1,nm)
           enddo
           do l=1,nk
              close(iuc(l))
           enddo
c * initialize the reference profiles
           call conpir(pstd,tstd,wstd,ostd,nl,1,pavg,tref,wref,oref)
           init=isat
        endif

        do j=1,nl
           taud(j)=1.0
           tauw(j)=1.0
           tauc(j)=1.0
           tauo(j)=1.0
           taut(j)=1.0
        enddo
        if(kan == 1) return

        dt=0.
        dw=0.
        do=0.
        do j=1,nl
           dt=dt+abs(temp(j)-tlas(j))
           tlas(j)=temp(j)
           dw=dw+abs(wvmr(j)-wlas(j))
           wlas(j)=wvmr(j)
           do=do+abs(ozmr(j)-olas(j))
           olas(j)=ozmr(j)
        enddo
        datm=dt+dw+do
        newatm=datm.ne.0.

        if(newatm) then
           call conpir(pstd,temp,wvmr,ozmr,nl,1,pavg,tavg,wamt,oamt)
        endif

        newang=theta.ne.zlas
        if(newang) then
           zsec=secant(theta)
           do l=1,nm
              secz(l)=zsec
           enddo
           zlas=theta
        endif

        if(newang.or.newatm) then
           call calpir(tref,wref,oref,tavg,wamt,oamt,pavg,secz,
     +         nm,nxd,nxw,nxo,nxc,xdry,xwet,xozo,xcon)
        endif

        k=kan
c * dry
        call taudoc(ncd,nxd,nm,coefd(1,1,k),xdry,taud)
c * ozo
        call taudoc(nco,nxo,nm,coefo(1,1,k),xozo,tauo)
c * wet
c .. continuum
        call taudoc(ncc,nxc,nm,coefc(1,1,k),xcon,tauc)
c .. lines
        call tauwtr(ncs,ncl,nxs,nxl,nxw,nm,coefs(1,1,k),
     +                coefl(1,1,k),xwet,tauw)
        do j=1,nl
           tauw(j)=tauw(j)*tauc(j)
        enddo
c * total
        do j=1,nl
           taut(j)=taud(j)*tauo(j)*tauw(j)
        enddo
        return

200        return1
        end
