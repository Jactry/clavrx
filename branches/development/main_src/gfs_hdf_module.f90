!  $Id: gfs_hdf_module.f90,v 1.11.2.2 2014/01/26 04:48:33 heidinger Exp $
!--------------------------------------------------------------------------------------
! Clouds from AVHRR Extended (CLAVR-x) 1b PROCESSING SOFTWARE Version 5.3
!
! NAME: gfs_hdf_module.f90 (src)
!       GFS (program)
!
! PURPOSE: This module houses all of the routines used to read and process the
!          GFS NWP data.  
!
! DESCRIPTION: The data used here are already in hdf format from the
!              convert_grib_to_hdf utility.  
!
! AUTHORS:
!  Andrew Heidinger, Andrew.Heidinger@noaa.gov
!  Andi Walther, CIMSS, andi.walther@ssec.wisc.edu
!  Denis Botambekov, CIMSS, denis.botambekov@ssec.wisc.edu
!  William Straka, CIMSS, wstraka@ssec.wisc.edu
!
! COPYRIGHT
!
! (c) This code is copyrighted by the author and all NOAA restrictions apply
!
! Dependencies:
!  CONSTANTS
!  NUMERICAL_ROUTINES
!  Sort_Module
!  NWP_COMMON
!  HDF
!
! Calling Sequence:
!  use GFS
!
! Public Routines within this module:
!  READ_GFS_DATA
!--------------------------------------------------------------------------------------
module GFS
  use CONSTANTS
  use NUMERICAL_ROUTINES
  use Sort_Module
  use NWP_COMMON
  use HDF

  implicit none

  public:: READ_GFS_DATA
  private:: READ_DATA_2D
  private:: READ_DATA_3D

  real (kind=real4), parameter, private :: Missing_Gfs = 9.999E+20

   character(len=11), parameter:: MODULE_PROMPT = "GFS_MODULE:"
contains

!-------------------------------------------------------------
! Subroutine to read in GFS data
!-------------------------------------------------------------
  subroutine READ_GFS_DATA(Nwp_Data_Type, &
                           start_year, &
                           start_jday, &
                           start_itime,&
                           end_year,   &
                           end_jday,   &
                           end_itime,  &
                           Nwp_Path,   &
                           Ierror_Nwp)

!-------------------------------------------------------------
!   Local declarations
!-------------------------------------------------------------

!   Arguments
    integer(kind=int4), intent(in) :: Nwp_Data_Type
    character (len=*), intent(in) :: Nwp_Path
    integer(kind=int2), intent(in) :: start_year, start_jday, end_year, end_jday
    integer(kind=int4), intent(in) :: start_itime, end_itime
    integer, intent(out):: Ierror_Nwp
    integer :: year, jday

!   Parameters
    real, parameter :: Missing_value = -9.999E+20

!   Local variables
    character (len=120) :: Nwp_Name_Before
    character (len=120) :: Nwp_Name_After
    character (len=2)   :: Year_string, Hour_string, Day_string, Month_string
    character (len=3)   :: array_order_1, array_order_2 
    character (len=4)   :: Year_string_full

    logical :: file_exists

    integer :: year2d, ileap_After, ileap_Before, ileap_this_year, ileap_prev_year
    integer :: Month_Before, Day_Before, JDay_Before, Year_Before, Hour_Before
    integer :: Month_After,  Day_After,  JDay_After,  Year_After,  Hour_After
    integer :: i, j, ii, jj

    real :: time,start_time, x

    integer:: Nlevels, Nlevels_o3mr, Nlevels_rh, Nlevels_clwmr, Nlat_Gfs, Nlon_Gfs
    real:: Dlat_Gfs, Dlon_Gfs, lat1_Gfs, lon1_Gfs

!-- values used for hdf reading
integer:: sd_id_1,sd_id_2,sds_id, Istatus
integer, parameter:: sds_rank_1d = 1, sds_rank_2d = 2, sds_rank_3d = 3
integer, dimension(sds_rank_1d):: sds_start_1d, sds_stride_1d, sds_edges_1d
integer, dimension(sds_rank_2d):: sds_start_2d, sds_stride_2d, sds_edges_2d
integer, dimension(sds_rank_3d):: sds_start_3d, sds_stride_3d, sds_edges_3d

! HDF function declarations
 integer:: sfstart, sfendacc, sfend, &
           hishdff, sfselect, sfrdata, sfn2index, &
           sffattr, sfrnatt, sfrcatt



    !-- check Nwp_Data_Type
    if (Nwp_Data_Type /= 1 .and. Nwp_Data_Type /= 3 .and. Nwp_Data_Type /=4) then
       print *, EXE_PROMPT, MODULE_PROMPT, " ERROR: unsupported NWP data in GFS read module, stopping"
       stop 
    endif

    !--   Initializations
    Ierror_Nwp = 0
    Nlat_Gfs   = -1
    Nlon_Gfs   = -1

    Missing_Nwp = Missing_Gfs

    !--- compute mean orbit time and account for orbiting end after midnight
    start_time = (start_itime)/60.0/60.0/1000.0
 
    time = 0.5*(start_itime + end_itime)/60.0/60.0/1000.0

    if (time < start_time) then
      time = time + 12.0
    endif

    if (time <= 24.00) then
      jday =  start_jday
      year =  start_year
    else
      jday =  end_jday
      year =  end_year
      time = time - 24.0
    endif

    !------ determine if this year is a leap year
    ileap_this_year = 0
    ileap_this_year = leap_Year_fct(year)

    ileap_prev_year = 0
    ileap_prev_year = leap_Year_fct(year-1)

    !---------------------------------------------------------------
    !   Pick forecasts that surround this observation time
    !---------------------------------------------------------------
    if ((time >= 0.00) .and. (time < 6.00)) then
       if (Nwp_Data_Type == 1) then                  !12 hour forecasts
        JDay_Before = jday - 1
        Hour_Before = 12
        JDay_After = jday - 1
        Hour_After = 18
       elseif(Nwp_Data_Type == 3) then               !6 hour forecasts
        JDay_Before = jday - 1
        Hour_Before = 18
        JDay_After = jday
        Hour_After = 0
       elseif(Nwp_Data_Type == 4) then               !0 hour forecasts
        JDay_Before = jday
        Hour_Before = 0
        JDay_After = jday
        Hour_After = 6
       endif

    elseif ((time >= 6.00) .and. (time < 12.00)) then
       if (Nwp_Data_Type == 1) then
        JDay_Before = jday -1
        Hour_Before = 18
        JDay_After = jday
        Hour_After = 0
       elseif(Nwp_Data_Type == 3) then
        JDay_Before = jday
        Hour_Before = 0
        JDay_After = jday
        Hour_After = 6
       elseif(Nwp_Data_Type == 4) then
        JDay_Before = jday
        Hour_Before = 6
        JDay_After = jday
        Hour_After = 12 
       endif

    elseif ((time >= 12.00) .and. (time < 18.00)) then
       if (Nwp_Data_Type == 1) then
        JDay_Before = jday
        Hour_Before = 0
        JDay_After = jday
        Hour_After = 6
       elseif(Nwp_Data_Type == 3) then
        JDay_Before = jday
        Hour_Before = 6
        JDay_After = jday
        Hour_After = 12
       elseif(Nwp_Data_Type == 4) then
        JDay_Before = jday
        Hour_Before = 12
        JDay_After = jday
        Hour_After = 18
       endif

    elseif ((time >= 18.00) .and. (time < 24.00)) then
       if (Nwp_Data_Type == 1) then
        JDay_Before = jday
        Hour_Before = 6
        JDay_After = jday
        Hour_After = 12
       elseif(Nwp_Data_Type == 3) then
        JDay_Before = jday
        Hour_Before = 12
        JDay_After = jday
        Hour_After = 18
       elseif(Nwp_Data_Type == 4) then
        JDay_Before = jday
        Hour_Before = 18
        JDay_After = jday+1
        Hour_After = 0
       endif

    else
       print *, EXE_PROMPT, MODULE_PROMPT, " ERROR: Invalid time for forecast, stopping ", time
       Ierror_Nwp = 1
       stop 401
    endif

    !   Adjust year if necessary
    Year_Before = year
    Year_After = year
    ileap_After = ileap_this_year
    ileap_Before = ileap_this_year
    if (JDay_Before < 1) then
       ileap_Before = ileap_prev_year
       Year_Before = year -1
       JDay_Before = 365 + ileap_Before
    endif

    !   Compute weight of each forecast to this time
    !   values near one mean you are close to time of the "after" file
    !   values near zero mean you are close to time of the "before" file
    x = (time - 6.0*int(time/6.0))/6.0
    x = min(1.0,max(0.0,x))

!--------------------------------------------------------------------
!   Construct file name for forecast valid before obs time
!--------------------------------------------------------------------

    !--- Compute month and day of month from year and Julian day
    Month_Before = COMPUTE_MONTH(JDay_Before,ileap_Before)
    Day_Before = COMPUTE_DAY(JDay_Before,ileap_Before)

    !--- File name
    year2d = Year_Before - 100*int(year/100)      !two digit year
    write (Year_string_full,  '(I4.4)') Year_Before
    write (Year_string,  '(I2.2)') year2d
    write (Hour_string,  '(I2.2)') Hour_Before
    write (Month_string, '(I2.2)') Month_Before
    write (Day_string,   '(I2.2)') Day_Before

    if (Nwp_Data_Type == 1) then
          Nwp_Name_Before = trim(Nwp_Path) //  &
                       "gfs." // Year_string // Month_string // &
                       Day_string // Hour_string // "_F012.hdf"
    elseif (Nwp_Data_Type == 4) then
          Nwp_Name_Before = trim(Nwp_Path) //  &
                       "gdas." // Year_string // Month_string // &
                       Day_string // Hour_string // "_F000.hdf"    
    else
          Nwp_Name_Before = trim(Nwp_Path) //"/"//Year_string_full//"/"//  &
                       "cfsr." // Year_string // Month_string // &
                       Day_string // Hour_string // "_F006.hdf"
    endif

!---------------------------------------------------------------------
! Construct file name for forecast valid after obs time
!---------------------------------------------------------------------

!--- Compute month and day of month from year and Julian day
    Month_After= COMPUTE_MONTH(JDay_After,ileap_After)
    Day_After = COMPUTE_DAY(JDay_After,ileap_After)

!--- File name
    year2d = Year_After - 100*int(year/100)      !two digit year
    write (Year_string_full,  '(I4.4)') Year_After
    write (Year_string,  '(I2.2)') year2d
    write (Hour_string,  '(I2.2)') Hour_After
    write (Month_string, '(I2.2)') Month_After
    write (Day_string,   '(I2.2)') Day_After

    if (Nwp_Data_Type == 1) then
          Nwp_Name_After = trim(Nwp_Path)// &
                       "gfs."//Year_string//Month_string// &
                       Day_string//Hour_string//"_F012.hdf"
    elseif (Nwp_Data_Type == 4) then
          Nwp_Name_After = trim(Nwp_Path) //  &
                       "gdas." // Year_string // Month_string // &
                       Day_string // Hour_string // "_F000.hdf"    
    else
          Nwp_Name_After = trim(Nwp_Path) //"/"//Year_string_full//"/"//  &
                       "cfsr."//Year_string//Month_string// &
                       Day_string//Hour_string//"_F006.hdf"
    endif


!--- Does before file exist?
    inquire(file = Nwp_Name_Before, exist = file_exists)
    if (.not. file_exists) then
       write (*,*) EXE_PROMPT, MODULE_PROMPT, "WARNING: Missing data file " // trim(Nwp_Name_Before)
       write (*,*) EXE_PROMPT, MODULE_PROMPT, "WARNING: Setting GFS before to GFS after"
       Nwp_Name_Before = Nwp_Name_After
       !stop 402
    endif

    print *, EXE_PROMPT, MODULE_PROMPT, " NWP name before = ", trim(Nwp_Name_Before)

!--- Does after file exist?
    inquire(file = Nwp_Name_After, exist = file_exists)
    if (.not. file_exists) then
       !--- check to see if before file was also Missing
       if (Nwp_Name_After == Nwp_Name_Before) then
           write (*,*) EXE_PROMPT, MODULE_PROMPT, "ERROR: Neither GFS data files are present, processing stopped "
           stop 403
       endif  
       write (*,*) EXE_PROMPT, MODULE_PROMPT, "WARNING: Missing data file " // trim(Nwp_Name_After)
       write (*,*) EXE_PROMPT, MODULE_PROMPT, "WARNING: Setting GFS after to GFS before"
       Nwp_Name_After = Nwp_Name_Before
    endif

    print *, EXE_PROMPT, MODULE_PROMPT, "NWP name after = ", trim(Nwp_Name_After)
!--------------------------------------------------------------
! open before file and read contents from file data before this time
!--------------------------------------------------------------
! Check if the file is of HDF type
     Istatus = hishdff(trim(Nwp_Name_Before))
     if (Istatus == 0) then
        print *, EXE_PROMPT, MODULE_PROMPT, "ERROR: Input cell file doesn't exist or is not recognized as HDF file, stopping"
        stop
     endif
   
!-- open files
     sd_id_1 = sfstart(trim(Nwp_Name_Before), DFACC_READ)
     if (sd_id_1 == FAIL) then
      print *, EXE_PROMPT, MODULE_PROMPT, "ERROR: Failed open for read on first gfs file, stopping"
      stop
     endif

     sd_id_2 = sfstart(trim(Nwp_Name_After), DFACC_READ)
     if (sd_id_2 == FAIL) then
      print *, EXE_PROMPT, MODULE_PROMPT, "ERROR: Failed open for read on second gfs file, stopping"
      stop
     endif

!---- read attributes from file 1
     Istatus = 0
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF PRESSURE LEVELS"),Nlevels) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF O3MR LEVELS"),Nlevels_o3mr) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF RH LEVELS"),Nlevels_rh) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF CLWMR LEVELS"),Nlevels_clwmr) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF LATITUDES"),Nlat_Gfs) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"NUMBER OF LONGITUDES"),Nlon_Gfs) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"LATITUDE RESOLUTION"),Dlat_Gfs) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"LONGITUDE RESOLUTION"),Dlon_Gfs) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"FIRST LATITUDE"),lat1_Gfs) + Istatus
     Istatus = sfrnatt(sd_id_1,sffattr(sd_id_1,"FIRST LONGITUDE"),lon1_Gfs) + Istatus
     Istatus = sfrcatt(sd_id_1,sffattr(sd_id_1,"3D ARRAY ORDER"), array_order_1) + Istatus

!--- don't read attributes from file 2 (assume they are the same)
     Istatus = sfrcatt(sd_id_1,sffattr(sd_id_2,"3D ARRAY ORDER"), array_order_2) + Istatus

!--- do some checking
     if (array_order_1 /= array_order_2) then 
       print *, EXE_PROMPT, MODULE_PROMPT, " ERROR: Order of 3d arrays differ among gfs files, stopping = ",  &
              array_order_1, " ", array_order_2
       stop
     endif

!--- set reformat gfs flag
     REFORMAT_GFS_ZXY = 0
     if (array_order_1 == "XYZ" ) then
       REFORMAT_GFS_ZXY = 1
     endif

!--- set up need hdf dimensions

!---- define dimensions of 1d arrays
sds_start_1d = (/ 0 /)       !should this be 1
sds_stride_1d = (/ 1 /)
sds_edges_1d = (/ Nlevels /)     !should this be nx-1,ny-1
                                                                                                                           
!---- define dimensions of 2d arrays
sds_start_2d = (/ 0, 0 /)       !should this be 1
sds_stride_2d = (/ 1, 1 /)
sds_edges_2d = (/ Nlon_Gfs, Nlat_Gfs /)     !should this be nx-1,ny-1
                                                                                                                           
!---- define dimensions of 3d arrays
sds_start_3d = (/ 0, 0, 0 /)       
sds_stride_3d = (/ 1, 1, 1 /)
sds_edges_3d = (/ Nlevels, Nlon_Gfs, Nlat_Gfs /)     
if (REFORMAT_GFS_ZXY == 1) then
  sds_edges_3d = (/ Nlon_Gfs, Nlat_Gfs, Nlevels /)    
endif

!---- store dimensions in public variables
    Nlevels_Nwp = Nlevels
    Nlat_Nwp = Nlat_Gfs
    Nlon_Nwp = Nlon_Gfs

!---- specific to GFS grid
    lat1_Nwp = lat1_Gfs
    lon1_Nwp = lon1_Gfs
    Dlon_Nwp = Dlon_Gfs
    Dlat_Nwp = sign(Dlat_Gfs,-1.0*lat1_Gfs)

!-----------------------------------------------------------------
! allocate NWP arrays
!-----------------------------------------------------------------
    call CREATE_NWP_ARRAYS()

!------------------------------------------------------------------
!   Read data from the first file
!------------------------------------------------------------------

!--- read in standard levels from first file
    Istatus = 0
    sds_id = sfselect(sd_id_1, sfn2index(sd_id_1,"pressure levels"))
    Istatus = sfrdata(sds_id, sds_start_1d, sds_stride_1d, sds_edges_1d,  &
                      P_Std_Nwp) + Istatus
    Istatus = sfendacc(sds_id) + Istatus

!--- read in two dimensional arrays

!- land mask
    call READ_DATA_2D(sd_id_1,sd_id_2,"land mask",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,temp2d_Nwp_1)
    land_Nwp = int(temp2d_Nwp_1,kind=int1)

!- ice mask
    call READ_DATA_2D(sd_id_1,sd_id_2,"ice fraction",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,ice_Nwp )

!--- read in two dimensional arrays
    call READ_DATA_2D(sd_id_1,sd_id_2,"MSL pressure",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Pmsl_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"surface pressure",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Psfc_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"surface temperature",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Tmpsfc_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"surface height",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Zsfc_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"temperature at sigma=0.995",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Tmpair_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"rh at sigma=0.995",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Rhsfc_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"water equivalent snow depth",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Weasd_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"total precipitable water",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,Tpw_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"tropopause temperature",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,T_Trop_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"tropopause pressure",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,P_Trop_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"u-wind at sigma=0.995",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,U_Wnd_10m_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"v-wind at sigma=0.995",sds_start_2d, sds_stride_2d, &
                      sds_edges_2d,x,Missing_Nwp,V_Wnd_10m_Nwp)
    call READ_DATA_2D(sd_id_1,sd_id_2,"total ozone",sds_start_2d, sds_stride_2d,sds_edges_2d,x,Missing_Nwp,ozone_Nwp)

!--- read in three dimensional arrays
    call READ_DATA_3D(sd_id_1,sd_id_2,"temperature",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,T_Prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"height",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,z_prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"u-wind",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,U_Wnd_Prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"v-wind",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,V_Wnd_Prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"o3mr",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,ozone_prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"rh",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,Rh_Prof_Nwp)
    call READ_DATA_3D(sd_id_1,sd_id_2,"clwmr",sds_start_3d, sds_stride_3d, &
                      sds_edges_3d,x,Missing_Nwp,clwmr_prof_Nwp)

!--- close file
Istatus = sfend(sd_id_1)
Istatus = sfend(sd_id_2)

!--- fix GFS bug in RH
call FIX_GFS_RH()

!--- compute UTH    - 300 to 400 mb   !--- NEED TO make this dynamic!!!!!!
do i = 1, Nlon_Nwp
 do j = 1, Nlat_Nwp
   Uth_Nwp(i,j) = sum(Rh_Prof_Nwp(10:12,i,j))/3.0
 enddo
enddo
                                                                                
!--- store 500 mb heights - note convert back to meters
hght500_Nwp = z_prof_Nwp(14,:,:) * 1000.0

!---- compute wind speed
Wnd_Spd_10m_Nwp = wind_speed(U_Wnd_10m_Nwp,V_Wnd_10m_Nwp)
Wnd_Dir_10m_Nwp = wind_direction(U_Wnd_10m_Nwp,V_Wnd_10m_Nwp)

!---- compute the 3x3 uniformity of tmpair
do i = 1, Nlon_Nwp
 ii = max(2,min(Nlon_Nwp-1,i))
 do j = 1, Nlat_Nwp
  jj = max(2,min(Nlat_Nwp-1,j))
  tmpair_uni_Nwp(i,j) = (maxval(Tmpair_Nwp(ii-1:ii+1,jj-1:jj+1)) - &
                        minval(Tmpair_Nwp(ii-1:ii+1,jj-1:jj+1)) ) / 3.0
  tmpsfc_uni_Nwp(i,j) = (maxval(Tmpsfc_Nwp(ii-1:ii+1,jj-1:jj+1)) - &
                        minval(Tmpsfc_Nwp(ii-1:ii+1,jj-1:jj+1)) ) / 3.0
 enddo
enddo


!----- check for Missing t tropopause values and set to 200 K
do i = 1, Nlon_Nwp
 do j = 1, Nlat_Nwp
    if ((T_Trop_Nwp(i,j) < 180.0).or.(T_Trop_Nwp(i,j) > 240.0)) then
       T_Trop_Nwp(i,j) = 200.0
    endif
 enddo
enddo

 end subroutine READ_GFS_DATA

!--------------------------------------------------------------------------------------------
! generic HDF4 read routines
!--------------------------------------------------------------------------------------------

!------------------------------------------------------------------------------------------
! read in the 2d dimensional data from the GFS HDF files
!------------------------------------------------------------------------------------------
subroutine READ_DATA_2D(sd_id_1,sd_id_2,sds_name,sds_start,sds_stride,sds_edges,x,Missing,temp)

  integer, intent(in):: sd_id_1, sd_id_2
  character(len=*), intent(in):: sds_name
  integer, dimension(:), intent(in):: sds_stride, sds_start, sds_edges
  real, intent(in):: x, Missing
  real, dimension(:,:), intent(out):: temp

  integer:: sds_id_1,sds_id_2,Istatus_1,Istatus_2
  integer:: i1,i2,ndim1,ndim2

! HDF function declarations
 integer:: sfendacc, &
           sfselect, sfrdata, sfn2index


    Istatus_1 = 0
    Istatus_2 = 0

!--- open sds's
    sds_id_1 = sfselect(sd_id_1, sfn2index(sd_id_1,sds_name)) 
    sds_id_2 = sfselect(sd_id_2, sfn2index(sd_id_2,sds_name)) 

!--- read sds's
    Istatus_1 = sfrdata(sds_id_1, sds_start, sds_stride, sds_edges, temp2d_Nwp_1) + Istatus_1
    Istatus_2 = sfrdata(sds_id_2, sds_start, sds_stride, sds_edges, temp2d_Nwp_2) + Istatus_2

!--- interpolate
    ndim1 = size(temp,1)
    ndim2 = size(temp,2)
    do i1 = 1, ndim1
      do i2 = 1, ndim2
          if ((temp2d_Nwp_1(i1,i2) /= Missing) .and. (temp2d_Nwp_2(i1,i2) /= Missing)) then
           temp(i1,i2) = (1.0 - x) * temp2d_Nwp_1(i1,i2)   + x * temp2d_Nwp_2(i1,i2)
          else
           temp(i1,i2) = Missing_Nwp
          endif
      enddo
    enddo

!--- close sds's
    Istatus_1 = sfendacc(sds_id_1) + Istatus_1
    Istatus_2 = sfendacc(sds_id_2) + Istatus_2

!--- check for success
    if ((Istatus_1 < 0) .or. (Istatus_2 < 0)) then
        print *, EXE_PROMPT, MODULE_PROMPT, " WARNING: sds ",sds_name," not read in successfully from gfs files, setting to Missing"
        temp = Missing_Nwp

        !--- check if missing data is critical to further processing
        if (sds_name == "surface temperature" .or. sds_name == "surface height" .or.  &
            sds_name == "surface height") then
         print *, EXE_PROMPT, MODULE_PROMPT, " ERROR: critical 2d nwp sds missing, program stopping"
         stop 
        endif

    endif


end subroutine READ_DATA_2D

!------------------------------------------------------------------------------------------
! read in the 3d dimensional data from the GFS HDF files
!------------------------------------------------------------------------------------------
subroutine READ_DATA_3D(sd_id_1,sd_id_2,sds_name,sds_start,sds_stride,sds_edges,x,Missing,temp)

  integer, intent(in):: sd_id_1, sd_id_2
  character(len=*), intent(in):: sds_name
  integer, dimension(:), intent(in):: sds_stride, sds_start, sds_edges
  real, intent(in):: x, Missing
  real, dimension(:,:,:), intent(out):: temp
  integer:: sds_id_1,sds_id_2,Istatus_1,Istatus_2
  integer:: i1,i2,i3,ndim1,ndim2,ndim3

! HDF function declarations
 integer:: sfendacc, &
           sfselect, &
           sfrdata,  &
           sfn2index

    Istatus_1 = 0
    Istatus_2 = 0

    !--- interpolate
    ndim1 = size(temp,1)
    ndim2 = size(temp,2)
    ndim3 = size(temp,3)
    
    !--- open sds's
    sds_id_1 = sfselect(sd_id_1, sfn2index(sd_id_1,sds_name))
    sds_id_2 = sfselect(sd_id_2, sfn2index(sd_id_2,sds_name))

    !--- read sds from first time
    Istatus_1 = sfrdata(sds_id_1, sds_start, sds_stride, sds_edges, temp3d) + Istatus_1

    if (REFORMAT_GFS_ZXY == 1) then
      do i1 = 1,ndim1 
         temp3d_Nwp_1(i1,:,:) = temp3d(:,:,i1)  
      enddo
    else 
      temp3d_Nwp_1 = temp3d
    endif

    !--- read sds from second time
    Istatus_2 = sfrdata(sds_id_2, sds_start, sds_stride, sds_edges, temp3d) + Istatus_2

    if (REFORMAT_GFS_ZXY == 1) then
      do i1 = 1,ndim1 
         temp3d_Nwp_2(i1,:,:) = temp3d(:,:,i1)  
      enddo
    else 
      temp3d_Nwp_2 = temp3d
    endif

!-- note this where state is seg-faulting (replaced with equivalent do/if construct)
!   where ((temp3d_Nwp_1 == Missing) .or. (temp3d_Nwp_2 == Missing))
!      temp   = Missing_Nwp
!   elsewhere
!      temp   = (1.0 - x) * temp3d_Nwp_1   + x * temp3d_Nwp_2
!   endwhere
!----------------------------------------------------------------

    do i1 = 1, ndim1
      do i2 = 1, ndim2
        do i3 = 1, ndim3
          if ((temp3d_Nwp_1(i1,i2,i3) /= Missing) .and. (temp3d_Nwp_2(i1,i2,i3) /= Missing)) then
           temp(i1,i2,i3) = (1.0 - x) * temp3d_Nwp_1(i1,i2,i3)   + x * temp3d_Nwp_2(i1,i2,i3)
          else
           temp(i1,i2,i3) = Missing_Nwp
          endif
        enddo
      enddo
    enddo
            
!--- close sds's
    Istatus_1 = sfendacc(sds_id_1) + Istatus_1
    Istatus_2 = sfendacc(sds_id_2) + Istatus_2
                                                                                                                                                                                              
!--- check for success
    if ((Istatus_1 /= 0).or.(Istatus_2 /= 0)) then
        print *, EXE_PROMPT, MODULE_PROMPT, " WARNING: sds ",sds_name," not read in successfully from gfs files, setting to Missing"
        temp = Missing_Nwp

        !--- check if missing data is critical to further processing
        if (sds_name == "temperature" .or. sds_name == "height" .or. sds_name == "rh") then
         print *, EXE_PROMPT, MODULE_PROMPT, " ERROR: critical 3d nwp sds missing, program stopping"
         stop 
        endif

    endif

end subroutine READ_DATA_3D

!---------------------------------------------------------------------
! Fix GFS RH scaling
!
! In the current GFS output, the definition of RH varies between
! 253 and 273 K.  At 273 it is with respect to water. 
! At 253 it is defined with respect to ice.  
! At temperatures in between, it varies linearly.
! This routine attempts to define RH with respect to water for all temps
!---------------------------------------------------------------------
subroutine FIX_GFS_RH()

   integer:: i, j, k
   real:: es_water
   real:: es_ice
   real:: e
   real:: es
   real:: ice_weight

   do i = 1, Nlon_Nwp
      do j = 1, Nlat_Nwp

       do k = 1, Nlevels_Nwp
          if (Rh_Prof_Nwp(k,i,j) > 0.0) then

           !--- compute saturation vapor pressures
           es_water = VAPOR(T_Prof_Nwp(k,i,j))
           es_ice = VAPOR_ICE(T_Prof_Nwp(k,i,j))

           !--- derive the ice/water weight used in gfs
           ice_weight = (273.16 - T_Prof_Nwp(k,i,j)) / &
                       (273.16-253.16)
           ice_weight = min(1.0,max(0.0,ice_weight))

           !--- derive es used in original rh definition
           es = ice_weight * es_ice + (1.0-ice_weight)*es_water

           !--- compute actual e 
           e = Rh_Prof_Nwp(k,i,j) * es / 100.0

           !--- compute actual rh with respect to water
           Rh_Prof_Nwp(k,i,j) = 100.0 * e / es_water

          endif
       enddo

      enddo
   enddo

end subroutine FIX_GFS_RH

end module GFS
