!--------------------------------------------------------------------------------------
! Clouds from AVHRR Extended (CLAVR-x) 1b PROCESSING SOFTWARE Version 5.3
!
! NAME: file_utility.f90 (src)
!       file_utility (program)
!
! PURPOSE: Module containing generic file utility routines
!
! DESCRIPTION: 
!
! AUTHORS:
!        Paul van Delst, CIMSS@NOAA/NCEP 12-Jul-2000
!        pvandelst@ncep.noaa.gov
!
! COPYRIGHT
!  Copyright (C) 2000 Paul van Delst
!
! REVISION HISTORY:
!
!  This program is free software; you can redistribute it and/or
!  modify it under the terms of the GNU General Public License
!  as published by the Free Software Foundation; either version 2
!  of the License, or (at your option) any later version.
!
!  This program is distributed in the hope that it will be useful,
!  but WITHOUT ANY WARRANTY; without even the implied warranty of
!  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!  GNU General Public License for more details.
!
!  You should have received a copy of the GNU General Public License
!  along with this program; if not, write to the Free Software
!  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
!
! CATEGORY:
!       NCEP RTM
!
! CALLING SEQUENCE:
!       USE file_utility
!
! OUTPUTS:
!       None
!
! MODULES:
!       None.
!
! CONTAINS:
!       get_lun:     PUBLIC function to return a free logical unit number for
!                    file access.
!
!       file_exists: PUBLIC function to determine if a named file exists.
!
! EXTERNALS:
!       None
!
! COMMON BLOCKS:
!       None.
!
! SIDE EFFECTS:
!       None.
!
! RESTRICTIONS:
!       None.
!
!--------------------------------------------------------------------------------------

MODULE file_utility


  ! ---------------------------
  ! Disable all implicit typing
  ! ---------------------------

  IMPLICIT NONE


  ! ------------------
  ! Default visibility
  ! ------------------

  PRIVATE


  ! ----------------------------------
  ! Explicit visibility of subprograms
  ! ----------------------------------

  PUBLIC :: get_lun, &
            file_exists


CONTAINS


!------------------------------------------------------------------------------
!S+
! NAME:
!       get_lun
!
! PURPOSE:
!       PUBLIC function to obtain a free logical unit number for file access
!
! CALLING SEQUENCE:
!       result = get_lun()
!
! INPUT ARGUMENTS:
!       None.
!
! OUTPUT ARGUMENTS:
!       None.
!
! FUNCTION RESULT:
!       Function returns a default integer that can be used as a logical unit
!       number to open and access a file.
!
! CALLS:
!       None.
!
! EXTERNALS:
!       None
!
! COMMON BLOCKS:
!       None.
!
! SIDE EFFECTS:
!       None known.
!
! RESTRICTIONS:
!       None.
!
! PROCEDURE:
!       The search for a free logical unit number begins at 10. The logical
!       unit number if tested to see if it is connected to an open file. If
!       so, it is incremented by 1. This is repeated until a free logical
!       unit number is found.
!S-
!------------------------------------------------------------------------------

  FUNCTION get_lun() RESULT( lun )


    ! -----------------
    ! Type declarations
    ! -----------------
 
    INTEGER :: lun
    LOGICAL :: file_open


    ! --------------------------------------------
    ! Initialise logical unit number and file_open
    ! --------------------------------------------

    lun = 9
    file_open = .TRUE.


    ! ------------------------------
    ! Start open loop for lun search
    ! ------------------------------

    lun_search: DO

      ! -- Increment logical unit number
      lun = lun + 1

      ! -- Check if file is open
      INQUIRE( lun, OPENED = file_open )

      ! -- Is this lun available?
      IF ( .NOT. file_open ) EXIT lun_search

    END DO lun_search

  END FUNCTION get_lun

!------------------------------------------------------------------------------
!S+
! NAME:
!       file_exists
!
! PURPOSE:
!       PUBLIC function to determine if a file exists.
!
! CALLING SEQUENCE:
!       result = file_exists( file_name )
!
! INPUT ARGUMENTS:
!       file_name:  Name of the file the existence of which is to be determined.
!                   UNITS:      None
!                   TYPE:       Character
!                   DIMENSION:  Scalar
!                   ATTRIBUTES: INTENT( IN )
!
! OUTPUT ARGUMENTS:
!       None.
!
! FUNCTION RESULT:
!       Function returns a logical result.
!
!       result = .TRUE.  => file exists
!              = .FALSE. => file does not exist
!
! CALLS:
!       None.
!
! EXTERNALS:
!       None
!
! COMMON BLOCKS:
!       None.
!
! SIDE EFFECTS:
!       None known.
!
! RESTRICTIONS:
!       None.
!
! PROCEDURE:
!       The file name is INQUIREd by FILE keyword. The result of the inquiry
!       is the function result.
!S-
!------------------------------------------------------------------------------

  FUNCTION file_exists( file_name ) RESULT ( existence )


    ! -----------------
    ! Type declarations
    ! -----------------
 
    CHARACTER( * ), INTENT( IN ) :: file_name
    LOGICAL :: existence


    ! ---------------
    ! Inquire by name
    ! ---------------

    INQUIRE( FILE = file_name, EXIST = existence )

  END FUNCTION file_exists

END MODULE file_utility


!-------------------------------------------------------------------------------
!                          -- MODIFICATION HISTORY --
!-------------------------------------------------------------------------------
!
! $Id$
!
! $Date: 2014/01/26 04:48:33 $
!
! $Revision: 1.1.1.1.12.1 $
!
! $State: Exp $
!
! $Log: file_utility.f90,v $
! Revision 1.1.1.1.12.1  2014/01/26 04:48:33  heidinger
! updated
!
! Revision 1.1.1.1.6.1  2014/01/24 21:48:00  mhiley
! Format headers according to CDR General Software Coding Standards
!
! Revision 1.1.1.1  2008/10/31 19:52:02  heidinger
! experimental clavrx code
!
! Revision 1.1.1.1  2008/07/18 15:08:20  heidinger
! Clouds from AVHRR Extended
!
! Revision 1.1.1.1  2007/07/11 21:20:26  heidinger
! CLAVR-x v4_4 root
!
! Revision 1.1.1.1  2007/04/17 20:34:10  mpav
! GEOCAT V0.2, Algorithms V0.1
!
! Revision 1.4  2006/04/28 18:57:58  wstraka
! geocat reads in low/hi-res elevation, SST climatology
!
! Revision 1.3  2006/04/27 16:49:40  wstraka
! Newest revision includes improved memory usage for getting image data
!
! Revision 1.2.1.1  2006/04/27 16:38:29  wstraka
! Everything but GFS has ABI associations and var associations
!
! Revision 1.2  2006/04/26 18:23:41  wstraka
! Everything but GFS has ABI associations and var associations
!
! Revision 1.1.1.1  2006/04/25 20:01:37  wstraka
! Initial geocat folder creation
!
! Revision 1.1  2004/08/23 16:09:02  heidinger
! no message
!
! Revision 1.3  2000/08/31 19:36:32  paulv
! - Added documentation delimiters.
! - Updated documentation headers.
!
! Revision 1.2  2000/08/24 15:33:42  paulv
! - In the GET_LUN subprogram, the loop to search for a free unit number
!   was changed from:
!
!     DO WHILE ( file_open )
!       ...search
!     END DO
!
!   to
!
!     lun_search: DO
!       ...search
!       IF ( .NOT. file_open ) EXIT lun_search
!     END DO lun_search
!
!   The earlier version is a deprecated use of the DO with WHILE.
!
! - The subprogram FILE_EXISTS was added. Note that the INQUIRE statement
!   required the FILE =  keyword to work. Simply using the file name in
!   the INQUIRE returned an error (compiler assumed it was an inquire by
!   unit number?)
! - Updated module and subprogram documentation.
!
! Revision 1.1  2000/07/12 16:08:10  paulv
! Initial checked in version
!
!
!

