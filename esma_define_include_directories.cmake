set (esma_include  ${CMAKE_BINARY_DIR}/include CACHE PATH "include directory")
set (esma_etc  ${CMAKE_BINARY_DIR}/etc CACHE PATH "etc directory")
file (MAKE_DIRECTORY ${esma_include})
file (MAKE_DIRECTORY ${esma_etc})

macro (esma_set_include component)
  set (include_${component} ${esma_include}/${component})
  file (MAKE_DIRECTORY ${include_${component}})
endmacro ()

set (components
  NCEP_sp
  NCEP_bacio
  NCEP_sfcio
  NCEP_sigio
  NCEP_w3
  GMAO_mpeu
  GMAO_pilgrim
  GMAO_gfio_r4
  GMAO_gfio_r8
  GMAO_etc
  MAPL_cfio_r4
  MAPL_cfio_r8
  GMAO_pFIO
  MAPL_Base
  MAPL_pFUnit
  GEOS_Shared
  GMAO_hermes
  GEOS_Util
  Chem_Base
  Chem_Shared
     HEMCO
  GFDL_fms_r4
  GFDL_fms_r8
  LANL_cice
  GMAO_transf
  GMAO_stoch

  GEOSgcs_GridComp
    GEOSgcm_GridComp
      GEOSagcm_GridComp
      GEOSsuperdyn_GridComp
         FVdycore_GridComp
         FVdycoreCubed_GridComp
           fvdycore
         ARIESg3_GridComp
         GEOSdatmodyn_GridComp
      GEOSphysics_GridComp
        GEOSchem_GridComp
          GEOSpchem_GridComp
          GOCART_GridComp
            BC_GridComp
            BRC_GridComp
            CFC_GridComp
            CH4_GridComp
            CO2_GridComp
            CO_GridComp
            DU_GridComp
            NI_GridComp
            O3_GridComp
            OC_GridComp
            Rn_GridComp
            SS_GridComp
            SU_GridComp
          StratChem_GridComp
          GMIchem_GridComp
          CARMAchem_GridComp
          MATRIXchem_GridComp
          MAMchem_GridComp
          GEOSachem_GridComp
          GAAS_GridComp
          TR_GridComp
          DNA_GridComp
          HEMCO_GridComp
          GEOSCHEMchem_GridComp
        GEOSmoist_GridComp
        GEOSsurface_GridComp
          GEOS_SurfaceShared
          GEOSlandice_GridComp
          GEOSlake_GridComp
          GEOSland_GridComp
            GEOSvegdyn_GridComp
          GEOSroute_GridComp
          GEOScatchCN_GridComp
          GEOScatchCN_GridComp_openmp
          GEOScatch_GridComp
          GEOScatch_GridComp_openmp
          GEOS_LandShared
           GEOSsaltwater_GridComp
        GEOSturbulence_GridComp
        GEOSgwd_GridComp
        GEOSradiation_GridComp
          GEOS_RadiationShared
            RRTMGP
          GEOSirrad_GridComp  
          GEOSsolar_GridComp  
          GEOSsatsim_GridComp  
            RRTMG
            RRTMG_SW
    GEOSogcm_GridComp     
      GEOSorad_GridComp
      GEOSoradbio_GridComp
      GEOSoceanbiogeochem_GridComp
      GEOSoceanbiosimple_GridComp
      GEOSseaice_GridComp
      GuestOcean_GridComp
        MOM_GEOS5PlugMod
      GEOSdatasea_GridComp
      GEOSdataseaice_GridComp
    GEOSmkiau_GridComp
  )

foreach (component ${components})
  esma_set_include(${component})
endforeach ()


