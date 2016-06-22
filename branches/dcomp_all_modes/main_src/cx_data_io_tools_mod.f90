! $Id$
!  deals with hdf tools w


module cx_data_io_tools_mod
      use cx_hdf_write_mod, only:  &
      hdf_file_open &
      , create_sds &
      , compress_sds &
      , write_sds &
      , add_att &
      , close_sds &
      , close_file
      
         use cx_hdf_read_mod, only: &
         hdf_data &
         , hdf_att &
         , hdf_get_file_att
   
   use string_functions
contains

   subroutine copy_global_attributes ( file_in, file_out, exclude_list)
   
  
      
      implicit none
      
      character(len=*), intent(in) :: file_in
      character(len=*), intent(in) :: file_out
      character(len = *), intent(in), optional :: exclude_list(:)
      type(hdf_data) :: data
      integer :: natt
      type(hdf_att), allocatable :: attrs(:)
      integer :: i, j, istatus, id_out
      logical :: next_attr
      character(len =:), allocatable :: string_dum
      
      istatus = hdf_get_file_att (trim(file_in),natt,attrs)
      id_out = hdf_file_open ( trim(file_out))
      
      do i = 1, natt
         next_attr = .false.
         if (present(exclude_list) ) then
            do j = 1, size(exclude_list)
               if (trim(exclude_list(j)) .eq. trim(attrs(i) % name) ) next_attr = .true.            
            end do
            
            
            if ( next_attr) cycle
         end if
         
         data = attrs(i) % data
         
         
          if (allocated(data%c1values)) then
            allocate (character(data%dimsize(1)) :: string_dum)
            string_dum = copy_a2s(data%c1values)
            call add_att ( id_out,attrs(i) % name , string_dum)
            if ( allocated (string_dum)) deallocate ( string_dum)
               
          end if
          if (allocated(data%i1values)) call add_att ( id_out, attrs(i) % name, data%i1values(1))
          if (allocated(data%i2values)) call add_att ( id_out, attrs(i) % name, data%i2values(1))
          if (allocated(data%i4values)) call add_att ( id_out, attrs(i) % name, data%i4values(1))
      end do
      print*,'closing: ',id_out
      call close_file(id_out)
      
      
   end subroutine copy_global_attributes

end module cx_data_io_tools_mod
