! $Id$
!--------------------------------------------------------------------------------------
! Clouds from AVHRR Extended (CLAVR-x) 1b PROCESSING SOFTWARE Version 5.3
!
! NAME: sensor_module.f90 (src)
!       SENSOR_MODULE (program)
!
! PURPOSE: This module houses routines that apply to multiple sensors
!
! DESCRIPTION: 
!
! AUTHORS:
!  Andrew Heidinger, Andrew.Heidinger@noaa.gov
!
! COPYRIGHT
! THIS SOFTWARE AND ITS DOCUMENTATION ARE CONSIDERED TO BE IN THE PUBLIC
! DOMAIN AND THUS ARE AVAILABLE FOR UNRESTRICTED PUBLIC USE. THEY ARE
! FURNISHED "AS IS." THE AUTHORS, THE UNITED STATES GOVERNMENT, ITS
! INSTRUMENTALITIES, OFFICERS, EMPLOYEES, AND AGENTS MAKE NO WARRANTY,
! EXPRESS OR IMPLIED, AS TO THE USEFULNESS OF THE SOFTWARE AND
! DOCUMENTATION FOR ANY PURPOSE. THEY ASSUME NO RESPONSIBILITY (1) FOR
! THE USE OF THE SOFTWARE AND DOCUMENTATION; OR (2) TO PROVIDE TECHNICAL
! SUPPORT TO USERS.
!
! NOTES:
! 
! Routines in this module and their purpose:
!
!  the routines are called from process_clavrx.f90 in this order
!   file_loop
!      DETECT_SENSOR_FROM_FILE()
!      SET_FILE_DIMENSIONS()
!      SET_DATA_DATE_AND_TIME()
!      READ_INSTR_CONSTANTS()
!      READ_LEVEL1B_DATA()
!       ...
!       ... 
! end loop
!--------------------------------------------------------------------------------------
module SENSOR_MODULE
   use PIXEL_COMMON, only:
   use CALIBRATION_CONSTANTS
   use ALGORITHM_CONSTANTS
   use CONSTANTS
   use FILE_UTILITY
   use AVHRR_MODULE
   use GOES_MODULE
   use MODIS_MODULE, only : &
       DETERMINE_MODIS_CLOUD_MASK_FILE &
     , READ_MODIS_INSTR_CONSTANTS &
     , READ_MODIS &
     , READ_MODIS_SIZE_ATTR &
     , DETERMINE_MODIS_GEOLOCATION_FILE &
     , READ_MODIS_TIME_ATTR

   use FY2_MODULE, only: &
      READ_FY &
    , READ_FY_INSTR_CONSTANTS

   use ABI_MODULE, only: &
      READ_ABI &
    , READ_ABI_INSTR_CONSTANTS &
    , READ_NAVIGATION_BLOCK_ABI

   use COMS_MODULE
   use IFF_CLAVRX_BRIDGE , only : &
      READ_IFF_DATA &
      , READ_IFF_VIIRS_INSTR_CONSTANTS &
      , READ_IFF_AVHRR_INSTR_CONSTANTS &
      , READ_IFF_DATE_TIME &
      , GET_IFF_DIMS_BRIDGE
   use MTSAT_MODULE
   use SEVIRI_MODULE
#ifdef HDF5LIBS
   use VIIRS_CLAVRX_BRIDGE , only : &
       READ_VIIRS_DATE_TIME &
       , READ_VIIRS_DATA &
       , GET_NUMBER_OF_SCANS_FROM_VIIRS_BRIDGE &
       , READ_VIIRS_INSTR_CONSTANTS
   use AHI_CLAVRX_BRIDGE 
   use VIIRS_NASA_READ_MODULE, only : &
       READ_VIIRS_NASA_DATE_TIME &
       , READ_VIIRS_NASA_DATA &
       , READ_NUMBER_OF_SCANS_VIIRS_NASA
#endif

   use CLAVRX_MESSAGE_MODULE
   use MVCM_READ_MODULE

   implicit none

   private
   public :: SET_DATA_DATE_AND_TIME
   public :: READ_INSTR_CONSTANTS
   public :: DETECT_SENSOR_FROM_FILE
   public :: SET_FILE_DIMENSIONS
   public :: READ_LEVEL1B_DATA 
   public :: OUTPUT_SENSOR_TO_SCREEN
   public :: OUTPUT_IMAGE_TO_SCREEN
   public :: OUTPUT_PROCESSING_LIMITS_TO_SCREEN
   

   character(24), parameter, private :: MODULE_PROMPT = " SENSOR_MODULE: "
   character(38) :: Orbit_Identifier
  
   character (len = 3), private :: string_3
   character (len = 4), private :: string_4
   character (len = 6), private :: string_6
   character (len = 7), private :: string_7
   character (len = 30), private :: string_30

   contains

   !==============================================================================
   !   Determine date and time of the data and store in image structure
   !==============================================================================
   subroutine SET_DATA_DATE_AND_TIME(AREAstr)
      
      
      use DATE_TOOLS_MOD
      
      use CX_READ_AHI_MOD, only: &
         ahi_time_from_filename
      
      type ( date_type ) :: time0_obj, time1_obj
      
      ! - this is only needed/used for AVHRR
      type (AREA_STRUCT), intent(in) :: AREAstr

      integer(kind=int4):: Start_Year_Tmp
      integer(kind=int4):: Start_Day_Tmp
      integer(kind=int4):: End_Year_Tmp
      integer(kind=int4):: End_Day_Tmp
      integer(kind=int4):: Start_Time_Tmp
      integer(kind=int4):: End_Time_Tmp
      integer(kind=int4):: Orbit_Number_Tmp
      integer(kind=int4):: Hour
      integer(kind=int4):: Minute
      integer(kind=int4):: Second
      integer :: year, doy
      !----------------------------------------------
      ! for AVHRR, this is read in with level-1b data
      !----------------------------------------------

      !----------------------------------------------
      ! for Modis, take time from file name
      !----------------------------------------------
      if (index(Sensor%Sensor_Name,'MODIS') > 0) then

         call READ_MODIS_TIME_ATTR(trim(Image%Level1b_Path), trim(Image%Level1b_Name), &
                            Image%Start_Year, Image%Start_Doy, Image%Start_Time, &
                            Image%End_Year, Image%End_Doy, Image%End_Time)
  
      end if

      !----------------------------------------------
      ! read VIIRS-NOAA time from GMTCO
      !----------------------------------------------
      if (trim(Sensor%Sensor_Name) == 'VIIRS') then
#ifdef HDF5LIBS
         call READ_VIIRS_DATE_TIME(trim(Image%Level1b_Path),trim(Image%Level1b_Name), &
                             Start_Year_Tmp,Start_Day_Tmp,Start_Time_Tmp, &
                             End_Time_Tmp,Orbit_Number_Tmp,Orbit_Identifier, &
                             End_Year_Tmp , End_Day_Tmp)
         Image%Start_Year = Start_Year_Tmp
         Image%End_Year = End_Year_Tmp
         Image%Start_Doy = Start_Day_Tmp
         Image%End_Doy = End_Day_Tmp
 
         Image%Start_Time = Start_Time_Tmp
         Image%End_Time = End_Time_Tmp
#else
         PRINT *, "No HDF5 libraries installed, stopping"
         stop
#endif
      end if 

      !----------------------------------------------
      ! read VIIRS-NASA time from VGEOM
      !----------------------------------------------
      if (trim(Sensor%Sensor_Name) == 'VIIRS-NASA') then
#ifdef HDF5LIBS
         call READ_VIIRS_NASA_DATE_TIME(trim(Image%Level1b_Path),trim(Image%Level1b_Name), &
                             Start_Year_Tmp,Start_Day_Tmp,Start_Time_Tmp, &
                             End_Time_Tmp,Orbit_Number_Tmp, End_Year_Tmp , End_Day_Tmp)
         Image%Start_Year = Start_Year_Tmp
         Image%End_Year = End_Year_Tmp
         Image%Start_Doy = Start_Day_Tmp
         Image%End_Doy = End_Day_Tmp

         Image%Start_Time = Start_Time_Tmp
         Image%End_Time = End_Time_Tmp

#else
         PRINT *, "No HDF5 libraries installed, stopping"
         stop
#endif
      endif

      
      !----------------------------------------------
      ! for AHI ???????
      ! 
      !----------------------------------------------
      if (index(Sensor%Sensor_Name,'AHI') > 0) then
         
         call ahi_time_from_filename ( trim(Image%Level1b_Name) , time0_obj, time1_obj )
         
         call time0_obj % get_date ( year =  year &
                               , doy = doy  &
                               , msec_of_day = Image%Start_Time  )
         
         call time1_obj % get_date ( msec_of_day = Image%End_Time  )                                                

         Image%Start_Year  = year
         Image%Start_Doy   = doy   
         Image%End_Year  = year
         Image%End_Doy   = doy  
         
      endif
      
      !----------------------------------------------
      ! for IFF take time and set some constants
      ! could be VIIRS, MODIS AVHRR sensor
      !----------------------------------------------
      if (index(Sensor%Sensor_Name,'IFF') > 0) then
         call READ_IFF_DATE_TIME(trim(Image%Level1b_Path), trim(Image%Level1b_Name),Start_Year_Tmp, &
                      Start_Day_Tmp,Start_Time_Tmp, End_Year_Tmp,End_Day_Tmp,End_Time_Tmp)
         Image%Start_Year = Start_Year_Tmp
         Image%End_Year = End_Year_Tmp
         Image%Start_Doy = Start_Day_Tmp
         Image%End_Doy = End_Day_Tmp
         Image%Start_Time = Start_Time_Tmp
         Image%End_Time = End_Time_Tmp

      endif
      !----------------------------------------------
      ! for GOES, MTSAT and MSG, take time from AREAstr
      !----------------------------------------------
      if (index(Sensor%Sensor_Name,'GOES') > 0 .or.  &
          index(Sensor%Sensor_Name,'COMS') > 0 .or.  &
          index(Sensor%Sensor_Name,'MTSAT') > 0 .or.  &
          index(Sensor%Sensor_Name,'SEVIRI') > 0 .or.  &
          index(Sensor%Sensor_Name,'FY2') > 0) then

        !--- check if area file
        if (AREAstr%Version_Num == 4) then

         Image%Start_Year = 1900 + int(AREAstr%img_Date / 1000)
         Image%End_Year = Image%Start_Year
         Image%Start_Doy = AREAstr%img_Date - (Image%Start_Year - 1900) * 1000
         Image%End_Doy = Image%Start_Doy
         hour = AREAstr%img_Time / 10000 
         minute = (AREAstr%img_Time - hour * 10000) / 100
         second = (AREAstr%img_Time - hour * 10000 - minute * 100) / 100
         Image%Start_Time = ((hour * 60 + minute) * 60 + second) * 1000 !millisec
         Image%End_Time = Image%Start_Time
    
        endif
 
      end if

   end subroutine SET_DATA_DATE_AND_TIME
   !--------------------------------------------------------------------------------------
   !   screen output of sensor structure
   !--------------------------------------------------------------------------------------
   subroutine OUTPUT_SENSOR_TO_SCREEN()

      call mesg ( " ",level = verb_lev % DEFAULT)
      call mesg ( "SENSOR DEFINITION",level = verb_lev % DEFAULT)

      call mesg ( "Satellite = "//trim(Sensor%Platform_Name), level = verb_lev % DEFAULT)
      call mesg ( "Sensor = "//trim(Sensor%Sensor_Name), level = verb_lev % DEFAULT)

      write(string_3,'(i3)' ) Sensor%WMO_ID 
      call mesg ( "Spacecraft WMO number = "//trim(string_3) , level = verb_lev % DEFAULT)

      write ( string_6,'(i6)')   Sensor%Spatial_Resolution_Meters
      call mesg ( "Pixel Resolution (m) = "//string_6, level = verb_lev % DEFAULT)

      !--- some avhrr specific output
      if (index(Sensor%Sensor_Name,'AVHRR-1') > 0 .or. &
          index(Sensor%Sensor_Name,'AVHRR-2') > 0 .or. &
          index(Sensor%Sensor_Name,'AVHRR-3') > 0) then

         write ( string_3,'(i3)')   AVHRR_Data_Type
         call mesg ( "AVHRR data type = "//string_3, level = verb_lev % DEFAULT)

         write ( string_3,'(i3)')   AVHRR_Ver_1b
         call mesg ( "AVHRR Level1b Version = "//string_3, level = verb_lev % DEFAULT)

         write ( string_3,'(i3)')   AVHRR_GAC_FLAG
         call mesg ( "AVHRR GAC Flag = "//string_3, level = verb_lev % DEFAULT)

         write ( string_3,'(i3)')   AVHRR_KLM_FLAG
         call mesg ( "AVHRR KLM Flag = "//string_3, level = verb_lev % DEFAULT)

         write ( string_3,'(i3)')   AVHRR_AAPP_FLAG
         call mesg ( "AVHRR AAPP Flag = "//string_3, level = verb_lev % DEFAULT)
    
      end if

   end subroutine OUTPUT_SENSOR_TO_SCREEN
   !--------------------------------------------------------------------------------------
   !   screen output of some members of the image structure
   !--------------------------------------------------------------------------------------
   subroutine OUTPUT_IMAGE_TO_SCREEN()

      call mesg ( " ",level = verb_lev % DEFAULT)
      call mesg ( "IMAGE DEFINITION",level = verb_lev % DEFAULT)

      call mesg ("Level1b Name = "//trim(Image%Level1b_Name) , level = verb_lev % MINIMAL )

      write(string_6,'(i6)' ) Image%Number_Of_Elements
      call mesg ( "Number of Elements Per Line = "//string_6,level = verb_lev % DEFAULT)

      write(string_6,'(i6)' ) Image%Number_Of_Lines
      call mesg ( "Number of Lines in File = "//string_6,level = verb_lev % DEFAULT)

      write(string_6,'(i6)' ) Image%Number_Of_Lines_Per_Segment
      call mesg ( "Number of Lines in each Segment = "//string_6,level = verb_lev % DEFAULT)

      write ( string_30, '(I4,1X,I3,1X,F9.5)') Image%Start_Year,Image%Start_Doy, &
             Image%Start_Time/60.0/60.0/1000.0
      call mesg ("Start Year, Doy, Time = "//string_30,level = verb_lev % DEFAULT)

      write ( string_30, '(I4,1X,I3,1X,F9.5)') Image%End_Year,Image%End_Doy, &
             Image%End_Time/60.0/60.0/1000.0
      call mesg ("End Year, Doy, Time = "//string_30,level = verb_lev % DEFAULT)

      call mesg ( " ",level = verb_lev % DEFAULT)

   end subroutine OUTPUT_IMAGE_TO_SCREEN

   !--------------------------------------------------------------------------------------
   !   screen output of the spatial or viewing limits imposed on this processing
   !--------------------------------------------------------------------------------------
   subroutine OUTPUT_PROCESSING_LIMITS_TO_SCREEN()
      call mesg ( "PROCESSING LIMITS",level = verb_lev % DEFAULT)

      write(string_7,'(f7.2)' ) Nav%Lon_Max_Limit
      call mesg ( "Maximum Longitude for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.2)' ) Nav%Lon_Min_Limit
      call mesg ( "Minimum Longitude for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Nav%Lat_Max_Limit
      call mesg ( "Maximum Latitude for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Nav%Lat_Min_Limit
      call mesg ( "Minimum Latitude for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Geo%Satzen_Max_Limit
      call mesg ( "Maximum Sensor Zenith Angle for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Geo%Satzen_Min_Limit
      call mesg ( "Minimum Sensor Zenith Angle for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Geo%Solzen_Max_Limit
      call mesg ( "Maximum Solar Zenith Angle for Processing = "//string_7, level = verb_lev % DEFAULT)

      write(string_7,'(f7.1)' ) Geo%Solzen_Min_Limit
      call mesg ( "Minimum Solar Zenith Angle for Processing = "//string_7, level = verb_lev % DEFAULT)

      call mesg ( " ",level = verb_lev % DEFAULT)

   end subroutine OUTPUT_PROCESSING_LIMITS_TO_SCREEN

   !--------------------------------------------------------------------------------------------------
   !  Read the values from instrument constant files
   !--------------------------------------------------------------------------------------------------
   subroutine READ_INSTR_CONSTANTS()

      AVHRR_IFF_Flag = 0
 
      select case(trim(Sensor%Sensor_Name))

         case('AVHRR-1','AVHRR-2','AVHRR-3')
              call READ_AVHRR_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('MODIS','MODIS-MAC','MODIS-CSPP','AQUA-IFF')
              call READ_MODIS_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))

              !--- For psedo 13um Ch 45 use MODIS Ch 33 data 
              if (trim(Sensor%Sensor_Name) == 'AQUA-IFF') then
                 Planck_A1(45) = Planck_A1(33)
                 Planck_A2(45) = Planck_A2(33)
                 Planck_Nu(45) = Planck_Nu(33)
              endif
         case('GOES-IL-IMAGER','GOES-MP-IMAGER')
              call READ_GOES_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('GOES-IP-SOUNDER')
              call READ_GOES_SNDR_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('GOES-RU-IMAGER')
           call READ_ABI_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('SEVIRI')
              call READ_MSG_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('MTSAT-IMAGER')
              call READ_MTSAT_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('FY2-IMAGER')
              call READ_FY_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('COMS-IMAGER')
              call READ_COMS_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('AHI')
              call READ_AHI_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('VIIRS','VIIRS-NASA')
#ifdef HDF5LIBS 
              call READ_VIIRS_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
#else
         print *, "No HDF5 library installed, stopping"
         stop
#endif
         case('VIIRS-IFF')
            call READ_IFF_VIIRS_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
         case('AVHRR-IFF')
            call READ_IFF_AVHRR_INSTR_CONSTANTS(trim(Sensor%Instr_Const_File))
            AVHRR_IFF_Flag = 1

      end select

   end subroutine READ_INSTR_CONSTANTS

   !--------------------------------------------------------------------------------------------------
   !  Apply various tests to determine from which sensor this data comes
   !
   !  output is sesnorname and platform name
   !
   !
   !   AVHRR 
   !        sensors:  AVHRR-1, AVHRR-2, AVHRR-3
   !        platforms: NOAA-5 - NOAA-19, METOP-A - METOP-C
   !        spatial_resolution:  1.1, 4
   !  
   !   GOES
   !        sensors:   GOES-IL-IMAGER, GOES-MP-IMAGER, GOES-IP-SOUNDER
   !        platforms: GOES-8 - GOES-15
   !        spatial_resolution:  1, 4
   !
   !   METEOSAT
   !        sensors:  SEVIRI
   !        platform:  Meteosat-8 - Meteosat-11
   !        spatial_resolution:  3
   ! 
   !   MTSAT
   !        sensors:  MTSAT-IMAGER
   !        platform:  MTSAT-1R, MTSAT-2
   !        spatial_resolution:  4
   !
   !   COMS
   !        sensors:  COMS-IMAGER
   !        platform:  COMS-1
   !        spatial_resolution:  4
   !
   !   MODIS
   !        sensors:  MODIS, AQUA-IFF, MODIS-MAC, MODIS-CSPP
   !        platform:  AQUA, TERRA
   !        spatial_resolution:  1, 5
   !
   !   VIIRS
   !        sensors:  VIIRS, VIIRS-NASA, VIIRS-IFF
   !        platform:  SNPP
   !        spatial_resolution:  0.75
   !        
   !
   !  Output: The sensor structure which is global does not appear as an argument
   !--------------------------------------------------------------------------------------------------
   subroutine DETECT_SENSOR_FROM_FILE( &
           AREAstr &
         , NAVstr &
         , Ierror)

      TYPE (AREA_STRUCT), intent(out) :: AREAstr
      TYPE (GVAR_NAV), intent(out)    :: NAVstr
      integer(kind=int4) :: Ierror
      integer(kind=int4) :: Ifound

      !-------------------------------------------------------------------------
      !-- Initialize Sensor Structure
      !-------------------------------------------------------------------------
      Sensor%Sensor_Name = ''
      Sensor%Spatial_Resolution_Meters = Missing_Value_Int4
      Sensor%Platform_Name = ''
      Sensor%WMO_Id = Missing_Value_Int4
      Sensor%Instr_Const_File = 'no_file'
      Sensor%Algo_Const_File = 'no_file'
      Sensor%Geo_Sub_Satellite_Longitude = Missing_Value_Real4
      Sensor%Geo_Sub_Satellite_Latitude = Missing_Value_Real4

      !-------------------------------------------------------------------------
      !-- Loop through tests for each file type, if not found assume avhrr
      !-------------------------------------------------------------------------
      Ierror = sym%NO
      ifound = sym%NO
      
     

      test_loop: do while (ifound == sym%NO)
      
      !--- HIMAWARI-8 AHI Test
      if (index(Image%Level1b_Name, 'HS_H08') > 0) then
        Sensor%Sensor_Name = 'AHI'
        Sensor%Platform_Name = 'HIM8'
        Sensor%Spatial_Resolution_Meters = 2000
        Sensor%WMO_Id = 173
        Sensor%Instr_Const_File = 'him8_instr.dat'
        Sensor%Algo_Const_File = 'him8_algo.dat'
        Sensor%Geo_Sub_Satellite_Longitude = 140.0
        Sensor%Geo_Sub_Satellite_Latitude = 0.0
        exit test_loop
      endif
      
      !--- MODIS Test
      if (index(Image%Level1b_Name, 'MYD021KM') > 0) then
        Sensor%Sensor_Name = 'MODIS'
        Sensor%Platform_Name = 'AQUA'
        Sensor%Spatial_Resolution_Meters = 1000
        Sensor%WMO_Id = 784
        Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
        Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 'MYD02SSH') > 0) then
        Sensor%Sensor_Name = 'MODIS'
        Sensor%Platform_Name = 'AQUA'
        Sensor%Spatial_Resolution_Meters = 5000
        Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
        Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
        Sensor%WMO_Id = 784
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 'MYDATML') > 0) then
        Sensor%Sensor_Name = 'MODIS'
        Sensor%Platform_Name = 'AQUA'
        Sensor%Spatial_Resolution_Meters = 5000
        Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
        Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
        Sensor%WMO_Id = 784
        exit test_loop
      endif


      if (index(Image%Level1b_Name, 'MOD021KM') > 0) then
        Sensor%Sensor_Name = 'MODIS'
        Sensor%Platform_Name = 'TERRA'
        Sensor%Spatial_Resolution_Meters = 1000
        Sensor%WMO_Id = 783
        Sensor%Instr_Const_File = 'modis_terra_instr.dat'
        Sensor%Algo_Const_File = 'modis_terra_algo.dat'
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 'MOD02SSH') > 0) then
        Sensor%Sensor_Name = 'MODIS'
        Sensor%Platform_Name = 'TERRA'
        Sensor%Spatial_Resolution_Meters = 5000
        Sensor%WMO_Id = 783
        Sensor%Instr_Const_File = 'modis_terra_instr.dat'
        Sensor%Algo_Const_File = 'modis_terra_algo.dat'
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 'MAC02') > 0) then
        Sensor%Sensor_Name = 'MODIS-MAC'
        Sensor%Platform_Name = 'AQUA'
        Sensor%Spatial_Resolution_Meters = 1000
        Sensor%WMO_Id = 784
        Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
        Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 'a1.') > 0) then
        Sensor%Sensor_Name = 'MODIS-CSPP'
        Sensor%Platform_Name = 'AQUA'
        Sensor%Spatial_Resolution_Meters = 1000
        Sensor%WMO_Id = 784
        Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
        Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
        exit test_loop
      endif

      if (index(Image%Level1b_Name, 't1.') > 0) then
        Sensor%Sensor_Name = 'MODIS-CSPP'
        Sensor%Platform_Name = 'TERRA'
        Sensor%Spatial_Resolution_Meters = 1000
        Sensor%WMO_Id = 783
        Sensor%Instr_Const_File = 'modis_terra_instr.dat'
        Sensor%Algo_Const_File = 'modis_terra_algo.dat'
        exit test_loop
      endif

      !---  Check Geostationary (assumed to be areafiles)
      call GET_GOES_HEADERS(Image%Level1b_Full_Name, AREAstr, NAVstr)

      if (AREAstr%Version_Num == 4) then                          !begin valid Areafile test

         !--- set spatial resolution  !(AKH??? - Is this valid for all sensors)
         Sensor%Spatial_Resolution_Meters = real(AREAstr%Elem_Res)

         !--- based on McIdas Id, set sensor struc parameters
         select case(AREAstr%Sat_Id_Num)
 
            !test for SEVIRI
            case (51:54)
               Sensor%Sensor_Name = 'SEVIRI'
               Sensor%Spatial_Resolution_Meters = 3000
              
               if (AREAstr%Sat_Id_Num == 51) then
                  Sensor%Platform_Name = 'Meteosat-8'
                  Sensor%WMO_Id = 55
                  Sensor%Instr_Const_File = 'met8_instr.dat'
                  Sensor%Algo_Const_File = 'met8_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 52)  then
                  Sensor%Platform_Name = 'Meteosat-9'
                  Sensor%WMO_Id = 56
                  Sensor%Instr_Const_File = 'met9_instr.dat'
                  Sensor%Algo_Const_File = 'met9_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 53) then
                  Sensor%Platform_Name = 'Meteosat-10'
                  Sensor%WMO_Id = 57
                  Sensor%Instr_Const_File = 'met10_instr.dat'
                  Sensor%Algo_Const_File = 'met10_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 54) then
                  Sensor%Platform_Name = 'Meteosat-11'
                  Sensor%WMO_Id = 58
                  Sensor%Instr_Const_File = 'met11_instr.dat'
                  Sensor%Algo_Const_File = 'met11_algo.dat'
                  exit test_loop
               endif

            case (84,85)
               Sensor%Sensor_Name = 'MTSAT-IMAGER'
               Sensor%Spatial_Resolution_Meters = 4000
               if (AREAstr%Sat_Id_Num == 84) then
                  Sensor%Platform_Name = 'MTSAT-1R'
                  Sensor%WMO_Id = 171
                  Sensor%Instr_Const_File = 'mtsat1r_instr.dat'
                  Sensor%Algo_Const_File = 'mtsat1r_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 85) then
                  Sensor%Platform_Name = 'MTSAT-2'
                  Sensor%WMO_Id = 172
                  Sensor%Instr_Const_File = 'mtsat2_instr.dat'
                  Sensor%Algo_Const_File = 'mtsat2_algo.dat'
                  exit test_loop
               endif

            case (36, 37)
               Sensor%Sensor_Name = 'FY2-IMAGER'
               Sensor%Spatial_Resolution_Meters = 4000
               if (AREAstr%Sat_Id_Num == 36) then
                  Sensor%Platform_Name = 'FY-2D'
                  Sensor%WMO_Id = 514
                  Sensor%Instr_Const_File = 'fy2d_instr.dat'
                  Sensor%Algo_Const_File = 'fy2d_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 37) then
                  Sensor%Platform_Name = 'FY-2E'
                  Sensor%WMO_Id = 515
                  Sensor%Instr_Const_File = 'fy2e_instr.dat'
                  Sensor%Algo_Const_File = 'fy2e_algo.dat'
                  exit test_loop
               endif

            case (250)
               Sensor%Sensor_Name = 'COMS-IMAGER'
               Sensor%Spatial_Resolution_Meters = 4000
               Sensor%Platform_Name = 'COMS-1'
               Sensor%WMO_Id = 810
               Sensor%Instr_Const_File = 'coms1_instr.dat'
               Sensor%Algo_Const_File = 'coms1_algo.dat'
               exit test_loop

            case (70,72,74,76,78,180,182,184,186)

               if (AREAstr%Sat_Id_Num == 70) then
                  Sensor%Sensor_Name = 'GOES-IL-IMAGER'
                  Sensor%Platform_Name = 'GOES-8'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 252
                  Sensor%Instr_Const_File = 'goes_08_instr.dat'
                  Sensor%Algo_Const_File = 'goes_08_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 72) then
                  Sensor%Sensor_Name = 'GOES-IL-IMAGER'
                  Sensor%Platform_Name = 'GOES-9'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 253
                  Sensor%Instr_Const_File = 'goes_09_instr.dat'
                  Sensor%Algo_Const_File = 'goes_09_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 74) then
                  Sensor%Sensor_Name = 'GOES-IL-IMAGER'
                  Sensor%Platform_Name = 'GOES-10'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 254
                  Sensor%Instr_Const_File = 'goes_10_instr.dat'
                  Sensor%Algo_Const_File = 'goes_10_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 76) then
                  Sensor%Sensor_Name = 'GOES-IL-IMAGER'
                  Sensor%Platform_Name = 'GOES-11'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 255
                  Sensor%Instr_Const_File = 'goes_11_instr.dat'
                  Sensor%Algo_Const_File = 'goes_11_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 78) then
                  Sensor%Sensor_Name = 'GOES-MP-IMAGER'
                  Sensor%Platform_Name = 'GOES-12'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 256
                  Sensor%Instr_Const_File = 'goes_12_instr.dat'
                  Sensor%Algo_Const_File = 'goes_12_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 180) then
                  Sensor%Sensor_Name = 'GOES-MP-IMAGER'
                  Sensor%Platform_Name = 'GOES-13'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 257
                  Sensor%Instr_Const_File = 'goes_13_instr.dat'
                  Sensor%Algo_Const_File = 'goes_13_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 182) then
                  Sensor%Sensor_Name = 'GOES-MP-IMAGER'
                  Sensor%Platform_Name = 'GOES-14'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 258
                  Sensor%Instr_Const_File = 'goes_14_instr.dat'
                  Sensor%Algo_Const_File = 'goes_14_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 184) then
                  Sensor%Sensor_Name = 'GOES-MP-IMAGER'
                  Sensor%Platform_Name = 'GOES-15'
                  Sensor%Spatial_Resolution_Meters = 4000
                  Sensor%WMO_Id = 259
                  Sensor%Instr_Const_File = 'goes_15_instr.dat'
                  Sensor%Algo_Const_File = 'goes_15_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 186) then
                  Sensor%Sensor_Name = 'GOES-RU-IMAGER'
                  Sensor%Spatial_Resolution_Meters = 2000
                  Sensor%Platform_Name = 'GOES-16'
                  Sensor%WMO_Id = 270
                  Sensor%Instr_Const_File = 'goes_16_instr.dat'
                  Sensor%Algo_Const_File = 'goes_16_algo.dat'
                  exit test_loop
               endif

            case (71,73,75,77,79,181,183,185)
               if (AREAstr%Sat_Id_Num == 71) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-8'
                  Sensor%WMO_Id = 252
                  Sensor%Instr_Const_File = 'goes_08_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_08_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 73) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-9'
                  Sensor%WMO_Id = 253
                  Sensor%Instr_Const_File = 'goes_09_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_09_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 75) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-10'
                  Sensor%WMO_Id = 254
                  Sensor%Instr_Const_File = 'goes_10_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_10_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 77) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-11'
                  Sensor%WMO_Id = 255
                  Sensor%Instr_Const_File = 'goes_11_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_11_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 79) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-12'
                  Sensor%WMO_Id = 256
                  Sensor%Instr_Const_File = 'goes_12_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_12_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 181) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-13'
                  Sensor%WMO_Id = 257
                  Sensor%Instr_Const_File = 'goes_13_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_13_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 183) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 10000
                  Sensor%Platform_Name = 'GOES-14'
                  Sensor%WMO_Id = 258
                  Sensor%Instr_Const_File = 'goes_14_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_14_sndr_algo.dat'
                  exit test_loop
               endif
               if (AREAstr%Sat_Id_Num == 185) then
                  Sensor%Sensor_Name = 'GOES-IL-SOUNDER'
                  Sensor%Spatial_Resolution_Meters = 100000
                  Sensor%Platform_Name = 'GOES-15'
                  Sensor%WMO_Id = 259
                  Sensor%Instr_Const_File = 'goes_15_sndr_instr.dat'
                  Sensor%Algo_Const_File = 'goes_15_sndr_algo.dat'
                  exit test_loop
               endif

            end select
      endif

      !---  VIIRS
      if (index(Image%Level1b_Name, 'GMTCO') > 0) then 
         Sensor%Sensor_Name = 'VIIRS'
         Sensor%Spatial_Resolution_Meters = 750
         Sensor%Platform_Name = 'SNPP'
         Sensor%WMO_Id = 224
         Sensor%Instr_Const_File = 'viirs_npp_instr.dat'
         Sensor%Algo_Const_File = 'viirs_npp_algo.dat'
         exit test_loop
      endif

      !--- NPP/JPSS IFF 
      if (index(Image%Level1b_Name, 'IFFSDR_npp') > 0 .or. &
          index(Image%Level1b_Name, 'IFFSVM_npp') > 0 .or. &
          index(Image%Level1b_Name, 'IFF_npp') > 0) then
         Sensor%Sensor_Name = 'VIIRS-IFF'
         Sensor%Spatial_Resolution_Meters = 750
         Sensor%Platform_Name = 'SNPP'
         Sensor%WMO_Id = 224
         Sensor%Instr_Const_File = 'iff_viirs_npp_instr.dat'
         Sensor%Algo_Const_File = 'viirs_npp_algo.dat'
         exit test_loop
      endif

      !---  VIIRS-NASA
      if (index(Image%Level1b_Name, 'VGEOM') > 0) then
         Sensor%Sensor_Name = 'VIIRS-NASA'
         Sensor%Spatial_Resolution_Meters = 750
         Sensor%Platform_Name = 'SNPP'
         Sensor%WMO_Id = 224
         Sensor%Instr_Const_File = 'viirs_npp_instr.dat'
         Sensor%Algo_Const_File = 'viirs_npp_algo.dat'
         exit test_loop
      endif

      !--- AQUA IFF
      if (index(Image%Level1b_Name, 'IFFSDR_aqua') > 0) then
         Sensor%Sensor_Name = 'AQUA-IFF'
         Sensor%Spatial_Resolution_Meters = 1000
         Sensor%Platform_Name = 'AQUA'
         Sensor%WMO_Id = 784
         Sensor%Instr_Const_File = 'modis_aqua_instr.dat'
         Sensor%Algo_Const_File = 'modis_aqua_algo.dat'
         exit test_loop
      endif

      !--- AVHRR IFF
      !--- MJH: is it ok to use avhrr algo files here? or do we need new
      !         ones for AVHRR/HIRS?
      if (index(Image%Level1b_Name, 'IFF_noaa') > 0 .or. &
          index(Image%Level1b_Name, 'IFF_metop') > 0) then
            Sensor%Spatial_Resolution_Meters = 4000
            if (index(Image%Level1b_Name, 'IFF_noaa06') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 2
               Sensor%Platform_Name = 'NOAA-6'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 706
               Sensor%Instr_Const_File = "iff_avhrr_6_instr.dat"
               Sensor%Algo_Const_File = "avhrr_6_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa07') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 4
               Sensor%Platform_Name = 'NOAA-7'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 707
               Sensor%Instr_Const_File = "iff_avhrr_7_instr.dat"
               Sensor%Algo_Const_File = "avhrr_7_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa08') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 6
               Sensor%Platform_Name = 'NOAA-8'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 200
               Sensor%Instr_Const_File = "iff_avhrr_8_instr.dat"
               Sensor%Algo_Const_File = "avhrr_8_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa09') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 7
               Sensor%Platform_Name = 'NOAA-9'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 201
               Sensor%Instr_Const_File = "iff_avhrr_9_instr.dat"
               Sensor%Algo_Const_File = "avhrr_9_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa10') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 8
               Sensor%Platform_Name = 'NOAA-10'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 202
               Sensor%Instr_Const_File = "iff_avhrr_10_instr.dat"
               Sensor%Algo_Const_File = "avhrr_10_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa11') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 1
               Sensor%Platform_Name = 'NOAA-11'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 203
               Sensor%Instr_Const_File = "iff_avhrr_11_instr.dat"
               Sensor%Algo_Const_File = "avhrr_11_algo.dat"
               exit test_loop
            endif
            if (index(Image%Level1b_Name, 'IFF_noaa12') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 5
               Sensor%Platform_Name = 'NOAA-12'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 204
               Sensor%Instr_Const_File = "iff_avhrr_12_instr.dat"
               Sensor%Algo_Const_File = "avhrr_12_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa14') == 1) then
               AVHRR_KLM_Flag = sym%NO
               Sc_Id_AVHRR = 3
               Sensor%Platform_Name = 'NOAA-14'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 205
               Sensor%Instr_Const_File = "iff_avhrr_14_instr.dat"
               Sensor%Algo_Const_File = "avhrr_14_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa15') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 4
               Sensor%Platform_Name = 'NOAA-15'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 206
               Sensor%Instr_Const_File = "iff_avhrr_15_instr.dat"
               Sensor%Algo_Const_File = "avhrr_15_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa16') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 2
               Sensor%Platform_Name = 'NOAA-16'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 207
               Sensor%Instr_Const_File = "iff_avhrr_16_instr.dat"
               Sensor%Algo_Const_File = "avhrr_16_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa17') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 6
               Sensor%Platform_Name = 'NOAA-17'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 208
               Sensor%Instr_Const_File = "iff_avhrr_17_instr.dat"
               Sensor%Algo_Const_File = "avhrr_17_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa18') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 7
               Sensor%Platform_Name = 'NOAA-18'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 209
               Sensor%Instr_Const_File = "iff_avhrr_18_instr.dat"
               Sensor%Algo_Const_File = "avhrr_18_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_noaa19') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 8
               Sensor%Platform_Name = 'NOAA-19'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 223
               Sensor%Instr_Const_File = "iff_avhrr_19_instr.dat"
               Sensor%Algo_Const_File = "avhrr_19_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_metop02') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 12
               Sensor%Platform_Name = 'METOP-A'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 4
               Sensor%Instr_Const_File = "iff_avhrr_2_instr.dat"
               Sensor%Algo_Const_File = "avhrr_2_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_metop01') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 11
               Sensor%Platform_Name = 'METOP-B'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 3
               Sensor%Instr_Const_File = "iff_avhrr_1_instr.dat"
               Sensor%Algo_Const_File = "avhrr_1_algo.dat"
               exit test_loop
            end if
            if (index(Image%Level1b_Name, 'IFF_metop03') == 1) then
               AVHRR_KLM_Flag = sym%YES
               Sc_Id_AVHRR = 13 ! Metop-C Sc_Id numbers are not known at this time
               Sensor%Platform_Name = 'METOP-C'
               Sensor%Sensor_Name = 'AVHRR-IFF'
               Sensor%WMO_Id = 5
               Sensor%Instr_Const_File = "iff_avhrr_3_instr.dat"
               Sensor%Algo_Const_File = "avhrr_3_algo.dat"
               exit test_loop
            end if

      endif


      !-------------------------------------------------------------------------------
      !---if sensor not detected, assume AVHRR
      !-------------------------------------------------------------------------------

      !--- from a preliminary header read, set some global AVHRR flags and parameters
      call DETERMINE_AVHRR_FILE_TYPE(trim(Image%Level1b_Full_Name), &
                                     AVHRR_GAC_FLAG,AVHRR_KLM_Flag,AVHRR_AAPP_Flag, &
                                     AVHRR_Ver_1b,AVHRR_Data_Type,Byte_Swap_1b,AVHRR_1_Flag)

      !--- knowing Sc_Id_AVHRR and the above flags, populate sensor structure for AVHRR
      call ASSIGN_AVHRR_SAT_ID_NUM_INTERNAL()

      if (AVHRR_GAC_Flag == sym%YES) then
         Sensor%Spatial_Resolution_Meters = 4000
      else
         Sensor%Spatial_Resolution_Meters = 1000
      endif
     
      ifound = sym%YES   ! force exit need to develop logic for setting Ierror

      enddo test_loop
  
      !---------------------------------------------------------------------------------
      ! Set sub-satellite point for geostationary satellites that are Areafiles
      !---------------------------------------------------------------------------------
      call DETERMINE_GEO_SUB_SATELLITE_POSITION(trim(Image%Level1b_Full_Name),AREAstr,NAVstr)

      !---------------------------------------------------------------------------------
      ! append full path on constant files
      !---------------------------------------------------------------------------------
      Sensor%Instr_Const_File = trim(Ancil_Data_Dir)//"static/clavrx_constant_files/"//trim(Sensor%Instr_Const_File)
      Sensor%Algo_Const_File = trim(Ancil_Data_Dir)//"static/clavrx_constant_files/"//trim(Sensor%Algo_Const_File)

      !---------------------------------------------------------------------------------
      ! For MODIS, determine names of additional files for level-1b processing
      !---------------------------------------------------------------------------------

      !-- for 1 km MODIS, determine name of separate geolocation file
      if ((trim(Sensor%Sensor_Name) == 'MODIS' .or. trim(Sensor%Sensor_Name) == 'MODIS-CSPP') &
          .and.  Sensor%Spatial_Resolution_Meters == 1000) then
         call DETERMINE_MODIS_GEOLOCATION_FILE(Image%Level1b_Name,Image%Level1b_Path,Image%Auxiliary_Geolocation_File_Name)
         if (trim(Image%Auxiliary_Geolocation_File_Name) == "no_file") then
            Ierror = sym%YES
         endif
      endif


      !-- determine modis cloud mask name
      if ((trim(Sensor%Sensor_Name) == 'MODIS' .or. trim(Sensor%Sensor_Name) == 'MODIS-CSPP') &
          .and. Cloud_Mask_Aux_Flag /= sym%No_AUX_CLOUD_MASK) then

         call DETERMINE_MODIS_CLOUD_MASK_FILE(Image%Level1b_Name,Image%Level1b_Path,Image%Auxiliary_Cloud_Mask_File_Name )
         if (trim(Image%Auxiliary_Cloud_Mask_File_Name) == "no_file" .and. &
                  Cloud_Mask_Bayesian_Flag == sym%NO) then
            Ierror = sym%YES
         endif

      endif


   end subroutine DETECT_SENSOR_FROM_FILE

   !=====================================================================
   !
   !=====================================================================
   subroutine DETERMINE_GEO_SUB_SATELLITE_POSITION(Level1b_Full_Name,AREAstr,NAVstr)

    character(len=*), intent(in):: Level1b_Full_Name
    type (AREA_STRUCT), intent(inout) :: AREAstr
    type (GVAR_NAV), intent(inout)    :: NAVstr
    REAL (KIND=REAL4)                 :: Lat_temp, Lon_temp
    INTEGER (KIND=INT4)               :: Year_temp

    Sensor%Geo_Sub_Satellite_Longitude = Missing_Value_Real4
    Sensor%Geo_Sub_Satellite_Latitude = Missing_Value_Real4

    ! Calculate year of the image from the McIDAS AREA file.
    Year_temp = 1900 + int(AREAstr%img_Date / 1000)

    if (AREAstr%Version_Num == 4) then                          !begin valid Areafile test

      select case(AREAstr%Sat_Id_Num)
 
            !test for SEVIRI
            case (51:53)
               ! Read the satellite sub longitude point from the AREA file.
               call READ_NAVIGATION_BLOCK_SEVIRI(trim(Level1b_Full_Name), AREAstr, NAVstr)
               Sensor%Geo_Sub_Satellite_Latitude = NAVstr%sublat 
               Sensor%Geo_Sub_Satellite_Longitude = NAVstr%sublon
               ! Override the above for the operational sub satellite longitudes.
               ! Longitude of actual Sub-Satellite Point for Met-8 when it was operational.  For Met-8 Indian
               ! Ocean service, the subpoint from the AREA file is used.
               if (AREAstr%Sat_Id_Num == 51 .AND. Year_temp < 2016 ) Sensor%Geo_Sub_Satellite_Longitude = -3.477996 
               if (AREAstr%Sat_Id_Num == 52 ) Sensor%Geo_Sub_Satellite_Longitude = -0.159799     ! Longitude of actual Sub-Satellite Point for Met-9
               if (AREAstr%Sat_Id_Num == 53 ) Sensor%Geo_Sub_Satellite_Longitude = 0.06          ! Longitude of actual Sub-Satellite Point for Met-10
               AREAstr%Cal_Offset = AREAstr%reserved(3)
                    
            !test for MTSAT
            case (84,85)
               !This is needed to determine type of navigation
               !as Nav coefficents specific to MTSAT (and FY2)
               call READ_NAVIGATION_BLOCK_MTSAT_FY(trim(Level1b_Full_Name), AREAstr, NAVstr)
               Sensor%Geo_Sub_Satellite_Latitude = NAVstr%sublat
               Sensor%Geo_Sub_Satellite_Longitude = NAVstr%sublon
          
            !WCS3 - FY2-D AREA files have the subsat lat/lon flipped. Fix here
            !        Fix with McIDAS-X is fixed.
            case (36, 37)
               !This is needed to determine type of navigation
               !as Nav coefficents specific to FY2D/E. They are stored in
               ! the same manner as MTSAT, hence using the same routine
               call READ_NAVIGATION_BLOCK_MTSAT_FY(trim(Level1b_Full_Name), AREAstr, NAVstr)
               
               !Some data from BOM has subpoints flipped, so need to fix that
               IF (NAVstr%sublat .GT. 10.0) THEN
                    Lat_temp = NAVstr%sublon                   
                    Lon_temp = NAVstr%sublat
                    
                    NAVstr%sublon = Lon_temp
                    NAVstr%sublat = Lat_temp
               
               ENDIF
               
               
               Sensor%Geo_Sub_Satellite_Latitude = NAVstr%sublat
               Sensor%Geo_Sub_Satellite_Longitude = NAVstr%sublon
 
            !test for COMS
            case (250)
               !This is needed to determine type of navigation
               !as Nav coefficents specific to COMS
               call READ_NAVIGATION_BLOCK_COMS(trim(Level1b_Full_Name), AREAstr,NAVstr)
               Sensor%Geo_Sub_Satellite_Latitude = NAVstr%sublat
               Sensor%Geo_Sub_Satellite_Longitude = NAVstr%sublon

            !test for GOES-16
            case (186)
               ! This is needed to determine type of navigation
               ! as Nav coefficents specific to GOES-16. These
               ! coefficients are based on 1 km data, not 2 km.
               ! Navigation transformations in abi_module.f90 will
               ! account for this difference.

               call READ_NAVIGATION_BLOCK_ABI(trim(Level1b_Full_Name), AREAstr,NAVstr)
               Sensor%Geo_Sub_Satellite_Latitude = NAVstr%sublat
               Sensor%Geo_Sub_Satellite_Longitude = NAVstr%sublon

            !test for GOES Imagers or Sounders
            case (70:79,180:185)

               call LMODEL(Goes_Input_Time,  &
                           Goes_Epoch_Time, &
                           NAVstr, &
                           Sensor%Geo_Sub_Satellite_Latitude, &
                           Sensor%Geo_Sub_Satellite_Longitude)

                      Sensor%Geo_Sub_Satellite_Longitude = Sensor%Geo_Sub_Satellite_Longitude / Dtor
                      Sensor%Geo_Sub_Satellite_Latitude = Sensor%Geo_Sub_Satellite_Latitude  / Dtor

            case default
                print *, "Could not determine geostationary sub-satellite point"
                stop

      end select

    endif

   end subroutine DETERMINE_GEO_SUB_SATELLITE_POSITION
   
   !---------------------------------------------------------------------------------------------
   ! Determine the number of elements (Image%Number_Of_Elements) and Number of Scans (Image%Number_Of_Lines)
   ! expected.  Also, 
   !
   !    the output will be written in global Image structure
   !---------------------------------------------------------------------------------------------
   subroutine SET_FILE_DIMENSIONS(Level1b_Full_Name,AREAstr,Nrec_Avhrr_Header, &
                                 Ierror)
      use cx_read_ahi_mod, only : &
         ahi_segment_information_region &
         ,ahi_config_type
                                                               
      CHARACTER(len=*), intent(in) :: Level1b_Full_Name
      TYPE (AREA_STRUCT), intent(in) :: AREAstr ! AVHRR only
      integer(kind=int4), intent(out) :: Nrec_Avhrr_Header ! AVHRR only
      integer(kind=int4), intent(out) :: Ierror

      integer(kind=int4) :: Nword_Clavr
      integer(kind=int4) :: Nword_Clavr_Start
      integer(kind=int4) :: Ierror_Viirs_Nscans
      CHARACTER(len=1020) :: Dir_File
      
      type ( ahi_config_type ) :: ahi_config
      integer :: offset(2), count(2)

      Ierror = sym%NO
      if (index(Sensor%Sensor_Name,'MODIS') > 0) then
         call READ_MODIS_SIZE_ATTR(trim(Level1b_Full_Name),Image%Number_Of_Elements,Image%Number_Of_Lines)
      endif
   
      if (trim(Sensor%Sensor_Name) == 'MODIS-MAC') then
         Image%Number_Of_Elements =  11
         Image%Number_Of_Lines = 2030
      endif
      
      if ( trim(Sensor%Sensor_Name) == 'AHI') then
      
         
         Image%Number_Of_Elements =  5500
         Image%Number_Of_Lines = 5500
         
         if ( nav % lon_lat_limits_set ) then
            ahi_config % data_path = trim(Image%Level1b_Path)
            ahi_config % file_base = trim (Image%level1b_name)
            ahi_config % lon_range =[Nav%Lon_Min_Limit,Nav%Lon_Max_Limit]
            ahi_config % lat_range =[Nav%Lat_Min_Limit,Nav%Lat_Max_Limit]
            call ahi_segment_information_region ( ahi_config , offset, count )
         
            Image%Number_Of_Elements =  count(1)
            Image%Number_Of_Lines = count(2)
         end if
         
      end if
   
      if (trim(Sensor%Sensor_Name) == 'VIIRS') then
         Image%Number_Of_Elements = 3200
         Dir_File = trim(Image%Level1b_Path) // trim(Image%Level1b_Name)
#ifdef HDF5LIBS
         call GET_NUMBER_OF_SCANS_FROM_VIIRS_BRIDGE (trim(Dir_File),Image%Number_Of_Lines,Ierror_Viirs_Nscans)

         ! If error reading, then go to next file
         if (ierror_viirs_nscans /= 0) then
            Ierror = sym%YES
            return      ! skips file
         endif

         ! Check if VIIRS Number of scans is regular (48) and calculate Number of y pixels
         if (Image%Number_Of_Lines .ge. 48) then
            Image%Number_Of_Lines = Image%Number_Of_Lines * 16      !16pix per Scan
         else if (Image%Number_Of_Lines == 47) then
            Image%Number_Of_Lines = (Image%Number_Of_Lines+1) * 16
         else
            Ierror = sym%YES
            return      !skips file
         end if

#else
         print *, "No HDF5 library installed. VIIRS unable to process. Stopping"
         stop
#endif
      end if

      if (trim(Sensor%Sensor_Name) == 'VIIRS-NASA') then
         Image%Number_Of_Elements = 3200
         Dir_File = trim(Image%Level1b_Path) // trim(Image%Level1b_Name)
#ifdef HDF5LIBS
         call READ_NUMBER_OF_SCANS_VIIRS_NASA (trim(Dir_File),Image%Number_Of_Lines,Ierror_Viirs_Nscans)

         ! If error reading, then go to next file
         if (Ierror_Viirs_Nscans /= 0) then
            Ierror = sym%YES
            return      ! skips file
         endif
#else
         print *, "No HDF5 library installed. VIIRS-NASA unable to process. Stopping"
         stop
#endif

      endif
      
      !--- if an IFF, call routine to determine dimensions from latitude sds
      if (index(Sensor%Sensor_Name,'IFF') > 0) then
         call GET_IFF_DIMS_BRIDGE(trim(Image%Level1b_Path)//trim(Image%Level1b_Name),Image%Number_Of_Elements,Image%Number_Of_Lines)
      end if
     
      !--- AVHRR
      if (trim(Sensor%Sensor_Name) == 'AVHRR-1' .or. &
          trim(Sensor%Sensor_Name) == 'AVHRR-2' .or. &
          trim(Sensor%Sensor_Name) == 'AVHRR-3') then

         !-------------------------------------------------------
         ! Determine the type of level 1b file
         !-------------------------------------------------------
         call DETERMINE_AVHRR_FILE_TYPE(trim(Level1b_Full_Name),AVHRR_GAC_FLAG,AVHRR_KLM_Flag,AVHRR_AAPP_Flag, &
                                        AVHRR_Ver_1b,AVHRR_Data_Type,Byte_Swap_1b,AVHRR_1_Flag)
  
         !-------------------------------------------------------------------
         !-- based on file type (AVHRR_KLM_Flag and Gac), determine parameters needed
         !-- to read in header and data records for this orbit
         !------------------------------------------------------------------- 
         call DEFINE_1B_DATA(AVHRR_GAC_Flag,AVHRR_KLM_Flag,AVHRR_AAPP_Flag,Nrec_Avhrr_Header, &
                             Nword_Clavr_Start,Nword_Clavr)

         !-------------------------------------------------------------------
         !-- read in header
         !-------------------------------------------------------------------
         call READ_AVHRR_LEVEL1B_HEADER(trim(Level1b_Full_Name))

      end if

      !------------------------------------------------------------------------
      !  if GOES, SEVIRI and MTSAT, use elements of AREAstr to determine filesize
      !------------------------------------------------------------------------
      if (trim(Sensor%Sensor_Name) == 'GOES-IL-IMAGER' .or. &
          trim(Sensor%Sensor_Name) == 'GOES-MP-IMAGER') then
         Image%Number_Of_Elements =  int(AREAstr%Num_Elem / Goes_Xstride)
         Image%Number_Of_Lines = AREAstr%Num_Line
         L1b_Rec_Length = AREAstr%Num_Byte_Ln_Prefix +  &
                     (AREAstr%Num_Elem*AREAstr%Bytes_Per_Pixel)
      end if

      if (trim(Sensor%Sensor_Name) == 'GOES-RU-IMAGER') then
         Image%Number_Of_Elements =  int(AREAstr%Num_Elem)
         Image%Number_Of_Lines = AREAstr%Num_Line
      end if

      if (trim(Sensor%Sensor_Name) == 'GOES_IP_SOUNDER') then
         Image%Number_Of_Elements =  int(AREAstr%Num_Elem / Goes_Sndr_Xstride)
         Image%Number_Of_Lines = AREAstr%Num_Line
         L1b_Rec_Length = AREAstr%Num_Byte_Ln_Prefix +  &
                     (AREAstr%Num_Elem*AREAstr%Bytes_Per_Pixel)
      end if

      if (trim(Sensor%Sensor_Name) == 'SEVIRI') then
         Image%Number_Of_Elements =  int(AREAstr%Num_Elem)
         Image%Number_Of_Lines = AREAstr%Num_Line
      end if

      if (trim(Sensor%Sensor_Name) == 'MTSAT-IMAGER' .or. &
          trim(Sensor%Sensor_Name) == 'FY2-IMAGER' .or. &
          trim(Sensor%Sensor_Name) == 'COMS-IMAGER') then
         Image%Number_Of_Elements =  int(AREAstr%Num_Elem)
         Image%Number_Of_Lines = AREAstr%Num_Line
      end if

   end subroutine SET_FILE_DIMENSIONS

   !--------------------------------------------------------------------------------------------------
   !
   !--------------------------------------------------------------------------------------------------
   subroutine READ_LEVEL1B_DATA(Level1b_Full_Name,Segment_Number,Time_Since_Launch,AREAstr,NAVstr,Nrec_Avhrr_Header,Ierror_Level1b)

      character(len=*), intent(in):: Level1b_Full_Name
      integer, intent(in):: Segment_Number
      integer, intent(in):: Nrec_Avhrr_Header
      TYPE (AREA_STRUCT), intent(in) :: AREAstr
      TYPE (GVAR_NAV), intent(in)    :: NAVstr
      real, intent(in):: Time_Since_Launch
      integer, intent(out):: Ierror_Level1b

      Ierror_Level1b = 0
      Cloud_Mask_Aux_Read_Flag = sym%NO

      if (index(Sensor%Sensor_Name,'MODIS') > 0) then
         call READ_MODIS(Segment_Number,Ierror_Level1b)
         if (Ierror_Level1b /= 0) return
      end if

      select case (trim(Sensor%Sensor_Name))
       case('GOES-IL-IMAGER','GOES-MP-IMAGER')
         call READ_GOES(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     Time_Since_Launch, &
                     AREAstr,NAVstr)

         if (Sensor%Chan_On_Flag_Default(1)==sym%YES) then
            call READ_DARK_COMPOSITE_COUNTS(Segment_Number, Goes_Xstride, &
                     Dark_Composite_Name,AREAstr,Two_Byte_Temp) 
            call CALIBRATE_GOES_DARK_COMPOSITE(Two_Byte_Temp,Time_Since_Launch,Ref_Ch1_Dark_Composite)
         end if

       case('GOES-IP-SOUNDER')
         call READ_GOES_SNDR(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     Time_Since_Launch, &
                     AREAstr,NAVstr)

       case('GOES-RU-IMAGER')
         call READ_ABI(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     AREAstr,NAVstr)

       case('SEVIRI')
       !--------  MSG/SEVIRI
         call READ_SEVIRI(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     AREAstr)
         call READ_DARK_COMPOSITE_COUNTS(Segment_Number,Seviri_Xstride, &
                     Dark_Composite_Name,AREAstr,Two_Byte_Temp) 
         call CALIBRATE_SEVIRI_DARK_COMPOSITE(Two_Byte_Temp,Ref_Ch1_Dark_Composite)

       case('MTSAT-IMAGER')
         call READ_MTSAT(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     Time_Since_Launch, &
                     AREAstr,NAVstr)
         call READ_DARK_COMPOSITE_COUNTS(Segment_Number,Mtsat_Xstride, &
                     Dark_Composite_Name,AREAstr,Two_Byte_Temp) 
         call CALIBRATE_MTSAT_DARK_COMPOSITE(Two_Byte_Temp,Ref_Ch1_Dark_Composite)

       case('FY2-IMAGER')
         call READ_FY(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     AREAstr,NAVstr)

       case('COMS-IMAGER')
         call READ_COMS(Segment_Number,Image%Level1b_Name, &
                     Image%Start_Doy, Image%Start_Time, &
                     AREAstr,NAVstr)

       case('AVHRR-1','AVHRR-2','AVHRR-3')
         call READ_AVHRR_LEVEL1B_DATA(trim(Level1b_Full_Name), &
              AVHRR_KLM_Flag,AVHRR_AAPP_Flag,Therm_Cal_1b,&
              Time_Since_Launch,Nrec_Avhrr_Header,Segment_Number)

       case('VIIRS')
#ifdef HDF5LIBS
         call READ_VIIRS_DATA (Segment_Number, trim(Image%Level1b_Name), Ierror_Level1b)
      
         ! If error reading, then go to next file
         if (Ierror_Level1b /= 0) return
#else
         print *, "No HDF5 library installed, stopping"
         stop
#endif

       case('VIIRS-NASA')
#ifdef HDF5LIBS
         call READ_VIIRS_NASA_DATA (Segment_Number, trim(Image%Level1b_Name), Ierror_Level1b)

         !--- If error reading, then go to next file
         if (Ierror_Level1b /= 0) return

         !--- read auxillary cloud mask
         if (Cloud_Mask_Aux_Flag /= sym%No_AUX_CLOUD_MASK) then 
           call DETERMINE_MVCM_NAME(Segment_Number)
           call READ_MVCM_DATA(Segment_Number)
         endif
#else
         print *, "No HDF5 library installed, stopping"
         stop
#endif

       case('AHI')
         call READ_AHI_DATA (Segment_Number, trim(Image%Level1b_Name), Ierror_Level1b)
      end select

      !--- IFF data (all sensors same format)
      if (index(Sensor%Sensor_Name,'IFF') > 0) then
         call READ_IFF_DATA (Segment_Number, trim(Level1b_Full_Name), Ierror_Level1b)

         ! If error reading, then go to next file
         if (Ierror_Level1b /= 0) return

         !---- determine auxilliary cloud mask name and read it
         if (Cloud_Mask_Aux_Flag /= sym%No_AUX_CLOUD_MASK) then
           if (Segment_Number == 1) print *,'Searching and reading MVCM'
           call DETERMINE_MVCM_NAME(Segment_Number)
           call READ_MVCM_DATA(Segment_Number)
         endif

      end if

   end subroutine READ_LEVEL1B_DATA


!----------------------------------------------------------------
! read the AHI constants into memory  - AKH: Move this to AHI Module 
!-----------------------------------------------------------------
subroutine READ_AHI_INSTR_CONSTANTS(Instr_Const_file)
 character(len=*), intent(in):: Instr_Const_file
 integer:: ios0, erstat
 integer:: Instr_Const_lun

 Instr_Const_lun = GET_LUN()

 open(unit=Instr_Const_lun,file=trim(Instr_Const_file),status="old",position="rewind",action="read",iostat=ios0)

 print *, EXE_PROMPT, MODULE_PROMPT, " Opening ", trim(Instr_Const_file)
 erstat = 0
 if (ios0 /= 0) then
    erstat = 19
    print *, EXE_PROMPT, MODULE_PROMPT, "Error opening AHI constants file, ios0 = ", ios0
    stop 19
 endif

  read(unit=Instr_Const_lun,fmt="(a3)") sat_name
  read(unit=Instr_Const_lun,fmt=*) Solar_Ch20
  read(unit=Instr_Const_lun,fmt=*) Ew_Ch20
  read(unit=Instr_Const_lun,fmt=*) planck_a1(20), planck_a2(20),planck_nu(20) ! Band 7
  !Note AHI has a 6.2 (Band 8), but MODIS doesn't have one
  read(unit=Instr_Const_lun,fmt=*) planck_a1(27), planck_a2(27),planck_nu(27) !Band 9
  read(unit=Instr_Const_lun,fmt=*) planck_a1(28), planck_a2(28),planck_nu(28) !Band 10
  read(unit=Instr_Const_lun,fmt=*) planck_a1(29), planck_a2(29),planck_nu(29) !Band 11
  read(unit=Instr_Const_lun,fmt=*) planck_a1(30), planck_a2(30),planck_nu(30) !Band 12
  !NOTE AHI as a 10.4 (Band 13), but MODIS doesn't have one
  read(unit=Instr_Const_lun,fmt=*) planck_a1(31), planck_a2(31),planck_nu(31) !Band 14
  read(unit=Instr_Const_lun,fmt=*) planck_a1(32), planck_a2(32),planck_nu(32) !Band 15
  read(unit=Instr_Const_lun,fmt=*) planck_a1(33), planck_a2(33),planck_nu(33) !Band 16
  read(unit=Instr_Const_lun,fmt=*) planck_a1(37), planck_a2(37),planck_nu(37) !Band 8
  read(unit=Instr_Const_lun,fmt=*) planck_a1(38), planck_a2(38),planck_nu(38) !Band 13
  close(unit=Instr_Const_lun)

  !-- convert solar flux in channel 20 to mean with units mW/m^2/cm^-1
  Solar_Ch20_Nu = 1000.0 * Solar_Ch20 / Ew_Ch20

end subroutine READ_AHI_INSTR_CONSTANTS

end module SENSOR_MODULE
