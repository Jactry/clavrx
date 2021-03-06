!$Id$
!------------------------------------------------------------------------------
!  NOAA AWG Cloud Height Algorithm (ACHA) Bridge Code
!
!  This module houses the routines that serve as a bridge between
!  the CLAVR-x processing system and the ACHA code.
!
!------------------------------------------------------------------------------
module ACHA_CLAVRX_BRIDGE

 use AWG_CLOUD_HEIGHT
 use ACHA_COMP
 use ACHA_SHADOW
 use ACHA_SERVICES_MOD
 use CLAVRX_MESSAGE_MODULE, only: MESG
   
 implicit none

 public :: AWG_CLOUD_HEIGHT_BRIDGE
 private:: SET_SYMBOL, SET_INPUT, SET_OUTPUT, NULL_INPUT, NULL_OUTPUT
 private:: SET_DIAG, NULL_DIAG

 !--------------------------------------------------------------------
 ! define structures that will be arguments to ACHA
 !--------------------------------------------------------------------
 type(acha_symbol_struct), private :: Symbol
 type(acha_input_struct), private :: Input
 type(acha_output_struct), private :: Output
 type(acha_diag_struct), private :: Diag

 contains

!----------------------------------------------------------------------
! ACHA BRIDGE SUBROUTINE
!---------------------------------------------------------------------- 
 subroutine AWG_CLOUD_HEIGHT_BRIDGE()
 
   implicit none

   logical, save:: First_Call = .true.

   if (First_Call .eqv. .true.) then
       call MESG('ACHA starts ', color = 46)
   endif

   !---null pointers before filling them
   call NULL_INPUT()
   call NULL_OUTPUT()

   !-------------------------------------------
   !--- initialize structures
   !-------------------------------------------

   !--- store integer values
   call SET_INPUT()

   !---- initalize Output structure
   call SET_OUTPUT()
  
   !----set symbols to local values
   call SET_SYMBOL()

   !---- initialize diagnostic structure
   call SET_DIAG()

   !-----------------------------------------------------------------------
   !--- Call to AWG CLoud Height Algorithm (ACHA)
   !-----------------------------------------------------------------------

   call AWG_CLOUD_HEIGHT_ALGORITHM(Input, Symbol, Output)
   !call AWG_CLOUD_HEIGHT_ALGORITHM(Input, Symbol, Output, Diag)

   !-----------------------------------------------------------------------
   !--- Call algorithm to make ACHA optical and microphysical properties
   !-----------------------------------------------------------------------
   call ACHA_COMP_ALGORITHM(Input, Symbol, Output)

   !-----------------------------------------------------------------------
   !--- Call to Geometrical Shadow Algorithm
   !-----------------------------------------------------------------------
   call CLOUD_SHADOW_RETR (  &
           ACHA%Zc &
         , Geo%Solaz &
         , Geo%Solzen &
         , Nav%Lat &
         , Nav%Lon &
         , Nav%Lat_Pc &
         , Nav%Lon_Pc &
         , Shadow_Mask ) 

   !---- copy shadow result into cloud mask test bits
   where (Shadow_Mask == 1 .and. CLDMASK%Cld_Mask == 0 )  
           CLDMASK%Cld_Test_Vector_Packed ( 2 , :, : )  = ibset (CLDMASK%Cld_Test_Vector_Packed ( 2 , :, : )  , 6 )
   end where

   !-----------------------------------------------------------------------
   !--- Null pointers after algorithm is finished
   !-----------------------------------------------------------------------
   call NULL_INPUT()
   call NULL_OUTPUT()

   !-----------------------------------------------------------------------
   !---  read CVS Tag from ACHA and store in global variable for output
   !-----------------------------------------------------------------------
   call SET_ACHA_VERSION(Acha_Version)
  
   First_Call = .false.

 end subroutine AWG_CLOUD_HEIGHT_BRIDGE

 !-----------------------------------------------------------------------------
 ! Nullify the pointers holding input 
 !-----------------------------------------------------------------------------
 subroutine NULL_INPUT()
     Input%Invalid_Data_Mask =>  null()
     Input%Bt_67um =>  null()
     Input%Bt_85um =>  null()
     Input%Bt_11um =>  null()
     Input%Bt_12um =>  null()
     Input%Bt_133um =>  null()
     Input%Rad_67um =>  null()
     Input%Rad_85um =>  null()
     Input%Rad_11um =>  null()
     Input%Rad_12um =>  null()
     Input%Rad_133um =>  null()
     Input%Rad_136um =>  null()
     Input%Rad_139um =>  null()
     Input%Rad_142um =>  null()
     Input%Cosine_Zenith_Angle =>  null()
     Input%Sensor_Zenith_Angle =>  null()
     Input%Sensor_Azimuth_Angle =>  null()
     Input%Surface_Temperature => null()
     Input%Surface_Air_Temperature =>  null()
     Input%Tropopause_Temperature =>  null()
     Input%Tropopause_Height =>  null()
     Input%Tropopause_Pressure =>  null()
     Input%Surface_Pressure =>  null()
     Input%Surface_Elevation =>  null()
     Input%Latitude =>  null()
     Input%Longitude =>  null()
     Input%Rad_Clear_67um =>  null()
     Input%Rad_Clear_85um =>  null()
     Input%Rad_Clear_11um =>  null()
     Input%Rad_Clear_12um =>  null()
     Input%Rad_Clear_133um =>  null()
     Input%Rad_Clear_136um =>  null()
     Input%Rad_Clear_139um =>  null()
     Input%Rad_Clear_142um =>  null()
     Input%Surface_Emissivity_39um =>  null()
     Input%Surface_Emissivity_11um =>  null()
     Input%Surface_Emissivity_12um =>  null()
     Input%Surface_Emissivity_85um =>  null()
     Input%Surface_Emissivity_133um =>  null()
     Input%Surface_Emissivity_136um =>  null()
     Input%Surface_Emissivity_139um =>  null()
     Input%Surface_Emissivity_142um =>  null()
     Input%Surface_Emissivity_67um =>  null()
     Input%Snow_Class =>  null()
     Input%Surface_Type =>  null()
     Input%Cloud_Mask =>  null()
     Input%Cloud_Probability => null()
     Input%Cloud_Type =>  null()
     Input%Elem_Idx_Nwp =>   null()
     Input%Line_Idx_Nwp =>  null()
     Input%Elem_Idx_Opposite_Corner_NWP =>  null()
     Input%Line_Idx_Opposite_Corner_NWP =>  null()
     Input%Viewing_Zenith_Angle_Idx_Rtm =>  null()
     Input%Latitude_Interp_Weight_NWP =>  null()
     Input%Longitude_Interp_Weight_NWP =>  null()
     Input%Elem_Idx_LRC_Input =>  null()
     Input%Line_Idx_LRC_Input =>   null()
     Input%Tc_Cirrus_Sounder =>   null()
 end subroutine NULL_INPUT
 !-----------------------------------------------------------------------------
 ! Nullify the pointers holding input 
 !-----------------------------------------------------------------------------
 subroutine NULL_DIAG()
     Diag%Array_1 =>  null()
     Diag%Array_2 =>  null()
     Diag%Array_3 =>  null()
 end subroutine NULL_DIAG
 !-----------------------------------------------------------------------------
 ! Nullify the pointers holding output to ACHA
 !-----------------------------------------------------------------------------
 subroutine NULL_OUTPUT()
     Output%Latitude_Pc =>  null()
     Output%Longitude_Pc =>  null()
     Output%Tc =>  null()
     Output%Ec =>  null()
     Output%Beta =>  null()
     Output%Pc =>  null()
     Output%Zc =>  null()
     Output%Tau =>  null()
     Output%Reff =>  null()
     Output%Tc_Uncertainty =>  null()
     Output%Ec_Uncertainty =>  null()
     Output%Beta_Uncertainty =>  null()
     Output%Pc_Uncertainty =>  null()
     Output%Zc_Uncertainty =>  null()
     Output%Lower_Pc =>  null()
     Output%Lower_Tc =>  null()
     Output%Lower_Zc =>  null()
     Output%Cost =>  null()
     Output%Qf =>  null()
     Output%OE_Qf =>  null()
     Output%Packed_Qf =>  null()
     Output%Packed_Meta_Data =>  null()
     Output%Processing_Order  =>  null()
     Output%Inversion_Flag  =>  null()
     Output%Ec_67um =>  null()
     Output%Ec_85um =>  null()
     Output%Ec_11um =>  null()
     Output%Ec_12um =>  null()
     Output%Ec_133um =>  null()
     Output%Cloud_Type =>  null()
 end subroutine NULL_OUTPUT
 !-----------------------------------------------------------------------------
 ! Copy needed Symbol elements
 !-----------------------------------------------------------------------------
 subroutine SET_SYMBOL()
   Symbol%CLOUDY = sym%CLOUDY
   Symbol%PROB_CLOUDY = sym%PROB_CLOUDY
   Symbol%PROB_CLEAR = sym%PROB_CLEAR
   Symbol%CLEAR = sym%CLEAR

   Symbol%NO = sym%NO
   Symbol%YES = sym%YES

   Symbol%WATER_SFC = sym%WATER_SFC
   Symbol%EVERGREEN_NEEDLE_SFC = sym%EVERGREEN_NEEDLE_SFC
   Symbol%EVERGREEN_BROAD_SFC = sym%EVERGREEN_BROAD_SFC
   Symbol%DECIDUOUS_NEEDLE_SFC = sym%DECIDUOUS_NEEDLE_SFC
   Symbol%DECIDUOUS_BROAD_SFC = sym%DECIDUOUS_BROAD_SFC
   Symbol%MIXED_FORESTS_SFC = sym%MIXED_FORESTS_SFC
   Symbol%WOODLANDS_SFC = sym%WOODLANDS_SFC
   Symbol%WOODED_GRASS_SFC = sym%WOODED_GRASS_SFC
   Symbol%CLOSED_SHRUBS_SFC = sym%CLOSED_SHRUBS_SFC
   Symbol%OPEN_SHRUBS_SFC = sym%OPEN_SHRUBS_SFC
   Symbol%GRASSES_SFC = sym%GRASSES_SFC
   Symbol%CROPLANDS_SFC = sym%CROPLANDS_SFC
   Symbol%BARE_SFC = sym%BARE_SFC
   Symbol%URBAN_SFC = sym%URBAN_SFC

   Symbol%SHALLOW_OCEAN = sym%SHALLOW_OCEAN
   Symbol%LAND = sym%LAND
   Symbol%COASTLINE = sym%COASTLINE
   Symbol%SHALLOW_INLAND_WATER = sym%SHALLOW_INLAND_WATER
   Symbol%EPHEMERAL_WATER = sym%EPHEMERAL_WATER
   Symbol%DEEP_INLAND_WATER = sym%DEEP_INLAND_WATER
   Symbol%MODERATE_OCEAN = sym%MODERATE_OCEAN
   Symbol%DEEP_OCEAN = sym%DEEP_OCEAN

   Symbol%NO_SNOW = sym%NO_SNOW
   Symbol%SEA_ICE = sym%SEA_ICE
   Symbol%SNOW = sym%SNOW

   Symbol%CLEAR_TYPE = sym%CLEAR_TYPE
   Symbol%PROB_CLEAR_TYPE = sym%PROB_CLEAR_TYPE
   Symbol%FOG_TYPE = sym%FOG_TYPE
   Symbol%WATER_TYPE = sym%WATER_TYPE
   Symbol%SUPERCOOLED_TYPE = sym%SUPERCOOLED_TYPE
   Symbol%MIXED_TYPE = sym%MIXED_TYPE
   Symbol%OPAQUE_ICE_TYPE = sym%OPAQUE_ICE_TYPE
   Symbol%TICE_TYPE = sym%TICE_TYPE
   Symbol%CIRRUS_TYPE = sym%CIRRUS_TYPE
   Symbol%OVERLAP_TYPE = sym%OVERLAP_TYPE
   Symbol%OVERSHOOTING_TYPE = sym%OVERSHOOTING_TYPE
   Symbol%UNKNOWN_TYPE = sym%UNKNOWN_TYPE
   Symbol%DUST_TYPE = sym%DUST_TYPE
   Symbol%SMOKE_TYPE = sym%SMOKE_TYPE
   Symbol%FIRE_TYPE = sym%FIRE_TYPE

   Symbol%CLEAR_PHASE = sym%CLEAR_PHASE
   Symbol%WATER_PHASE = sym%WATER_PHASE
   Symbol%SUPERCOOLED_PHASE = sym%SUPERCOOLED_PHASE
   Symbol%MIXED_PHASE = sym%MIXED_PHASE
   Symbol%ICE_PHASE = sym%ICE_PHASE
   Symbol%UNKNOWN_PHASE = sym%UNKNOWN_PHASE
 end subroutine SET_SYMBOL

 subroutine SET_OUTPUT()
   Output%Latitude_Pc => Nav%Lat_Pc
   Output%Longitude_Pc => Nav%Lon_Pc
   Output%Tc => ACHA%Tc
   Output%Ec => ACHA%Ec
   Output%Beta => ACHA%Beta
   Output%Pc => ACHA%Pc
   Output%Zc => ACHA%Zc
   Output%Tau => ACHA%Tau
   Output%Reff => ACHA%Reff
   Output%Tc_Uncertainty => ACHA%Tc_Uncertainty
   Output%Ec_Uncertainty => ACHA%Ec_Uncertainty
   Output%Beta_Uncertainty => ACHA%Beta_Uncertainty
   Output%Pc_Uncertainty => ACHA%Pc_Uncertainty
   Output%Zc_Uncertainty => ACHA%Zc_Uncertainty
   Output%Lower_Tc_Uncertainty => ACHA%Lower_Tc_Uncertainty
   Output%Lower_Zc_Uncertainty => ACHA%Lower_Zc_Uncertainty
   Output%Lower_Pc_Uncertainty => ACHA%Lower_Pc_Uncertainty
   Output%Lower_Pc => ACHA%Lower_Pc
   Output%Lower_Tc => ACHA%Lower_Tc
   Output%Lower_Zc => ACHA%Lower_Zc
   Output%Cost  => ACHA%Cost
   Output%Qf => ACHA%Quality_Flag
   Output%OE_Qf => ACHA%OE_Quality_Flags
   Output%Packed_Qf => ACHA%Packed_Quality_Flags
   Output%Packed_Meta_Data => ACHA%Packed_Meta_Data_Flags
   Output%Processing_Order  => ACHA%Processing_Order
   Output%Inversion_Flag  => ACHA%Inversion_Flag
   Output%Ec_67um => ACHA%Ec_67um
   Output%Ec_85um => ACHA%Ec_85um
   Output%Ec_11um => ACHA%Ec_11um
   Output%Ec_12um => ACHA%Ec_12um
   Output%Ec_133um => ACHA%Ec_133um
   Output%Cloud_Type => ACHA%Cloud_Type
 end subroutine SET_OUTPUT
!--------------------------------------------------------
 subroutine SET_INPUT()

   Input%ACHA_Mode_Flag_In = ACHA%Mode
   Input%Number_of_Elements = Image%Number_Of_Elements
   Input%Number_of_Lines = Image%Number_Of_Lines_Per_Segment
   Input%Smooth_Nwp_Fields_Flag = Smooth_Nwp_Flag
   Input%Process_Undetected_Cloud_Flag = Process_Undetected_Cloud_Flag
   Input%Sensor_Resolution_KM = Sensor%Spatial_Resolution_Meters/1000.0
   Input%WMO_Id = Sensor%WMO_Id
   Input%Chan_Idx_67um = 27      !channel number for 6.7
   Input%Chan_Idx_85um = 29      !channel number for 8.5
   Input%Chan_Idx_11um = 31      !channel number for 11
   Input%Chan_Idx_12um = 32      !channel number for 12
   Input%Chan_Idx_136um = 34     !channel number for 13.6
   Input%Chan_Idx_139um = 35     !channel number for 13.9
   Input%Chan_Idx_142um = 36     !channel number for 14.2
   Input%Chan_On_67um = Sensor%Chan_On_Flag_Default(27)
   Input%Chan_On_85um = Sensor%Chan_On_Flag_Default(29)
   Input%Chan_On_11um = Sensor%Chan_On_Flag_Default(31)
   Input%Chan_On_12um = Sensor%Chan_On_Flag_Default(32)
   Input%Chan_On_136um = Sensor%Chan_On_Flag_Default(34)
   Input%Chan_On_139um = Sensor%Chan_On_Flag_Default(35)
   Input%Chan_On_142um = Sensor%Chan_On_Flag_Default(36)
   Input%Invalid_Data_Mask => Bad_Pixel_Mask
   Input%Bt_67um => ch(27)%Bt_Toa
   Input%Bt_85um => ch(29)%Bt_Toa
   Input%Bt_11um => ch(31)%Bt_Toa
   Input%Bt_12um => ch(32)%Bt_Toa
   Input%Bt_136um => ch(34)%Bt_Toa
   Input%Bt_139um => ch(35)%Bt_Toa
   Input%Bt_142um => ch(36)%Bt_Toa
   Input%Rad_67um => ch(27)%Rad_Toa
   Input%Rad_85um => ch(29)%Rad_Toa
   Input%Rad_11um => ch(31)%Rad_Toa
   Input%Rad_12um => ch(32)%Rad_Toa
   Input%Rad_133um => ch(33)%Rad_Toa
   Input%Rad_136um => ch(34)%Rad_Toa
   Input%Rad_139um => ch(35)%Rad_Toa
   Input%Rad_142um => ch(36)%Rad_Toa
   Input%Cosine_Zenith_Angle => Geo%Coszen
   Input%Sensor_Zenith_Angle => Geo%Satzen
   Input%Sensor_Azimuth_Angle => Geo%Sataz
   Input%Surface_Temperature =>Tsfc_Nwp_Pix
   Input%Surface_Air_Temperature => Tair_Nwp_Pix
   Input%Tropopause_Temperature => Ttropo_Nwp_Pix
   Input%Tropopause_Height => Ztropo_Nwp_Pix
   Input%Tropopause_Pressure => Ptropo_Nwp_Pix
   Input%Surface_Pressure => Psfc_Nwp_Pix
   Input%Surface_Elevation => Sfc%Zsfc
   Input%Latitude => Nav%Lat
   Input%Longitude => Nav%Lon
   Input%Rad_Clear_67um => ch(27)%Rad_Toa_Clear
   Input%Rad_Clear_85um => ch(29)%Rad_Toa_Clear
   Input%Rad_Clear_11um => ch(31)%Rad_Toa_Clear
   Input%Rad_Clear_12um => ch(32)%Rad_Toa_Clear
   Input%Rad_Clear_136um => ch(34)%Rad_Toa_Clear
   Input%Rad_Clear_139um => ch(35)%Rad_Toa_Clear
   Input%Rad_Clear_142um => ch(36)%Rad_Toa_Clear
   Input%Surface_Emissivity_39um => ch(20)%Sfc_Emiss
   Input%Surface_Emissivity_11um => ch(31)%Sfc_Emiss
   Input%Surface_Emissivity_12um => ch(32)%Sfc_Emiss
   Input%Surface_Emissivity_85um => ch(29)%Sfc_Emiss
   Input%Surface_Emissivity_133um => ch(33)%Sfc_Emiss
   Input%Surface_Emissivity_136um => ch(33)%Sfc_Emiss
   Input%Surface_Emissivity_139um => ch(33)%Sfc_Emiss
   Input%Surface_Emissivity_142um => ch(33)%Sfc_Emiss
   Input%Surface_Emissivity_67um => ch(27)%Sfc_Emiss
   Input%Snow_Class => Sfc%Snow
   Input%Surface_Type => Sfc%Sfc_Type
   Input%Cloud_Mask => CLDMASK%Cld_Mask
   Input%Cloud_Probability => CLDMASK%Posterior_Cld_Probability
   Input%Cloud_Type => Cld_Type
   Input%Elem_Idx_Nwp =>  I_Nwp
   Input%Line_Idx_Nwp => J_Nwp
   Input%Elem_Idx_Opposite_Corner_NWP => I_Nwp_x
   Input%Line_Idx_Opposite_Corner_NWP => J_Nwp_x
   Input%Viewing_Zenith_Angle_Idx_Rtm => Zen_Idx_Rtm
   Input%Latitude_Interp_Weight_NWP => Lat_Nwp_Fac
   Input%Longitude_Interp_Weight_NWP => Lon_Nwp_Fac
   Input%Elem_Idx_LRC_Input => I_LRC
   Input%Line_Idx_LRC_Input =>  J_LRC
   Input%Tc_Cirrus_Sounder =>  Tc_Cirrus_Background

   !-------------------------------------------------------------------
   ! handle use of ch45 instead of ch33 for MODE 9
   !-------------------------------------------------------------------
   if (ACHA%Mode == 9) then
     Input%Chan_Idx_133um = 45     !channel number for 13.3
   else
     Input%Chan_Idx_133um = 33     !channel number for 13.3
   endif

   Input%Chan_On_133um = Sensor%Chan_On_Flag_Default(Input%Chan_Idx_133um)
   Input%Bt_133um => ch(Input%Chan_Idx_133um)%Bt_Toa
   Input%Rad_Clear_133um => ch(Input%Chan_Idx_133um)%Rad_Toa_Clear

   Input%Chan_On_136um = Sensor%Chan_On_Flag_Default(Input%Chan_Idx_136um)
   Input%Chan_On_139um = Sensor%Chan_On_Flag_Default(Input%Chan_Idx_139um)
   Input%Chan_On_142um = Sensor%Chan_On_Flag_Default(Input%Chan_Idx_142um)

 end subroutine SET_INPUT
!----------------------------------------------------------------------
!
!----------------------------------------------------------------------
 subroutine SET_DIAG
     Diag%Array_1 => Diag_Pix_Array_1 
     Diag%Array_2 => Diag_Pix_Array_2 
     Diag%Array_3 => Diag_Pix_Array_3 
 end subroutine SET_DIAG

end module ACHA_CLAVRX_BRIDGE
