! $Id$
module ahi_clavrx_bridge
   
      use Pixel_Common , only : &
        Image &
      , Sensor &
      , Geo &
      , Nav &
      , Scan_Number &
      , Ancil_Data_Dir & 
      , Cloud_Mask_Aux_Flag &
      , Cloud_Mask_Aux_Read_Flag &
      , Cld_Mask_Aux &
      , Cld_Type_Aux &
      , Cld_Phase_Aux &
      , Scan_Time &
      , Gap_Pixel_Mask &
      , Ch 
   
    use constants, only: &
      int4 &
		, Missing_Value_Real4
      
      
    use calibration_constants, only: &
            Planck_Nu
   
   use planck, only: CONVERT_RADIANCE
   
   implicit none

contains

   subroutine read_ahi_data ( segment_number ,  file_ch01 , error_out )
      use planck
      use cx_read_ahi_mod
      
      implicit none
      
      integer , intent(in) :: segment_number
      character(len=*), intent(in) :: file_ch01
      integer(kind=int4), intent(out) :: error_out
      
      integer :: modis_chn_list (16)
      real :: nu_list (7:16)
      type ( ahi_config_type )   :: ahi_c
      type ( ahi_data_out_type ) :: ahi_data
      integer :: y_start
      integer :: c_seg_lines
      integer, parameter :: NUM_CHN_AHI = 16
      integer, parameter :: SYM_YES = 1, SYM_NO =0
      integer :: i_chn
      logical :: is_solar_channel(16)
      
      integer :: modis_chn
      integer :: i_line
      
     
      error_out = 0
      modis_chn_list = [ 3 , 4 , 1 , 2 , 6 , 7 , 20 , 37 ,  27 , 28,  &
                        29 , 30 , 38 , 31 , 32 , 33 ]
      
      ! List of solar constant values for radiance transformation
      nu_list(7:16) = [ Planck_Nu(20), Planck_Nu(37), Planck_Nu(27),  &
                        Planck_Nu(28), Planck_Nu(29), Planck_Nu(30),  &
                        Planck_Nu(38), Planck_Nu(31), Planck_Nu(32),  &
                        Planck_Nu(33)]
      
      
      is_solar_channel(7:16) = .false.
      is_solar_channel(1:6) = .true.
    
      ahi_c % file_base = file_ch01
      ahi_c % chan_on (:) = Sensor%Chan_On_Flag_Default ( modis_chn_list) == SYM_YES
    
      ahi_c % data_path = trim(Image%Level1b_Path)
   
      y_start = ( segment_number -1 ) * Image%Number_Of_Lines_Per_Segment
      c_seg_lines = Image%Number_Of_Lines_Per_Segment
   
      if ( (c_seg_lines + y_start) > Image%Number_Of_Lines ) then
         c_seg_lines = Image%Number_Of_Lines - y_start   
      end if
 
      ahi_c % h5_offset = [0,y_start]
      ahi_c % h5_count = [Image%Number_Of_Elements  , c_seg_lines] 
   
 
      call get_ahi_data ( ahi_c, ahi_data )
  
      nav % lat_1b(:,1:c_seg_lines)    = ahi_data % geo % lat
      nav % lon_1b(:,1:c_seg_lines)    = ahi_data % geo % lon
      
      geo % sataz(:,1:c_seg_lines)        = ahi_data % geo % sataz
      geo % satzen(:,1:c_seg_lines)       = ahi_data % geo % satzen
      geo % solaz (:,1:c_seg_lines)       = ahi_data % geo % solaz 
      geo % solzen (:,1:c_seg_lines)      = ahi_data % geo % solzen 
      geo % relaz (:,1:c_seg_lines)       = ahi_data % geo % relaz
      geo % glintzen (:,1:c_seg_lines)    = ahi_data % geo % glintzen
      geo % scatangle (:,1:c_seg_lines)   = ahi_data % geo % scatangle
      ! nav % ascend (1:c_seg_lines)     = ahi_data % geo % ascend
  
      do i_chn = 1, NUM_CHN_AHI

         modis_chn = modis_chn_list (i_chn)
         
         if ( .not. ahi_data % chn ( i_chn ) % is_read ) then
            sensor % chan_on_flag_per_line (modis_chn ,1:c_seg_lines) = SYM_NO 
            cycle   
         end if
      
         if ( .not. ahi_c % chan_on(i_chn) ) cycle
      
         if ( is_solar_channel ( i_chn) ) then
            ch(modis_chn) % Ref_Toa ( : ,1:c_seg_lines)  =  ahi_data % chn (i_chn) % ref
            
         else
            if ( modis_chn > 38) then
               cycle
            end if
            
            ch(modis_chn) % Rad_Toa ( : ,1:c_seg_lines)  =  ahi_data % chn (i_chn) % rad
            call convert_radiance ( ch(modis_chn) % Rad_Toa ( : ,1:c_seg_lines) , nu_list(i_chn), -999. )
            call compute_bt_array ( ch(modis_chn)%bt_toa ( : ,1:c_seg_lines) , ch(modis_chn)%rad_toa ( : ,1:c_seg_lines) &
                , modis_chn ,MISSING_VALUE_REAL4 )
 
         end if   
      
      end do
    
   
      Image%Number_Of_Lines_Read_This_Segment = c_seg_lines
      scan_number = [(i_line , i_line = y_start+ 1 , y_start+ Image%Number_Of_Lines_Per_Segment + 1 , 1)]

      nav % ascend = 0 
      Cloud_Mask_Aux_Read_Flag = 0 
      
     
      
      ! - update time
      call ahi_data % time_start_obj % get_date ( msec_of_day = Image%Start_Time  )
      call ahi_data % time_end_obj % get_date ( msec_of_day = Image%End_Time  )     
           
      scan_time(1:c_seg_lines)   = Image%Start_Time + &
                                 ( scan_number * (Image%End_Time - Image%Start_Time)) &
                                 / Image%Number_Of_Lines
      
      call ahi_data % deallocate_all
 
 
   end subroutine read_ahi_data

end module ahi_clavrx_bridge