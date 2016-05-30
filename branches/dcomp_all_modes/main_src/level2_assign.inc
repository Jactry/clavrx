select case(trim(name))
case("scan_line_number")
   if (allocated ( scan_number)) then
      data_dim1_dtype3 = scan_number(Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("scan_line_time")
   if (allocated ( utc_scan_time_hours)) then
      data_dim1_dtype4 = utc_scan_time_hours(Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("bad_scan_line_flag")
   if (allocated ( bad_scan_flag)) then
      data_dim1_dtype1 = bad_scan_flag(Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("asc_des_flag")
   if (allocated ( nav%ascend)) then
      data_dim1_dtype1 = nav%ascend(Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("bad_pixel_mask")
   if (allocated ( bad_pixel_mask)) then
      data_dim2_dtype1 = bad_pixel_mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("gap_pixel_mask")
   if (allocated ( gap_pixel_mask)) then
      data_dim2_dtype1 = gap_pixel_mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("diagnostic_1")
   if (allocated ( diag_pix_array_1)) then
      data_dim2_dtype4 = diag_pix_array_1(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("diagnostic_2")
   if (allocated ( diag_pix_array_2)) then
      data_dim2_dtype4 = diag_pix_array_2(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("diagnostic_3")
   if (allocated ( diag_pix_array_3)) then
      data_dim2_dtype4 = diag_pix_array_3(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("packed_pixel_meta_data")
case("latitude")
   if (allocated ( nav%lat)) then
      data_dim2_dtype2 = nav%lat(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("longitude")
   if (allocated ( nav%lon)) then
      data_dim2_dtype2 = nav%lon(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("latitude_pc")
   if (allocated ( nav%lat_pc)) then
      data_dim2_dtype2 = nav%lat_pc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("longitude_pc")
   if (allocated ( nav%lon_pc)) then
      data_dim2_dtype2 = nav%lon_pc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("sensor_zenith_angle")
   if (allocated ( geo%satzen)) then
      data_dim2_dtype1 = geo%satzen(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("solar_zenith_angle")
   if (allocated ( geo%solzen)) then
      data_dim2_dtype1 = geo%solzen(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("relative_azimuth_angle")
   if (allocated ( geo%relaz)) then
      data_dim2_dtype1 = geo%relaz(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("solar_azimuth_angle")
   if (allocated ( geo%solaz)) then
      data_dim2_dtype1 = geo%solaz(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("sensor_azimuth_angle")
   if (allocated ( geo%sataz)) then
      data_dim2_dtype1 = geo%sataz(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("glint_zenith_angle")
   if (allocated ( geo%glintzen)) then
      data_dim2_dtype1 = geo%glintzen(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("scattering_angle")
   if (allocated ( geo%scatangle)) then
      data_dim2_dtype1 = geo%scatangle(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("lunar_zenith_angle")
   if (allocated ( geo%lunzen)) then
      data_dim2_dtype1 = geo%lunzen(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("lunar_relative_azimuth_angle")
   if (allocated ( geo%lunrelaz)) then
      data_dim2_dtype1 = geo%lunrelaz(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("lunar_azimuth_angle")
   if (allocated ( geo%lunaz)) then
      data_dim2_dtype1 = geo%lunaz(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("glint_mask")
   if (allocated ( sfc%glint_mask)) then
      data_dim2_dtype1 = sfc%glint_mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("coast_mask")
   if (allocated ( sfc%coast_mask)) then
      data_dim2_dtype1 = sfc%coast_mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_type")
   if (allocated ( sfc%sfc_type)) then
      data_dim2_dtype1 = sfc%sfc_type(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("land_class")
   if (allocated ( sfc%land)) then
      data_dim2_dtype1 = sfc%land(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("snow_class")
   if (allocated ( sfc%snow)) then
      data_dim2_dtype1 = sfc%snow(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_elevation")
   if (allocated ( sfc%zsfc)) then
      data_dim2_dtype2 = sfc%zsfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom")
   if (allocated ( ch(1)%ref_toa)) then
      data_dim2_dtype2 = ch(1)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_86um_nom")
   if (allocated ( ch(2)%ref_toa)) then
      data_dim2_dtype2 = ch(2)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_47um_nom")
   if (allocated ( ch(3)%ref_toa)) then
      data_dim2_dtype2 = ch(3)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_1_60um_nom")
   if (allocated ( ch(6)%ref_toa)) then
      data_dim2_dtype2 = ch(6)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_sol_dnb_nom")
   if (allocated ( ch(44)%ref_toa)) then
      data_dim2_dtype2 = ch(44)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_lunar_dnb_nom")
   if (allocated ( ch(44)%ref_lunar_toa)) then
      data_dim2_dtype2 = ch(44)%ref_lunar_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_3_75um_nom")
   if (allocated ( ch(20)%ref_toa)) then
      data_dim2_dtype2 = ch(20)%ref_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_3_75um_nom")
   if (allocated ( ch(20)%bt_toa)) then
      data_dim2_dtype2 = ch(20)%bt_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_8_5um_nom")
   if (allocated ( ch(27)%bt_toa)) then
      data_dim2_dtype2 = ch(27)%bt_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_11_0um_nom")
   if (allocated ( ch(31)%bt_toa)) then
      data_dim2_dtype2 = ch(31)%bt_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_12_0um_nom")
   if (allocated ( ch(32)%bt_toa)) then
      data_dim2_dtype2 = ch(32)%bt_toa(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_stddev_3x3")
   if (allocated ( Ref_Ch1_Min_3x3)) then
      data_dim2_dtype1 = Ref_Ch1_Min_3x3(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_11_0um_nom_stddev_3x3")
   if (allocated ( Ref_Ch1_Std_3x3)) then
      data_dim2_dtype1 = Ref_Ch1_Std_3x3(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_probability")
   if (allocated ( posterior_cld_probability)) then
      data_dim2_dtype2 = posterior_cld_probability(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_mask")
   if (allocated ( cld_mask)) then
      data_dim2_dtype1 = cld_mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("adj_pix_cloud_mask")
   if (allocated ( Adj_Pix_Cld_Mask)) then
      data_dim2_dtype1 = Adj_Pix_Cld_Mask(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_mask_test_packed_results")
case("bayes_mask_sfc_type")
   if (allocated ( Bayes_Mask_Sfc_Type_Global)) then
      data_dim2_dtype1 = Bayes_Mask_Sfc_Type_Global(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_type")
   if (allocated ( cld_type)) then
      data_dim2_dtype1 = cld_type(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_phase")
   if (allocated ( cld_phase)) then
      data_dim2_dtype1 = cld_phase(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_press_acha")
   if (allocated ( acha%pc)) then
      data_dim2_dtype2 = acha%pc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_temp_acha")
   if (allocated ( acha%tc)) then
      data_dim2_dtype2 = acha%tc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_acha")
   if (allocated ( acha%zc)) then
      data_dim2_dtype2 = acha%zc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_top_acha")
   if (allocated ( acha%zc_top)) then
      data_dim2_dtype2 = acha%zc_top(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_base_acha")
   if (allocated ( acha%zc_base)) then
      data_dim2_dtype2 = acha%zc_base(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_altitude_acha")
   if (allocated ( acha%alt)) then
      data_dim2_dtype2 = acha%alt(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("acha_processing_order")
   if (allocated ( acha%processing_order)) then
      data_dim2_dtype1 = acha%processing_order(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("acha_inversion_flag")
   if (allocated ( ACHA%Inversion_Flag)) then
      data_dim2_dtype1 = ACHA%Inversion_Flag(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_h2o")
   if (allocated ( Zc_H2O)) then
      data_dim2_dtype2 = Zc_H2O(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_opaque")
   if (allocated ( Zc_opaque_cloud)) then
      data_dim2_dtype2 = Zc_opaque_cloud(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_emiss_acha")
   if (allocated ( acha%ec)) then
      data_dim2_dtype1 = acha%ec(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_beta_acha")
   if (allocated ( acha%beta)) then
      data_dim2_dtype1 = acha%beta(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_height_uncer_acha")
   if (allocated ( acha%zc_uncertainty)) then
      data_dim2_dtype1 = acha%zc_uncertainty(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_temp_uncer_acha")
   if (allocated ( acha%tc_uncertainty)) then
      data_dim2_dtype1 = acha%tc_uncertainty(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_temp_acha_qf")
   if (allocated ( acha%oe_quality_flags)) then
      data_dim2_dtype1 = acha%oe_quality_flags(1,:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_emiss_acha_qf")
   if (allocated ( acha%oe_quality_flags)) then
      data_dim2_dtype1 = acha%oe_quality_flags(2,:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_beta_acha_qf")
   if (allocated ( acha%oe_quality_flags)) then
      data_dim2_dtype1 = acha%oe_quality_flags(3,:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_acha")
   if (allocated ( acha%tau)) then
      data_dim2_dtype1 = acha%tau(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_acha")
   if (allocated ( acha%reff)) then
      data_dim2_dtype1 = acha%reff(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("acha_quality")
   if (allocated ( ACHA%Packed_Quality_Flags)) then
      data_dim2_dtype1 = ACHA%Packed_Quality_Flags(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("acha_info")
   if (allocated ( ACHA%Packed_Meta_Data_Flags)) then
      data_dim2_dtype1 = ACHA%Packed_Meta_Data_Flags(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_dcomp")
   if (allocated ( tau_dcomp)) then
      data_dim2_dtype2 = tau_dcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_dcomp")
   if (allocated ( reff_dcomp)) then
      data_dim2_dtype2 = reff_dcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_dcomp_unc")
   if (allocated ( tau_dcomp_cost)) then
      data_dim2_dtype2 = tau_dcomp_cost(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_dcomp_unc")
   if (allocated ( reff_dcomp_cost)) then
      data_dim2_dtype2 = reff_dcomp_cost(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_dcomp_qf")
   if (allocated ( tau_dcomp_qf)) then
      data_dim2_dtype1 = tau_dcomp_qf(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_dcomp_qf")
   if (allocated ( reff_dcomp_qf)) then
      data_dim2_dtype1 = reff_dcomp_qf(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("dcomp_quality")
   if (allocated ( Dcomp_quality_flag)) then
      data_dim2_dtype1 = Dcomp_quality_flag(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("dcomp_info")
   if (allocated ( dcomp_info_flag)) then
      data_dim2_dtype2 = dcomp_info_flag(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("insolation_dcomp")
   if (allocated ( Insolation_Dcomp)) then
      data_dim2_dtype2 = Insolation_Dcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("insolation_diffuse_dcomp")
   if (allocated ( Insolation_Dcomp_Diffuse)) then
      data_dim2_dtype2 = Insolation_Dcomp_Diffuse(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_nlcomp")
   if (allocated ( Tau_Nlcomp)) then
      data_dim2_dtype2 = Tau_Nlcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_nlcomp")
   if (allocated ( Reff_Nlcomp)) then
      data_dim2_dtype2 = Reff_Nlcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_opd_nlcomp_unc")
   if (allocated ( Tau_Nlcomp_Cost)) then
      data_dim2_dtype2 = Tau_Nlcomp_Cost(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_reff_nlcomp_unc")
   if (allocated ( Reff_Nlcomp_Cost)) then
      data_dim2_dtype2 = Reff_Nlcomp_Cost(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("nlcomp_quality")
   if (allocated ( Nlcomp_quality_flag)) then
      data_dim2_dtype1 = Nlcomp_quality_flag(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("nlcomp_info")
   if (allocated ( Nlcomp_Info_Flag)) then
      data_dim2_dtype2 = Nlcomp_Info_Flag(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_albedo_0_65um_nom")
   if (allocated ( cloud_063um_albedo)) then
      data_dim2_dtype1 = cloud_063um_albedo(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_transmission_0_65um_nom")
   if (allocated ( cloud_063um_transmission_solar)) then
      data_dim2_dtype1 = cloud_063um_transmission_solar(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_fraction")
   if (allocated ( Cloud_Fraction)) then
      data_dim2_dtype1 = Cloud_Fraction(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_fraction_uncertainty")
   if (allocated ( Cloud_Fraction_Uncer)) then
      data_dim2_dtype1 = Cloud_Fraction_Uncer(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("emissivity_11um_tropopause")
   if (allocated ( ch(31)%Emiss_Tropo)) then
      data_dim2_dtype1 = ch(31)%Emiss_Tropo(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("ndvi_sfc")
   if (allocated ( ndvi_sfc)) then
      data_dim2_dtype1 = ndvi_sfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_temperature_retrieved")
   if (allocated ( Tsfc_Retrieved)) then
      data_dim2_dtype1 = Tsfc_Retrieved(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_air_temperature_nwp")
   if (allocated ( Tair_Nwp_Pix)) then
      data_dim2_dtype1 = Tair_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_temperature_background")
   if (allocated ( Tsfc_Nwp_Pix)) then
      data_dim2_dtype2 = Tsfc_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_relative_humidity_nwp")
   if (allocated ( Rh_Nwp_Pix)) then
      data_dim2_dtype1 = Rh_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("surface_pressure_background")
   if (allocated ( Psfc_Nwp_Pix)) then
      data_dim2_dtype1 = Psfc_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("mean_sealevel_pressure_background")
   if (allocated ( Pmsl_Nwp_Pix)) then
      data_dim2_dtype1 = Pmsl_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("k_index_nwp")
   if (allocated ( K_Index_Nwp_Pix)) then
      data_dim2_dtype1 = K_Index_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_water_path_nwp")
   if (allocated ( Cwp_Nwp_Pix)) then
      data_dim2_dtype2 = Cwp_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_fraction_nwp")
   if (allocated ( Cfrac_Nwp_Pix)) then
      data_dim2_dtype1 = Cfrac_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cld_press_nwp")
   if (allocated ( Pc_Nwp_Pix)) then
      data_dim2_dtype1 = Pc_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("number_cloud_layers_nwp")
   if (allocated ( Ncld_Layers_Nwp_Pix)) then
      data_dim2_dtype1 = Ncld_Layers_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_type_nwp")
   if (allocated ( Cld_Type_Nwp_Pix)) then
      data_dim2_dtype1 = Cld_Type_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("tropopause_temperature_nwp")
   if (allocated ( Ttropo_Nwp_Pix)) then
      data_dim2_dtype1 = Ttropo_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("lcl_nwp")
   if (allocated ( LCL_Height_Nwp_Pix)) then
      data_dim2_dtype1 = LCL_Height_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("ccl_nwp")
   if (allocated ( CCL_Height_Nwp_Pix)) then
      data_dim2_dtype1 = CCL_Height_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_counts")
   if (allocated ( Ch1_Counts)) then
      data_dim2_dtype2 = Ch1_Counts(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_86um_nom_counts")
   if (allocated ( Ch2_Counts)) then
      data_dim2_dtype2 = Ch2_Counts(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_1_60um_nom_counts")
   if (allocated ( Ch6_Counts)) then
      data_dim2_dtype2 = Ch6_Counts(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("total_precipitable_water_nwp")
   if (allocated ( Tpw_Nwp_Pix)) then
      data_dim2_dtype1 = Tpw_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_3_75um_nom_atmos_corr")
   if (allocated ( ch(20)%Ref_Sfc)) then
      data_dim2_dtype2 = ch(20)%Ref_Sfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_atmos_corr")
   if (allocated ( ch(1)%Ref_Sfc)) then
      data_dim2_dtype2 = ch(1)%Ref_Sfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_86um_nom_atmos_corr")
   if (allocated ( ch(2)%Ref_Sfc)) then
      data_dim2_dtype1 = ch(2)%Ref_Sfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_1_60um_nom_atmos_corr")
   if (allocated ( ch(6)%Ref_Sfc)) then
      data_dim2_dtype1 = ch(6)%Ref_Sfc(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_clear_sky")
   if (allocated ( Ch(1)%Ref_Toa_Clear)) then
      data_dim2_dtype2 = Ch(1)%Ref_Toa_Clear(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_3_75um_nom_clear_sky")
   if (allocated ( ch(20)%Bt_Toa_Clear)) then
      data_dim2_dtype2 = ch(20)%Bt_Toa_Clear(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_8_5um_nom_clear_sky")
   if (allocated ( Ch(27)%Bt_Toa_Clear)) then
      data_dim2_dtype2 = Ch(27)%Bt_Toa_Clear(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_11_0um_nom_clear_sky")
   if (allocated ( Ch(31)%Bt_Toa_Clear)) then
      data_dim2_dtype2 = Ch(31)%Bt_Toa_Clear(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("temp_12_0um_nom_clear_sky")
   if (allocated ( Ch(32)%Bt_Toa_Clear)) then
      data_dim2_dtype2 = Ch(32)%Bt_Toa_Clear(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_mean_3x3")
   if (allocated ( Ref_Ch1_Mean_3x3)) then
      data_dim2_dtype2 = Ref_Ch1_Mean_3x3(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("pixel_sst_unmasked")
   if (allocated ( Sst_Unmasked)) then
      data_dim2_dtype2 = Sst_Unmasked(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("wind_speed_10m_nwp")
   if (allocated ( Wnd_Spd_10m_Nwp_Pix)) then
      data_dim2_dtype1 = Wnd_Spd_10m_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("wind_direction_10m_nwp")
   if (allocated ( Wnd_Dir_10m_Nwp_Pix)) then
      data_dim2_dtype1 = Wnd_Dir_10m_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("refl_0_65um_nom_dark")
   if (allocated ( Ref_Ch1_Dark_Composite)) then
      data_dim2_dtype2 = Ref_Ch1_Dark_Composite(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("cloud_water_path")
   if (allocated ( Cwp_Dcomp)) then
      data_dim2_dtype1 = Cwp_Dcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("rain_rate")
   if (allocated ( Rain_Rate_Dcomp)) then
      data_dim2_dtype1 = Rain_Rate_Dcomp(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("wind_speed_cloud_top_nwp")
   if (allocated ( Wnd_Spd_Cld_Top_Nwp_Pix)) then
      data_dim2_dtype1 = Wnd_Spd_Cld_Top_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
case("wind_direction_cloud_top_nwp")
   if (allocated ( Wnd_Dir_Cld_Top_Nwp_Pix)) then
      data_dim2_dtype1 = Wnd_Dir_Cld_Top_Nwp_Pix(:, Line_Idx_Min_Segment:Sds_Edge_2d(2) + Line_Idx_Min_Segment - 1)
   end if
end select